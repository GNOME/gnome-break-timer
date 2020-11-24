/* TimerBreakType.vala
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

public abstract class TimerBreakType : BreakType {
    private GLib.DBusConnection dbus_connection;

    protected TimerBreakType (string id, BreakController break_controller, BreakView break_view) {
        base (id, break_controller, break_view);
    }

    public override bool init (GLib.Cancellable? cancellable) throws GLib.Error {
        this.dbus_connection = GLib.Bus.get_sync (GLib.BusType.SESSION, cancellable);

        this.dbus_connection.register_object (
            Config.DAEMON_OBJECT_PATH + "/" + this.id,
            new TimerBreakDBusObject (
                (TimerBreakController) this.break_controller,
                (TimerBreakView) this.break_view
            )
        );

        return base.init (cancellable);
    }
}

}
