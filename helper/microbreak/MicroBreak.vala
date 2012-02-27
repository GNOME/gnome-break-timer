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

/**
 * A type of timer break that should activate frequently and for short
 * durations. Satisfied when the user is inactive for its entire duration,
 * and when it is active it restarts its countdown whenever the user types
 * or moves the mouse.
 */
public class MicroBreak : TimerBreak {
	private ActivityMonitor activity_monitor;
	
	public MicroBreak() {
		Settings settings = new Settings("org.brainbreak.breaks.microbreak");
		
		base(settings);
		
		this.activity_monitor = new ActivityMonitor();
	}
	
	protected override void waiting_timeout_cb(CleverTimeout timeout, int delta_millisecs) {
		ActivityMonitor.UserActivity activity = this.activity_monitor.get_activity();
		
		if (activity.is_active) {
			this.interval_countdown.continue();
			this.duration_countdown.reset();
		} else {
			this.interval_countdown.pause();
			
			if (! this.duration_countdown.is_counting()) {
				this.duration_countdown.continue_from(-activity.idle_time);
			}
		}
		
		base.waiting_timeout_cb(timeout, delta_millisecs);
	}
	
	protected override void active_timeout_cb(CleverTimeout timeout, int delta_millisecs) {
		ActivityMonitor.UserActivity activity = this.activity_monitor.get_activity();
		
		if (activity.is_active) {
			this.duration_countdown.start();
		} else {
			this.duration_countdown.continue();
		}
		
		base.active_timeout_cb(timeout, delta_millisecs);
	}
}

