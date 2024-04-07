/* MicroBreakController.vala
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

namespace BreakTimer.Daemon.MicroBreak {

/**
 * A type of timer break that should activate frequently and for short
 * durations. Satisfied when the user is inactive for its entire duration,
 * and when it is active it restarts its countdown whenever the user types
 * or moves the mouse.
 */
public class MicroBreakController : TimerBreakController {
    public MicroBreakController (ActivityMonitor activity_monitor) {
        base (activity_monitor, 0);
        this.delayed.connect (this.delayed_cb);
    }

    private void delayed_cb (int lap_time, int total_time) {
        this.duration_countdown.reset ();
    }
}

}
