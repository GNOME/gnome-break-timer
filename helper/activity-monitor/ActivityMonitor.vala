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

public interface IActivityMonitorBackend : Object {
	public abstract int get_idle_seconds();
}

public class ActivityMonitor : Object {
	public struct UserActivity {
		public bool is_active;
		public int idle_time;
		public bool was_sleeping;
		private int64 last_active_time;
		
		public bool is_active_within(int seconds) {
			int64 now = get_real_time_seconds();
			int seconds_since_active = (int) (now - this.last_active_time);
			return this.is_active || seconds_since_active < seconds;
		}
	}
	
	private Timer activity_timer;
	private UserActivity last_activity;
	private int last_idle_time;
	
	private IActivityMonitorBackend backend;

	private const int MICROSECONDS_IN_SECONDS = 1000 * 1000;
	
	public ActivityMonitor(IActivityMonitorBackend backend) {
		this.backend = backend;
		
		this.activity_timer = new Timer();
		this.last_activity = UserActivity();
		this.last_idle_time = 0;
	}

	private static int64 get_real_time_seconds() {
		return (GLib.get_real_time() / MICROSECONDS_IN_SECONDS);
	}

	private static int64 get_monotonic_time_seconds() {
		return (GLib.get_monotonic_time() / MICROSECONDS_IN_SECONDS);
	}

	private int64 last_real_time = get_real_time_seconds();
	private int64 last_monotonic_time = get_monotonic_time_seconds();
	private int pop_sleep_time() {
		// Detect if the device has been asleep using the difference between
		// monotonic time and real time.
		// TODO: Should we detect when the process is suspended, too?
		int64 now_real = get_real_time_seconds();
		int64 now_monotonic = get_monotonic_time_seconds();
		int real_time_delta = (int) (now_real - this.last_real_time);
		int monotonic_time_delta = (int) (now_monotonic - this.last_monotonic_time);
		int sleep_time = (int)(real_time_delta - monotonic_time_delta);
		this.last_real_time = now_real;
		this.last_monotonic_time = now_monotonic;
		return sleep_time;
	}
	
	/**
	 * Determines user activity level since the last call to this function.
	 * Note that this will behave strangely if it is called more than once.
	 * @returns a struct with information about the user's current activity
	 */
	public UserActivity get_activity() {
		UserActivity activity = this.last_activity;
		int sleep_time = this.pop_sleep_time();
		int idle_seconds = backend.get_idle_seconds();

		if (sleep_time > idle_seconds + 15) {
			// Detected sleep time exceeds reported idle time by a healthy
			// margin. We use a magic number to filter out rounding error
			// converting from microseconds to seconds.
			activity.idle_time = sleep_time;
			activity.was_sleeping = true;
			activity.is_active = false;
			GLib.debug("Detected system sleep for %d seconds", sleep_time);
		} else {
			activity.idle_time = idle_seconds;
			activity.was_sleeping = false;
			activity.is_active = activity.idle_time <= this.last_idle_time;
		}

		if (activity.is_active) activity.last_active_time = get_real_time_seconds();

		this.last_idle_time = activity.idle_time;
		this.last_activity = activity;
		
		return activity;
	}
}

