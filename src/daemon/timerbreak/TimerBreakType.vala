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
    protected TimerBreakType (string id, BreakController break_controller, BreakView break_view) {
        base (id, break_controller, break_view);
    }

    public override bool init (GLib.Cancellable? cancellable) throws GLib.Error {
        var timer_break_controller = (TimerBreakController) this.break_controller;
        var timer_break_view = (TimerBreakView) this.break_view;

        var dbus_object = new TimerBreakDBusObject (
            timer_break_controller,
            timer_break_view
        );

        try {
            GLib.DBusConnection connection = GLib.Bus.get_sync (GLib.BusType.SESSION, null);
            connection.register_object (
                Config.DAEMON_BREAK_OBJECT_BASE_PATH+this.id,
                dbus_object
            );
        } catch (GLib.IOError error) {
            GLib.error ("Error registering break type on the session bus: %s", error.message);
        }

        return base.init (cancellable);
    }
}

}
