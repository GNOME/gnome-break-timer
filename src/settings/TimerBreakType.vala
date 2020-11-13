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

namespace BreakTimer.Settings {

public abstract class TimerBreakType : BreakType {
    public int interval { get; protected set; }
    public int duration { get; protected set; }

    public int[] interval_options;
    public int[] duration_options;

    public IBreakDaemon_TimerBreak? break_server;

    protected TimerBreakType (string name, GLib.Settings settings) {
        base (name, settings);
        settings.bind ("interval-seconds", this, "interval", SettingsBindFlags.GET);
        settings.bind ("duration-seconds", this, "duration", SettingsBindFlags.GET);
    }

    public signal void timer_status_changed (TimerBreakStatus? status);

    public override void initialize () {
        base.initialize ();
        Bus.watch_name (BusType.SESSION, Config.DAEMON_BUS_NAME, BusNameWatcherFlags.NONE,
                this.breakdaemon_appeared, this.breakdaemon_disappeared);
    }

    protected new void update_status (TimerBreakStatus? status) {
        if (status != null) {
            base.update_status (BreakStatus () {
                is_enabled = status.is_enabled,
                is_focused = status.is_focused,
                is_active = status.is_active
            });
        } else {
            base.update_status (null);
        }
        this.timer_status_changed (status);
    }

    private uint update_timeout_id;
    private bool update_status_cb () {
        TimerBreakStatus? status = this.get_status ();
        this.update_status (status);
        return true;
    }

    private TimerBreakStatus? get_status () {
        if (this.break_server != null) {
            try {
                return this.break_server.get_status ();
            } catch (IOError error) {
                GLib.warning ("Error connecting to break daemon service: %s", error.message);
                return null;
            } catch (GLib.DBusError error) {
                // FIXME: This fails if we call this before the helper has
                //        initialized. We should either add a dbus service
                //        definition or look closer before printing a scary
                //        error message.
                GLib.warning ("Error getting break status: %s", error.message);
                return null;
            }
        } else {
            return null;
        }
    }

    private void breakdaemon_appeared () {
        try {
            this.break_server = Bus.get_proxy_sync (
                BusType.SESSION,
                Config.DAEMON_BUS_NAME,
                Config.DAEMON_BREAK_OBJECT_BASE_PATH+this.id,
                DBusProxyFlags.DO_NOT_AUTO_START
            );
            // We can only poll the break daemon application for updates, so
            // for responsiveness we update at a faster than normal rate.
            this.update_timeout_id = Timeout.add (500, this.update_status_cb);
            this.update_status_cb ();
        } catch (IOError error) {
            this.break_server = null;
            GLib.warning ("Error connecting to break daemon service: %s", error.message);
        }
    }

    private void breakdaemon_disappeared () {
        if (this.update_timeout_id > 0) {
            Source.remove (this.update_timeout_id);
            this.update_timeout_id = 0;
        }
        this.break_server = null;
        this.update_status_cb ();
    }
}

}
