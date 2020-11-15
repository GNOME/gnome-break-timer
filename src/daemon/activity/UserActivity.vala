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

namespace BreakTimer.Daemon.Activity {

public enum ActivityType {
    SLEEP,
    LOCKED,
    NONE,
    INPUT,
    UNLOCK
}

public struct UserActivity {
    public ActivityType type;
    public int64 idle_time;
    public int64 time_since_active;
    public int64 time_correction;

    public Json.Object serialize () {
        Json.Object json_root = new Json.Object ();
        json_root.set_int_member ("type", (int) this.type);
        json_root.set_int_member ("idle_time", this.idle_time);
        json_root.set_int_member ("time_since_active", this.time_since_active);
        json_root.set_int_member ("time_correction", this.time_correction);
        return json_root;
    }

    public static UserActivity deserialize (ref Json.Object json_root) {
        return UserActivity () {
            type = (ActivityType) json_root.get_int_member ("type"),
            idle_time = json_root.get_int_member ("idle_time"),
            time_since_active = json_root.get_int_member ("time_since_active"),
            time_correction = json_root.get_int_member ("time_correction")
        };
    }

    public bool is_active () {
        return this.type > ActivityType.NONE;
    }
}

}
