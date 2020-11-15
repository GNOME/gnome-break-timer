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

namespace BreakTimer.Daemon {

public abstract class TimerBreakType : BreakType {
    private TimerBreakDBusObject dbus_object;

    protected TimerBreakType (string id, GLib.Settings settings) {
        base (id, settings);
    }

    protected override void initialize (UIManager ui_manager) {
        base.initialize (ui_manager);

        var timer_break_controller = (TimerBreakController)this.break_controller;
        var timer_break_view = (TimerBreakView)this.break_view;

        this.settings.bind ("interval-seconds", timer_break_controller, "interval", GLib.SettingsBindFlags.GET);
        this.settings.bind ("duration-seconds", timer_break_controller, "duration", GLib.SettingsBindFlags.GET);

        this.dbus_object = new TimerBreakDBusObject (
            timer_break_controller,
            timer_break_view
        );
        try {
            GLib.DBusConnection connection = GLib.Bus.get_sync (GLib.BusType.SESSION, null);
            connection.register_object (
                Config.DAEMON_BREAK_OBJECT_BASE_PATH+this.id,
                this.dbus_object
            );
        } catch (GLib.IOError error) {
            GLib.error ("Error registering break type on the session bus: %s", error.message);
        }
    }
}

}
