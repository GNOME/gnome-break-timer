/* ActivityMonitor.vala
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

public class ActivityMonitor : GLib.Object, GLib.Initable {
    private PausableTimeout poll_activity_timeout;
    private UserActivity last_activity;
    private int64 last_active_timestamp;

    private ISessionStatus session_status;
    private ActivityMonitorBackend backend;

    public signal void detected_idle (UserActivity activity);
    public signal void detected_activity (UserActivity activity);

    public const int SLEEP_TIME_CORRECTION_THRESHOLD = 10;

    public ActivityMonitor (ISessionStatus session_status, ActivityMonitorBackend backend) {
        this.session_status = session_status;
        this.backend = backend;

        this.poll_activity_timeout = new PausableTimeout (this.poll_activity_cb, 1);
        session_status.unlocked.connect (this.unlocked_cb);

        this.last_activity = UserActivity ();
    }

    public bool init (GLib.Cancellable? cancellable) throws GLib.Error {
        return true;
    }

    public Json.Object serialize () {
        Json.Object json_root = new Json.Object ();
        json_root.set_int_member ("last_active_timestamp", this.last_active_timestamp);
        json_root.set_object_member ("last_activity", this.last_activity.serialize ());
        return json_root;
    }

    public void deserialize (ref Json.Object json_root) {
        this.last_active_timestamp = json_root.get_int_member ("last_active_timestamp");
        Json.Object? last_activity_json = json_root.get_object_member ("last_activity");
        this.last_activity = UserActivity.deserialize (ref last_activity_json);
    }

    public void start () {
        this.poll_activity_timeout.start ();
    }

    public void stop () {
        this.poll_activity_timeout.stop ();
    }

    public void poll_activity () {
        UserActivity activity = this.collect_activity ();
        GLib.debug ("Detected activity: %s", activity.to_string ());
        this.add_activity (activity);
    }

    private void poll_activity_cb (PausableTimeout timeout, int delta_millisecs) {
        this.poll_activity ();
    }

    private void unlocked_cb () {
        UserActivity activity = UserActivity () {
            type = ActivityType.UNLOCK,
            idle_time = 0,
            time_correction = 0
        };
        this.add_activity (activity);
    }

    private void add_activity (UserActivity activity) {
        this.last_activity = activity;
        if (activity.is_active ()) {
            this.last_active_timestamp = TimeUnit.get_real_time_seconds ();
            this.detected_activity (activity);
        } else {
            this.detected_idle (activity);
        }
    }

    /**
     * Determines user activity level since the last call to this function.
     * This function is ugly and stateful, so it shouldn't be called from
     * more than one place.
     * @returns a struct with information about the user's current activity
     */
    private UserActivity collect_activity () {
        UserActivity activity;

        int64 sleep_time = backend.pop_sleep_time ();
        int64 idle_time = backend.get_idle_seconds ();
        int64 time_since_active = (int64) (TimeUnit.get_real_time_seconds () - this.last_active_timestamp);

        // Order is important here: some types of activity (or inactivity)
        // happen at the same time, and are only reported once.

        if (sleep_time > SLEEP_TIME_CORRECTION_THRESHOLD) {
            // Detected sleep time is above a reasonable threshold that we will
            // count it as idle time.
            activity = UserActivity () {
                type = ActivityType.SLEEP,
                idle_time = 0,
                time_correction = sleep_time
            };
        } else if (this.session_status.is_locked ()) {
            activity = UserActivity () {
                type = ActivityType.LOCKED,
                idle_time = idle_time,
                time_correction = 0
            };
        } else if (idle_time == 0 || idle_time < this.last_activity.idle_time) {
            activity = UserActivity () {
                type = ActivityType.INPUT,
                idle_time = idle_time,
                time_correction = 0
            };
        } else {
            activity = UserActivity () {
                type = ActivityType.NONE,
                idle_time = idle_time,
                time_correction = 0
            };
        }

        activity.time_since_active = time_since_active;

        /*
        // Catch up idle time missed due to infrequent updates.
        // Should be unnecessary now that we just update every second.
        if (activity.idle_time > this.fuzzy_seconds && this.fuzzy_seconds > 0) {
            activity.time_correction = activity.idle_time - this.fuzzy_seconds;
        }
        */

        return activity;
    }
}

}
