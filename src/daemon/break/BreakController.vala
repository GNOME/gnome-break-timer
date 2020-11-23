/* BreakController.vala
 *
 * Copyright 2020 Dylan McCall <dylan@dylanmccall.ca>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using BreakTimer.Common;

namespace BreakTimer.Daemon.Break {

/**
 * Base class for a break's activity tracking functionality.
 * A break can be started or stopped, and once started it will be activated
 * and finished either manually or autonomously based on user activity, or
 * some related metric. The mechanism for activating a break and for
 * satisfying it is unique to each implementation.
 * This class provides mechanisms for tracking and directly setting the
 * break's state, which can be either WAITING, ACTIVE, or DISABLED.
 */
public abstract class BreakController : GLib.Object {
    /**
     * ''WAITING'':  The break has not started yet. For example, it may be
     *               monitoring user activity in the background, waiting
     *               until the user has been working for a particular
     *               time.
     * ''ACTIVE'':   The break has started. For example, when a break
     *               becomes active, it might show a "Take a break"
     *               screen. Once the break has been satisfied, it should
     *               return to the WAITING state.
     * ''DISABLED'': The break is not in use, and should not be monitoring
     *               activity. This state is usually set explicitly by
     *               BreakManager.
    */
    public enum State {
        WAITING,
        ACTIVE,
        DISABLED
    }
    public State state { get; private set; }

    public enum FinishedReason {
        DISABLED,
        SKIPPED,
        SATISFIED
    }

    /** The break has been enabled. It will monitor user activity and emit activated () or finished () signals until it is disabled. */
    public signal void enabled ();
    /** The break has been disabled. Its timers have been stopped and it will not do anything until it is enabled again. */
    public signal void disabled ();

    /** The break is going to happen soon */
    public signal void warned ();
    /** The break is no longer going to start soon */
    public signal void unwarned ();

    /** The break has been activated and is now counting down aggressively until it is satisfied. */
    public signal void activated ();
    /** The break has been satisfied. This can happen at any time, including while the break is waiting or after it has been activiated. */
    public signal void finished (BreakController.FinishedReason reason, bool was_active);

    /** The break is active and it has progressed in some fashion (for example, remaining time has changed). */
    public signal void active_changed ();

    private Value? activate_timestamp;

    protected BreakController () {
        this.state = State.DISABLED;
        this.activate_timestamp = null;
    }

    public virtual Json.Object serialize () {
        Json.Object json_root = new Json.Object ();
        json_root.set_int_member ("state", (int) this.state);
        if (this.activate_timestamp == null) {
            json_root.set_null_member ("activate_timestamp");
        } else {
            json_root.set_int_member ("activate_timestamp", (int64) this.activate_timestamp);
        }
        return json_root;
    }

    public virtual void deserialize (ref Json.Object json_root) {
        // State serialized_state = (State) json_root.get_int_member ("state");
        // We won't restore the original state directly. A BreakController
        // implementation should decide whether to activate at this stage.

        if (json_root.get_null_member ("activate_timestamp")) {
            this.activate_timestamp = null;
        } else {
            this.activate_timestamp = json_root.get_int_member ("activate_timestamp");
        }
    }

    /**
     * Set whether the break is enabled or disabled. If it is enabled,
     * it will periodically update in the background, and if it is
     * disabled it will do nothing (and consume fewer resources).
     * This will also emit the enabled () or disabled () signal.
     * @param enable True to enable the break, false to disable it
     */
    public void set_enabled (bool enable) {
        if (enable && !this.is_enabled ()) {
            this.state = State.WAITING;
            this.enabled ();
        } else if (!enable && this.is_enabled ()) {
            bool was_active = this.state == State.ACTIVE;
            this.state = State.DISABLED;
            this.finished (BreakController.FinishedReason.DISABLED, was_active);
            this.disabled ();
        }
    }

    /**
     * @return True if the break is enabled and waiting to start automatically
     */
    public bool is_enabled () {
        return this.state != State.DISABLED;
    }

    /**
     * @return True if the break has been activated, is in focus, and expects to be satisfied
     */
    public bool is_active () {
        return this.state == State.ACTIVE;
    }

    /**
     * @return The real time, in seconds, since the break was activated.
     */
    public int get_seconds_since_start () {
        if (this.activate_timestamp != null) {
            return (int) (TimeUnit.get_real_time_seconds () - (int64) this.activate_timestamp);
        } else {
            return 0;
        }
    }

    /**
     * Start a break. This is usually triggered automatically by the break
     * controller itself, but it may be triggered externally as well.
     */
    public void activate () {
        if (this.state < State.ACTIVE) {
            if (this.activate_timestamp == null) {
                this.activate_timestamp = (int64) TimeUnit.get_real_time_seconds ();
            }
            this.state = State.ACTIVE;
            this.activated ();
        }
    }

    /**
     * The break's requirements have been satisfied. Start counting from
     * the beginning again.
     */
    public void finish () {
        bool was_active = this.is_active ();
        this.state = State.WAITING;
        this.activate_timestamp = null;
        this.finished (BreakController.FinishedReason.SATISFIED, was_active);
    }

    /**
     * We're skipping this break. The BreakController should act as if the
     * break has finished as usual, but we will send a different
     * FinishedReason to the "finished" signal. This way, its BreakView will
     * know to present this differently than if the break has actually been
     * satisfied.
     * @param forget_start true to reset the value returned by get_seconds_since_start
     */
    public void skip (bool forget_start = false) {
        if (this.state == State.DISABLED) {
            return;
        }

        bool was_active = this.is_active ();
        this.state = State.WAITING;
        if (forget_start) {
            this.activate_timestamp = null;
        }
        this.finished (BreakController.FinishedReason.SKIPPED, was_active);
    }
}

}
