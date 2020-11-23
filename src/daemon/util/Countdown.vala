/* Countdown.vala
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

namespace BreakTimer.Daemon.Util {

/**
 * A countdown timer that counts seconds from a start time down to 0. Uses
 * "wall-clock" time instead of monotonic time, so it will count regardless
 * of system state. The countdown can be paused, and its duration can be
 * adjusted at any time using penalty and bonus time.
 */
public class Countdown : GLib.Object {
    private enum State {
        STOPPED,
        PAUSED,
        COUNTING
    }
    private State state;

    private int base_duration;

    private int64 start_time;
    private int stop_time_elapsed;
    private int penalty;

    public Countdown (int base_duration) {
        this.base_duration = base_duration;
        this.reset ();
    }

    public string serialize () {
        int serialized_time_counted = (int) (TimeUnit.get_real_time_seconds () - this.start_time);
        serialized_time_counted = int.max (0, serialized_time_counted);

        return string.joinv (",", {
            ((int) this.state).to_string (),
            this.start_time.to_string (),
            this.stop_time_elapsed.to_string (),
            this.penalty.to_string (),
            serialized_time_counted.to_string ()
        });
    }

    public void deserialize (string data, bool persistent = false) {
        string[] data_parts = data.split (",");

        State serialized_state = (State) int.parse (data_parts[0]);

        switch (serialized_state) {
            case State.STOPPED:
                this.reset ();
                break;
            case State.PAUSED:
                this.pause ();
                break;
            case State.COUNTING:
                this.start ();
                break;
        }

        this.stop_time_elapsed = int.parse (data_parts[2]);
        this.penalty = int.parse (data_parts[3]);

        if (persistent) {
            // Pretend the countdown has been running since it was serialized
            this.start_time = int64.parse (data_parts[1]);
        } else {
            // Resume where the timer left off
            if (serialized_state == State.COUNTING) {
                int serialized_time_counted = int.parse (data_parts[4]);
                this.advance_time (serialized_time_counted);
            }
        }
    }

    /**
     * Stop the countdown and forget its current position.
     * This is the same as calling Countdown.start (), except the countdown
     * will not advance.
     */
    public void reset () {
        this.penalty = 0;
        this.stop_time_elapsed = 0;
        this.state = State.STOPPED;
    }

    /**
     * Start counting down from the time set with set_base_duration.
     * This is the same as calling Countdown.stop () followed by
     * Countdown.continue ().
     */
    public void start () {
        this.start_from (0);
    }

    /**
     * Start counting with the time offset by the given number of seconds.
     * Useful if the countdown should have started in the past.
     * @param start_offset the number of seconds to offset the start time,
     *                     where a negative value brings the countdown closer
     *                     to being finished.
     */
    public void start_from (int start_offset) {
        this.reset ();
        this.continue_from (start_offset);
    }

    /**
     * Pause the countdown, keeping its current position.
     */
    public void pause () {
        this.stop_time_elapsed = this.get_time_elapsed ();
        this.state = State.PAUSED;
    }

    /**
     * Start the countdown, continuing from the current position if
     * possible.
     */
    public void continue () {
        if (this.state < State.COUNTING) {
            this.continue_from (0);
        }
    }

    /**
     * If not already counting, start counting with the time offset by the
     * given number of seconds. This is like start_from, but it never resets
     * the countdown.
     * @param start_offset the number of seconds to offset the start time,
     *                     where a negative value brings the countdown closer
     *                     to being finished.
     */
    public void continue_from (int start_offset) {
        if (this.state < State.COUNTING) {
            int64 now = TimeUnit.get_real_time_seconds ();
            this.start_time = now + start_offset;
            this.state = State.COUNTING;
        }
    }

    /**
     * If the countdown is paused, continue as if that never happened. This
     * has the effect of the countdown advancing by the time for which it was
     * paused.
     */
    public void cancel_pause () {
        if (this.state == State.PAUSED) {
            this.stop_time_elapsed = 0;
            this.state = State.COUNTING;
        }
    }

    /**
     * Advance the countdown by the number of seconds, regardless of its
     * present state. If the countdown is currently paused, calling continue
     * will take into account the given offset.
     * @param seconds_off the number of seconds to advance the countdown,
     *                    where a positive value brings it closer to being
     *                    finished.
     */
    public void advance_time (int seconds_off) {
        int64 now = TimeUnit.get_real_time_seconds ();
        if (this.state == State.COUNTING) {
            this.start_time = now - seconds_off;
        } else {
            this.stop_time_elapsed += seconds_off;
        }
    }

    /**
     * Sets a temporary time penalty. This increases the countdown's duration
     * until it is reset.
     * @param penalty the number of seconds extra the countdown will last.
     */
    public void set_penalty (int penalty) {
        this.penalty = penalty;
    }

    /**
     * @return the current time penalty for the countdown.
     * @see set_penalty
     */
    public int get_penalty () {
        return this.penalty;
    }

    /**
     * @return true if the countdown is currently counting, or false if it is
     *         either stopped or paused.
     */
    public bool is_counting () {
        return this.state == State.COUNTING;
    }

    /**
     * Sets the base duration for the countdown. This is how long the
     * countdown will last from when it is freshly started.
     *
     * The base duration can be changed while the countdown is counting. The
     * elapsed time will not change, while the remaining time will increase or
     * decrease based on that elapsed time, the new base duration, and the
     * current penalty.
     *
     * @param base_duration the new base duration for the countdown
     */
    public void set_base_duration (int base_duration) {
        this.base_duration = base_duration;
    }

    /**
     * Returns the current duration for the countdown. This is not the same as
     * the base duration: it takes into account the penalty, as well. The
     * return value will change as the time penalty changes.
     * @return the countdown's duration
     */
    public int get_duration () {
        return int.max (0, this.base_duration + this.penalty);
    }

    /**
     * Returns the amount of time that the countdown has been counting, if at
     * all. If the countdown is paused, this will return the elapsed time from
     * the point when it was paused.
     * @return the countdown's current elapsed time, or 0
     */
    public int get_time_elapsed () {
        int time_elapsed = this.stop_time_elapsed;

        if (this.state == State.COUNTING) {
            int64 now = TimeUnit.get_real_time_seconds ();
            time_elapsed += (int) (now - this.start_time);
        }

        return int.max (0, time_elapsed);
    }

    /**
     * Returns the time remaining until the countdown will be finished, or 0
     * if the countdown is already finished. If the countdown is not counting,
     * this will return its current duration.
     * @return the time the countdown needs to count until it is finished
     */
    public int get_time_remaining () {
        int time_remaining = this.get_duration () - this.get_time_elapsed ();
        return int.max (0, time_remaining);
    }

    /**
     * Returns true if the countdown is finished; if its elapsed time meets or
     * exceeds its duration. This is equivalent to checking if the remaining
     * time is 0.
     * @return true if the countdown is finished.
     */
    public bool is_finished () {
        return this.get_time_remaining () == 0;
    }
}

}
