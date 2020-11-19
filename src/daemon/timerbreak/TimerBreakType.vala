/*
 * This file is part of GNOME Break Timer.
 *
 * GNOME Break Timer is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * GNOME Break Timer is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with GNOME Break Timer.  If not, see <http://www.gnu.org/licenses/>.
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
            Config.DAEMON_BREAK_OBJECT_BASE_PATH+this.id,
            new TimerBreakDBusObject (
                (TimerBreakController) this.break_controller,
                (TimerBreakView) this.break_view
            )
        );

        return base.init (cancellable);
    }
}

}
