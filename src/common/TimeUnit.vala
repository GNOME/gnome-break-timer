/* TimeUnit.vala
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

namespace BreakTimer.Common {

public abstract class TimeUnit {
    public const int MILLISECONDS_IN_SECONDS = 1000;
    public const int MICROSECONDS_IN_SECONDS = 1000 * 1000;
    public const int MICROSECONDS_IN_MILLISECONDS = 1000;

    public static bool _do_override_time = false;
    public static int64 _override_real_time = 0;
    public static int64 _override_monotonic_time = 0;

    public inline static int64 get_real_time () {
        if (_do_override_time) {
            return _override_real_time;
        } else {
            return GLib.get_real_time ();
        }
    }

    public inline static int64 get_real_time_ms () {
        return get_real_time () / MILLISECONDS_IN_SECONDS;
    }

    public inline static int64 get_real_time_seconds () {
        return get_real_time () / MICROSECONDS_IN_SECONDS;
    }

    public inline static int64 get_monotonic_time () {
        if (_do_override_time) {
            return _override_monotonic_time;
        } else {
            return GLib.get_monotonic_time ();
        }
    }

    public inline static int64 get_monotonic_time_ms () {
        return get_monotonic_time () / MILLISECONDS_IN_SECONDS;
    }

    public inline static int64 get_monotonic_time_seconds () {
        return get_monotonic_time () / MICROSECONDS_IN_SECONDS;
    }
}

}
