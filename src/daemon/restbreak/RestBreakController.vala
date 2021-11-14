/* RestBreakController.vala
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

using BreakTimer.Daemon.Activity;
using BreakTimer.Daemon.TimerBreak;
using BreakTimer.Daemon.Util;

namespace BreakTimer.Daemon.RestBreak {

/**
 * A type of timer break designed for longer durations. Satisfied when the user
 * is inactive for its entire duration, but allows the user to interact with
 * the computer while it counts down. The timer will stop until the user has
 * finished using the computer, and then it will start to count down again.
 */
public class RestBreakController : TimerBreakController {
    public bool lock_screen_enabled { get; set; }

    private Countdown reminder_countdown;

    public signal void current_duration_changed ();

    public RestBreakController (ActivityMonitor activity_monitor) {
        base (activity_monitor, 5);

        // Countdown for an extra reminder that a break is ongoing, if the
        // user is ignoring it
        this.reminder_countdown = new Countdown (this.interval / 4);
        this.notify["interval"].connect ((s, p) => {
            this.reminder_countdown.set_base_duration (this.interval / 4);
        });
        this.activated.connect (() => {
            this.reminder_countdown.reset ();
        });

        this.counting.connect (this.counting_cb);
        this.delayed.connect (this.delayed_cb);
    }

    public override Json.Object serialize () {
        Json.Object json_root = base.serialize ();
        json_root.set_string_member ("reminder_countdown", this.reminder_countdown.serialize ());
        return json_root;
    }

    public override void deserialize (ref Json.Object json_root) {
        base.deserialize (ref json_root);
        this.reminder_countdown.deserialize (json_root.get_string_member ("reminder_countdown"));
    }

    private void counting_cb (int lap_time, int total_time) {
        this.reminder_countdown.pause ();
        if (lap_time > 60) {
            this.reminder_countdown.reset ();
        }
    }

    private void delayed_cb (int lap_time, int total_time) {
        if (this.state == State.WAITING && lap_time > 10) {
            this.duration_countdown.reset ();
        }
        this.reminder_countdown.continue ();

        if (this.reminder_countdown.is_finished ()) {
            // Demand attention if the break is delayed for a long time
            int new_penalty = this.duration_countdown.get_penalty () + (this.duration/4);
            new_penalty = int.min (new_penalty, this.duration/2);
            this.duration_countdown.reset ();
            this.duration_countdown.set_penalty (new_penalty);
            this.current_duration_changed ();
            this.reminder_countdown.start ();
        }
    }
}

}
