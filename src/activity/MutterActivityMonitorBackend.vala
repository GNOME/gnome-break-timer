/* MutterActivityMonitorBackend.vala
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
using BreakTimer.Daemon.Util;

namespace BreakTimer.Daemon.Activity {

public class MutterActivityMonitorBackend : ActivityMonitorBackend, GLib.Initable {
    private GLib.DBusConnection dbus_connection;

    private IMutterIdleMonitor? mutter_idle_monitor;
    private uint32 idle_watch_id;
    private uint32 user_active_watch_id;

    private uint64 last_idle_time_ms;
    private int64 last_idle_time_update_time_ms;
    private bool user_is_active;
    private uint active_idle_poll_source_id;

    private const uint IDLE_WATCH_INTERVAL_MS = 1 * TimeUnit.MILLISECONDS_IN_SECONDS;

    public MutterActivityMonitorBackend () {
        this.user_is_active = false;
        this.last_idle_time_update_time_ms = 0;
        this.active_idle_poll_source_id = 0;
    }

    ~MutterActivityMonitorBackend () {
        if (this.mutter_idle_monitor != null && this.idle_watch_id > 0) {
            try {
                this.mutter_idle_monitor.remove_watch (this.idle_watch_id);
            } catch (GLib.IOError error) {
                GLib.warning ("Error connecting to mutter idle monitor service: %s", error.message);
            } catch (GLib.DBusError error) {
                GLib.warning ("Error removing mutter idle watch: %s", error.message);
            }
        }
    }

    public override bool init (GLib.Cancellable? cancellable) throws GLib.Error {
        this.dbus_connection = GLib.Bus.get_sync (GLib.BusType.SESSION, cancellable);
        GLib.Bus.watch_name_on_connection (
            this.dbus_connection,
            "org.gnome.Mutter.IdleMonitor",
            GLib.BusNameWatcherFlags.NONE,
            this.mutter_idle_monitor_appeared,
            this.mutter_idle_monitor_disappeared
        );
        return true;
    }

    private void mutter_idle_monitor_appeared () {
        try {
            this.mutter_idle_monitor = GLib.Bus.get_proxy_sync (
                GLib.BusType.SESSION,
                "org.gnome.Mutter.IdleMonitor",
                "/org/gnome/Mutter/IdleMonitor/Core"
            );
            this.mutter_idle_monitor.watch_fired.connect (this.mutter_idle_monitor_watch_fired_cb);
            this.idle_watch_id = this.mutter_idle_monitor.add_idle_watch (IDLE_WATCH_INTERVAL_MS);
            this.set_user_is_active (false);
        } catch (GLib.IOError error) {
            this.mutter_idle_monitor = null;
            GLib.warning ("Error connecting to mutter idle monitor service: %s", error.message);
        } catch (GLib.DBusError error) {
            this.mutter_idle_monitor = null;
            GLib.warning ("Error adding mutter idle watch: %s", error.message);
        }
    }

    private void mutter_idle_monitor_disappeared () {
        GLib.warning ("Mutter idle monitor disappeared");
        this.mutter_idle_monitor = null;
        this.idle_watch_id = 0;
    }

    private void mutter_idle_monitor_watch_fired_cb (uint32 id) {
        if (id == this.idle_watch_id) {
            this.idle_watch_cb ();
        } else if (id == this.user_active_watch_id) {
            this.user_active_watch_cb ();
        }
    }

    private void start_active_idle_poll () {
        // In some cases, such as applications triggering fake events to
        // suppress the screensaver, the active watch fires but idle time
        // does not reset. As we are not the screensaver, we would like to
        // treat these cases like idle time, so we will need to poll manually
        // as long as Mutter is reporting that the user as active.
        // TODO: Track this issue in Mutter and remove this code when possible.
        if (this.active_idle_poll_source_id == 0) {
            this.active_idle_poll_source_id = GLib.Timeout.add_seconds (
                IDLE_WATCH_INTERVAL_MS / TimeUnit.MILLISECONDS_IN_SECONDS, this.active_idle_poll_cb
            );
        }
    }

    private void stop_active_idle_poll () {
        if (this.active_idle_poll_source_id != 0) {
            GLib.Source.remove (this.active_idle_poll_source_id);
            this.active_idle_poll_source_id = 0;
        }
    }

    private void idle_watch_cb () {
        this.poll_activity ();
        this.set_user_is_active (false);
        this.stop_active_idle_poll ();
    }

    private void user_active_watch_cb () {
        this.user_active_watch_id = 0;
        this.poll_activity ();
        this.set_user_is_active (true);
    }

    private bool active_idle_poll_cb () {
        this.poll_activity ();
        this.set_user_is_active (this.last_idle_time_ms < IDLE_WATCH_INTERVAL_MS);
        return GLib.Source.CONTINUE;
    }

    private void poll_activity () {
        try {
            this.last_idle_time_ms = this.mutter_idle_monitor.get_idletime ();
            this.last_idle_time_update_time_ms = TimeUnit.get_monotonic_time_ms ();
        } catch (GLib.IOError error) {
            GLib.warning ("Error connecting to mutter idle monitor service: %s", error.message);
        } catch (GLib.DBusError error) {
            GLib.warning ("Error getting mutter idletime: %s", error.message);
        }
    }

    private void set_user_is_active (bool active) {
        if (active) {
            this.start_active_idle_poll ();
        } else {
            try {
                this.user_active_watch_id = this.mutter_idle_monitor.add_user_active_watch ();
            } catch (GLib.IOError error) {
                GLib.warning ("Error connecting to mutter idle monitor service: %s", error.message);
            } catch (GLib.DBusError error) {
                GLib.warning ("Error adding mutter user active watch: %s", error.message);
            }
        }
        this.user_is_active = active;
    }

    protected override uint64 time_since_last_event_ms () {
        if (this.user_is_active) {
            return 0;
        } else if (this.last_idle_time_update_time_ms > 0) {
            int64 now = TimeUnit.get_monotonic_time_ms ();
            int64 time_since = now - this.last_idle_time_update_time_ms;
            return time_since + this.last_idle_time_ms;
        } else {
            return 0;
        }
    }
}

}
