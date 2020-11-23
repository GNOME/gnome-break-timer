/* TimerBreakDBusObject.vala
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

namespace BreakTimer.Daemon.TimerBreak {

[DBus (name = "org.gnome.BreakTimer.TimerBreak")]
private class TimerBreakDBusObject : GLib.Object, IBreakTimer_TimerBreak {
    private weak TimerBreakController break_controller;
    private weak TimerBreakView break_view;

    public TimerBreakDBusObject (TimerBreakController break_controller, TimerBreakView break_view) {
        this.break_controller = break_controller;
        this.break_view = break_view;
    }

    public TimerBreakStatus get_status () throws GLib.DBusError, GLib.IOError {
        return TimerBreakStatus () {
            is_enabled = this.break_controller.is_enabled (),
            is_focused = this.break_view.has_ui_focus (),
            is_active = this.break_controller.is_active (),
            starts_in = this.break_controller.starts_in (),
            time_remaining = this.break_controller.get_time_remaining (),
            current_duration = this.break_controller.get_current_duration ()
        };
    }

    public void activate () throws GLib.DBusError, GLib.IOError {
        this.break_controller.activate ();
    }
}

}
