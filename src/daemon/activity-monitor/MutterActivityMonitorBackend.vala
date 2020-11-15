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

public class MutterActivityMonitorBackend : ActivityMonitorBackend {
    private IMutterIdleMonitor? mutter_idle_monitor;
    private uint32 idle_watch_id;
    private uint32 user_active_watch_id;

    private uint64 last_idle_time_ms;
    private int64 last_idle_time_update_time_ms;
    private bool user_is_active;

    private static uint64 IDLE_WATCH_INTERVAL_MS = 1000;

    public MutterActivityMonitorBackend () {
        this.user_is_active = false;
        Bus.watch_name (
            BusType.SESSION,
            "org.gnome.Mutter.IdleMonitor",
            BusNameWatcherFlags.NONE,
            this.mutter_idle_monitor_appeared,
            this.mutter_idle_monitor_disappeared
        );
    }

    ~MutterActivityMonitorBackend() {
        if (this.mutter_idle_monitor != null && this.idle_watch_id > 0) {
            this.mutter_idle_monitor.remove_watch (this.idle_watch_id);
        }
    }

    private void mutter_idle_monitor_appeared () {
        try {
            this.mutter_idle_monitor = Bus.get_proxy_sync (
                BusType.SESSION,
                "org.gnome.Mutter.IdleMonitor",
                "/org/gnome/Mutter/IdleMonitor/Core"
            );
            this.mutter_idle_monitor.watch_fired.connect (this.mutter_idle_monitor_watch_fired_cb);
            this.idle_watch_id = this.mutter_idle_monitor.add_idle_watch (IDLE_WATCH_INTERVAL_MS);
            this.update_last_idle_time();
        } catch (IOError error) {
            this.mutter_idle_monitor = null;
            GLib.warning ("Error connecting to mutter idle monitor service: %s", error.message);
        } catch (GLib.DBusError error) {
            this.mutter_idle_monitor = null;
            GLib.warning ("Error adding mutter idle watch: %s", error.message);
        }
    }

    private void mutter_idle_monitor_disappeared () {
        this.mutter_idle_monitor = null;
        this.idle_watch_id = 0;
    }

    private void mutter_idle_monitor_watch_fired_cb (uint32 id) {
        if (id == this.idle_watch_id) {
            this.user_is_active = false;
            this.update_last_idle_time();
            try {
                this.user_active_watch_id = this.mutter_idle_monitor.add_user_active_watch ();
            } catch (IOError error) {
                GLib.warning ("Error connecting to mutter idle monitor service: %s", error.message);
            } catch (GLib.DBusError error) {
                GLib.warning ("Error adding mutter user active watch: %s", error.message);
            }
        } else if (id == this.user_active_watch_id) {
            this.user_is_active = true;
            this.user_active_watch_id = 0;
        }
    }

    private void update_last_idle_time() {
        try {
            this.last_idle_time_ms = this.mutter_idle_monitor.get_idletime ();
        } catch (IOError error) {
            GLib.warning ("Error connecting to mutter idle monitor service: %s", error.message);
        } catch (GLib.DBusError error) {
            GLib.warning ("Error getting mutter idletime: %s", error.message);
        }
        this.last_idle_time_update_time_ms = TimeUnit.get_monotonic_time_ms ();
    }

    protected override uint64 time_since_last_event_ms () {
        if (this.user_is_active) {
            return 0;
        } else {
            int64 now = TimeUnit.get_monotonic_time_ms ();
            int64 time_since = now - this.last_idle_time_update_time_ms;
            uint64 idle_time_ms = this.last_idle_time_ms + time_since;
            return idle_time_ms;
        }
    }
}

}
