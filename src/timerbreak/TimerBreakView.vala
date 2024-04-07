/* TimerBreakView.vala
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

using BreakTimer.Daemon.Break;

namespace BreakTimer.Daemon.TimerBreak {

public abstract class TimerBreakView : BreakView {
    protected TimerBreakController timer_break {
        get {
            return (TimerBreakController) this.break_controller;
        }
    }

    protected TimerBreakView (TimerBreakController timer_break, UIManager ui_manager) {
        base (timer_break, ui_manager);
    }

    protected int get_lead_in_seconds () {
        int lead_in = this.timer_break.duration+3;
        if (lead_in > 40) {
            lead_in = 40;
        } else if (lead_in < 15) {
            lead_in = 15;
        }
        return lead_in;
    }
}

}
