/* BreakManagerDBusObject.vala
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
using BreakTimer.Daemon.Break;

namespace BreakTimer.Daemon {

[DBus (name = "org.gnome.BreakTimer")]
public class BreakManagerDBusObject : GLib.Object, IBreakTimer {
    private weak BreakManager break_manager;

    public BreakManagerDBusObject (BreakManager break_manager) {
        this.break_manager = break_manager;
    }

    public string[] get_current_active_break () throws GLib.DBusError, GLib.IOError {
        foreach (BreakType break_type in this.break_manager.all_breaks ()) {
            bool is_active = break_type.break_view.has_ui_focus () &&
                break_type.break_controller.is_active ();
            if (is_active) return {break_type.id};
        }
        return {};
    }

    public bool is_active () throws GLib.DBusError, GLib.IOError {
        bool active = false;
        foreach (BreakType break_type in this.break_manager.all_breaks ()) {
            active = active || break_type.break_controller.is_active ();
        }
        return active;
    }

    public string[] get_break_ids () throws GLib.DBusError, GLib.IOError {
        var break_ids = new GLib.Array<string> ();
        foreach (unowned string break_id in this.break_manager.all_break_ids ()) {
            break_ids.append_val (break_id);
        }
        return break_ids.data;
    }

    public string[] get_status_messages () throws GLib.DBusError, GLib.IOError {
        var messages = new GLib.Array<string> ();
        foreach (BreakType break_type in break_manager.all_breaks ()) {
            string? status_message = break_type.break_view.get_status_message ();
            messages.append_val ("%s:\t%s".printf (break_type.id, status_message));
        }
        return messages.data;
    }

    public void activate_break (string break_name) throws GLib.DBusError, GLib.IOError {
        BreakType? break_type = this.break_manager.get_break_type_for_name (break_name);
        if (break_type != null) break_type.break_controller.activate ();
    }
}

}
