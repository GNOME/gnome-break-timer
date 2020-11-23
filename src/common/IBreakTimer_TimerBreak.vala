/* IBreakTimer_TimerBreak.vala
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

namespace BreakTimer.Common {

[DBus (name = "org.gnome.BreakTimer.TimerBreak")]
public interface IBreakTimer_TimerBreak : GLib.Object {
    /** Get the break's current status, such as time remaining, or time until the break starts */
    public abstract TimerBreakStatus get_status () throws GLib.DBusError, GLib.IOError;

    /** Activate the break */
    public abstract void activate () throws GLib.DBusError, GLib.IOError;
}

public struct BreakStatus {
    bool is_enabled;
    bool is_focused;
    bool is_active;
}

public struct TimerBreakStatus {
    bool is_enabled;
    bool is_focused;
    bool is_active;
    int starts_in;
    int time_remaining;
    int current_duration;
}

}
