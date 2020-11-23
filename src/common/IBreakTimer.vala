/* IBreakTimer.vala
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

[DBus (name = "org.gnome.BreakTimer")]
public interface IBreakTimer : GLib.Object {
    /** Returns the ID of the break that is currently focused and activated, if any. */
    public abstract string[] get_current_active_break () throws GLib.DBusError, GLib.IOError;

    /** Returns a list of breaks that are currently known to the break daemon. */
    public abstract string[] get_break_ids () throws GLib.DBusError, GLib.IOError;

    /** Returns a list of helpful status messages for each break, for debugging. */
    public abstract string[] get_status_messages () throws GLib.DBusError, GLib.IOError;

    /** Activate the specified break immediately, regardless of the usual activation conditions. */
    public abstract void activate_break (string break_id) throws GLib.DBusError, GLib.IOError;

    // TODO: It might make sense to communicate when the active break changes,
    // using a signal. The only reason we don't at the moment is it adds
    // complexity in the break daemon, and the settings app already polls the
    // dbus service regularly for updates.
}

}
