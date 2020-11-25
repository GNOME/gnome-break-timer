/* IMutterIdleMonitor.vala
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

[DBus (name = "org.gnome.Mutter.IdleMonitor")]
public interface IMutterIdleMonitor : GLib.Object {
    public signal void watch_fired (uint32 id);

    public abstract uint32 add_idle_watch (uint64 interval_ms) throws GLib.DBusError, GLib.IOError;
    public abstract uint32 add_user_active_watch () throws GLib.DBusError, GLib.IOError;
    public abstract uint64 get_idletime () throws GLib.DBusError, GLib.IOError;
    public abstract void remove_watch (uint32 id) throws GLib.DBusError, GLib.IOError;
    public abstract void reset_idletime () throws GLib.DBusError, GLib.IOError;
}

}
