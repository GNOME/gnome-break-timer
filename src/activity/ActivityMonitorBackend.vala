/* ActivityMonitorBackend.vala
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

public abstract class ActivityMonitorBackend : GLib.Object, GLib.Initable {
    private int64 last_real_time = 0;
    private int64 last_monotonic_time = 0;

    public virtual bool init (GLib.Cancellable? cancellable) throws GLib.Error {
        return true;
    }

    public virtual Json.Object serialize () {
        Json.Object json_root = new Json.Object ();
        json_root.set_int_member ("last_real_time", this.last_real_time);
        json_root.set_int_member ("last_monotonic_time", this.last_monotonic_time);
        return json_root;
    }

    public virtual void deserialize (ref Json.Object json_root) {
        this.last_real_time = json_root.get_int_member ("last_real_time");
        this.last_monotonic_time = json_root.get_int_member ("last_monotonic_time");
    }

    protected abstract uint64 time_since_last_event_ms ();

    public int64 get_idle_seconds () {
        uint64 idle_ms = this.time_since_last_event_ms ();
        return (int64) idle_ms / TimeUnit.MILLISECONDS_IN_SECONDS;
    }

    /** Detect if the device has been asleep using the difference between monotonic time and real time */
    public int64 pop_sleep_time () {
        int64 sleep_time;
        int64 now_real = TimeUnit.get_real_time_seconds ();
        int64 now_monotonic = TimeUnit.get_monotonic_time_seconds ();
        int64 real_time_delta = (int64) (now_real - this.last_real_time);
        int64 monotonic_time_delta = (int64) (now_monotonic - this.last_monotonic_time).abs ();

        if (this.last_real_time > 0 && this.last_monotonic_time > 0) {
            if (real_time_delta > monotonic_time_delta) {
                sleep_time = (int64) (real_time_delta - monotonic_time_delta);
            } else {
                sleep_time = real_time_delta;
            }
        } else {
            sleep_time = 0;
        }

        this.last_real_time = now_real;
        this.last_monotonic_time = now_monotonic;

        return sleep_time;
    }
}

}
