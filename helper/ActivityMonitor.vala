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

class ActivityMonitor : Object {
	private Timer activity_timer;
	private CleverTimeout update_timeout;
	private int64 last_update_wall_time;
	
	private bool activity_detected;
	private int last_idle_time;
	
	ActivityMonitor() {
		this.activity_timer = new Timer();
		this.update_timeout = new CleverTimeout(this.update_timeout_cb, 3);
		this.last_update_wall_time = new DateTime.now_utc().to_unix();
		
		this.activity_detected = false;
		this.last_idle_time = 0;
		
		this.update_timeout.start();
	}
	
	public bool user_is_active() {
		return this.activity_detected;
	}
	
	public bool user_is_active_within(int seconds) {
		bool idle_within_seconds = this.get_idle_time() < seconds;
		return this.user_is_active() || idle_within_seconds;
	}
	
	public int get_idle_time() {
		return int.max(this.last_idle_time, Magic.get_idle_seconds());
	}
	
	private void update_timeout_cb(CleverTimeout timeout, int frequency) {
		int64 now = new DateTime.now_utc().to_unix();
		int64 wall_time_delta = now - this.last_update_wall_time;
		this.last_update_wall_time = now;
		
		// detect sleeping using difference between monotonic time and wall time
		int sleep_time = (int)(wall_time_delta - frequency);
		int idle_time = int.max(sleep_time, Magic.get_idle_seconds());
		
		if (idle_time > this.last_idle_time) {
			this.activity_detected = false;
		} else {
			this.activity_detected = this.activity_timer.elapsed() < 15;
			this.activity_timer.start();
		}
		this.last_idle_time = idle_time;
	}
	
	private static ActivityMonitor instance;
	public static ActivityMonitor get_instance() {
		// TODO: This should have some way to be cleaned up when unused
		if (instance == null) {
			instance = new ActivityMonitor();
		}
		return instance;
	}
}

