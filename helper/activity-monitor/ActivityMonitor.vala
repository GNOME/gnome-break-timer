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

namespace BreakTimer.Helper {

public class ActivityMonitor : Object {
	public enum ActivityType {
		SLEEP,
		LOCKED,
		NONE,
		INPUT,
		UNLOCK
	}

	public struct UserActivity {
		public ActivityType type;
		public int idle_time;
		public int time_since_active;
		public int time_correction;

		public Json.Object serialize () {
			Json.Object json_root = new Json.Object ();
			json_root.set_int_member ("type", (int)this.type);
			json_root.set_int_member ("idle_time", this.idle_time);
			json_root.set_int_member ("time_since_active", this.time_since_active);
			json_root.set_int_member ("time_correction", this.time_correction);
			return json_root;
		}

		public static UserActivity deserialize (ref Json.Object json_root) {
			return UserActivity () {
				type = (ActivityType)json_root.get_int_member ("type"),
				idle_time = (int)json_root.get_int_member ("idle_time"),
				time_since_active = (int)json_root.get_int_member ("time_since_active"),
				time_correction = (int)json_root.get_int_member ("time_correction")
			};
		}

		public bool is_active () {
			return this.type > ActivityType.NONE;
		}
	}

	public signal void detected_idle (UserActivity activity);
	public signal void detected_activity (UserActivity activity);
	
	private PausableTimeout poll_activity_timeout;
	private UserActivity last_activity;
	private int64 last_active_timestamp;

	private ISessionStatus session_status;
	private ActivityMonitorBackend backend;
	
	public ActivityMonitor (ISessionStatus session_status, ActivityMonitorBackend backend) {
		this.session_status = session_status;
		this.backend = backend;

		this.poll_activity_timeout = new PausableTimeout (this.poll_activity_cb, 1);
		session_status.unlocked.connect (this.unlocked_cb);
		
		this.last_activity = UserActivity ();
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
			this.last_active_timestamp = Util.get_real_time_seconds ();
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

		int sleep_time = backend.pop_sleep_time ();
		int idle_time = backend.get_idle_seconds ();
		int time_since_active = (int) (Util.get_real_time_seconds () - this.last_active_timestamp);

		// Order is important here: some types of activity (or inactivity)
		// happen at the same time, and are only reported once.

		if (sleep_time > idle_time + 5) {
			// Detected sleep time exceeds reported idle time by a healthy
			// margin. We use a magic number to filter out strange cases
			activity = UserActivity () {
				type = ActivityType.SLEEP,
				idle_time = 0,
				time_correction = sleep_time
			};
			GLib.debug ("Detected system sleep for %d seconds", sleep_time);
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

public abstract class ActivityMonitorBackend : Object {
	private int64 last_real_time = 0;
	private int64 last_monotonic_time = 0;

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

	protected abstract int time_since_last_event ();

	public int get_idle_seconds () {
		return this.time_since_last_event ();
	}

	/** Detect if the device has been asleep using the difference between monotonic time and real time */
	public int pop_sleep_time () {
		int sleep_time;
		int64 now_real = Util.get_real_time_seconds ();
		int64 now_monotonic = Util.get_monotonic_time_seconds ();
		int real_time_delta = (int) (now_real - this.last_real_time);
		int monotonic_time_delta = (int) (now_monotonic - this.last_monotonic_time).abs ();
		
		if (this.last_real_time > 0 && this.last_monotonic_time > 0) {
			if (real_time_delta > monotonic_time_delta) {
				sleep_time = (int) (real_time_delta - monotonic_time_delta);
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
