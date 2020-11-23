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
    private Gnome.IdleMonitor? gnome_idle_monitor;
    private uint32 idle_watch_id;
    private uint32 user_active_watch_id;

    private uint64 last_idle_time_ms;
    private int64 last_idle_time_update_time_ms;
    private bool user_is_active;
    private uint active_idle_poll_source_id;

    private const uint IDLE_WATCH_INTERVAL_MS = 1 * TimeUnit.MILLISECONDS_IN_SECONDS;

    public MutterActivityMonitorBackend () {
        this.user_is_active = false;
        this.active_idle_poll_source_id = 0;
    }

    ~MutterActivityMonitorBackend () {
        if (this.gnome_idle_monitor != null && this.idle_watch_id > 0) {
            this.gnome_idle_monitor.remove_watch (this.idle_watch_id);
        }
    }

    public override bool init (GLib.Cancellable? cancellable) throws GLib.Error {
        this.gnome_idle_monitor = new Gnome.IdleMonitor ();
        this.gnome_idle_monitor.init (cancellable);
        this.idle_watch_id = this.gnome_idle_monitor.add_idle_watch (
            IDLE_WATCH_INTERVAL_MS, this.idle_watch_cb
        );
        return true;
    }

    private void idle_watch_cb () {
        this.update_idle_time ();
        this.user_is_active = false;
        this.stop_active_idle_poll ();
        this.user_active_watch_id = this.gnome_idle_monitor.add_user_active_watch (
            this.user_active_watch_cb
        );
    }

    private void user_active_watch_cb () {
        this.user_active_watch_id = 0;
        this.update_idle_time ();
        this.start_active_idle_poll ();
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

    private bool active_idle_poll_cb () {
        this.update_idle_time ();
        return GLib.Source.CONTINUE;
    }

    private void update_idle_time () {
        this.last_idle_time_ms = this.gnome_idle_monitor.get_idletime ();
        this.last_idle_time_update_time_ms = TimeUnit.get_monotonic_time_ms ();
        this.user_is_active = (this.last_idle_time_ms < IDLE_WATCH_INTERVAL_MS);
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
