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

using BreakTimer.Common;
using BreakTimer.Settings.Break;

namespace BreakTimer.Settings.TimerBreak {

public class BreakTimeOption : GLib.Object {
    public int time_seconds {get; protected set; }
    public bool is_custom { get; protected set; default = false; }
    public string label { get; protected set; }

    public BreakTimeOption (int time_seconds) {
        this.time_seconds = time_seconds;
        this.label = NaturalTime.instance.get_label_for_seconds (this.time_seconds);
    }

    public bool equals (BreakTimeOption other) {
        return this.time_seconds == other.time_seconds;
    }
}

public abstract class TimerBreakType : BreakType {
    public int interval { get; protected set; }
    public int duration { get; protected set; }

    public BreakTimeOption[] interval_options;
    public BreakTimeOption[] duration_options;

    private GLib.DBusConnection dbus_connection;
    private IBreakTimer_TimerBreak? break_server;

    public signal void timer_status_changed (TimerBreakStatus? status);

    protected TimerBreakType (string name, GLib.Settings settings) {
        base (name, settings);
        settings.bind ("interval-seconds", this, "interval", SettingsBindFlags.GET);
        settings.bind ("duration-seconds", this, "duration", SettingsBindFlags.GET);
    }

    public override bool init (GLib.Cancellable? cancellable) throws GLib.Error {
        this.dbus_connection = GLib.Bus.get_sync (GLib.BusType.SESSION, cancellable);

        GLib.Bus.watch_name_on_connection (
            this.dbus_connection,
            Config.DAEMON_APPLICATION_ID,
            GLib.BusNameWatcherFlags.NONE,
            this.breakdaemon_appeared,
            this.breakdaemon_disappeared
        );

        return base.init (cancellable);
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
        return GLib.Source.CONTINUE;
    }

    private TimerBreakStatus? get_status () {
        if (this.break_server != null) {
            try {
                return this.break_server.get_status ();
            } catch (GLib.IOError error) {
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
            this.break_server = this.dbus_connection.get_proxy_sync (
                Config.DAEMON_APPLICATION_ID,
                Config.DAEMON_OBJECT_PATH + "/" + this.id,
                GLib.DBusProxyFlags.DO_NOT_AUTO_START
            );
            // We can only poll the break daemon application for updates, so
            // for responsiveness we update at a faster than normal rate.
            this.update_timeout_id = GLib.Timeout.add (500, this.update_status_cb);
            this.update_status_cb ();
        } catch (GLib.IOError error) {
            this.break_server = null;
            GLib.warning ("Error connecting to break daemon service: %s", error.message);
        }
    }

    private void breakdaemon_disappeared () {
        if (this.update_timeout_id > 0) {
            GLib.Source.remove (this.update_timeout_id);
            this.update_timeout_id = 0;
        }
        this.break_server = null;
        this.update_status_cb ();
    }
}

}
