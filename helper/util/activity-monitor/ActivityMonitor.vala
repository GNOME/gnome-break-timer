/*
 * This file is part of Brain Break.
 * 
 * Brain Break is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * Brain Break is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with Brain Break.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace Magic {
	[Import] private static extern void begin();
	[Import] private static extern uint32 get_idle_time();
	
	private static int get_idle_seconds() {
		return (int)(get_idle_time() / 1000);
	}
}

public class ActivityMonitor : Object {
	public struct UserActivity {
		public bool is_active;
		public int idle_time;
		private int64 last_active_time;
		
		public bool is_active_within(int seconds) {
			int64 now = get_real_time() / MICROSECONDS_IN_SECONDS;
			bool idle_within_seconds = now - this.last_active_time < seconds;
			return this.is_active || idle_within_seconds;
		}

	}
	
	private Timer activity_timer;
	private UserActivity last_activity;
	private int last_idle_time;
	
	public ActivityMonitor() {
		this.get_monotonic_time_delta();
		this.get_wall_time_delta();
		
		this.activity_timer = new Timer();
		this.last_activity = UserActivity();
		this.last_idle_time = 0;
	}
	
	public static void setup() {
		Magic.begin();
	}
	
	private const int MICROSECONDS_IN_SECONDS = 1000 * 1000;
	
	private int64 last_monotonic_time;
	/**
	 * @returns milliseconds in monotonic time since this function was last called
	 */
	private int get_monotonic_time_delta() {
		int64 now = get_monotonic_time();
		int64 time_delta = now - this.last_monotonic_time;
		this.last_monotonic_time = now;
		return (int) (time_delta / MICROSECONDS_IN_SECONDS);
	}
	
	private int64 last_wall_time;
	/**
	 * @returns milliseconds in real time since this function was last called
	 */
	private int get_wall_time_delta() {
		int64 now = get_real_time();
		int64 time_delta = now - this.last_wall_time;
		this.last_wall_time = now;
		return (int) (time_delta / MICROSECONDS_IN_SECONDS);
	}
	
	/**
	 * Determines user activity level since the last call to this function.
	 * Note that this will behave strangely if it is called more than once.
	 * @returns a struct with information about the user's current activity
	 */
	public UserActivity get_activity() {
		UserActivity activity = this.last_activity;
		
		// detect sleeping with difference between monotonic time and real time
		int monotonic_time_delta = this.get_monotonic_time_delta();
		int wall_time_delta = this.get_wall_time_delta();
		int sleep_time = (int)(wall_time_delta - monotonic_time_delta);
		
		activity.idle_time = int.max(sleep_time, Magic.get_idle_seconds());
		
		if (activity.idle_time > this.last_idle_time) {
			activity.is_active = false;
		} else {
			activity.is_active = this.activity_timer.elapsed() < 15;
			if (activity.is_active) {
				activity.last_active_time = get_real_time() / MICROSECONDS_IN_SECONDS;
			}
			this.activity_timer.start();
		}
		this.last_idle_time = activity.idle_time;
		
		this.last_activity = activity;
		
		return activity;
	}
}

