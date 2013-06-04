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
 * A type of timer break designed for longer durations. Satisfied when the user
 * is inactive for its entire duration, but allows the user to interact with
 * the computer while it counts down. The timer will stop until the user has
 * finished using the computer, and then it will start to count down again.
 */
public class RestBreakModel : TimerBreakModel {
	private ActivityMonitor activity_monitor;
	private Countdown reminder_countdown;
	
	public RestBreakModel(IActivityMonitorBackend activity_monitor_backend) {
		Settings settings = new Settings("org.brainbreak.breaks.restbreak");
		
		base(settings);
		
		this.activity_monitor = new ActivityMonitor(activity_monitor_backend);
		
		this.reminder_countdown = new Countdown(this.interval / 6);
		this.notify["interval"].connect((s, p) => {
			this.reminder_countdown.set_base_duration(this.interval / 6);
		});
		this.activated.connect(() => {
			this.reminder_countdown.reset();
		});
	}
	
	protected override void waiting_timeout_cb(CleverTimeout timeout, int delta_millisecs) {
		ActivityMonitor.UserActivity activity = this.activity_monitor.get_activity();
		
		if (activity.is_active) {
			this.interval_countdown.continue();
			if (this.duration_countdown.is_counting()) {
				// If the user is active, we stop counting down break duration
				this.duration_countdown.pause();
			} else {
				// If the user continues to be active, we reset that countdown
				this.duration_countdown.reset();
			}
		} else {
			if (this.interval_countdown.is_counting()) {
				this.interval_countdown.pause();
				
				if (! this.duration_countdown.is_counting()) {
					this.duration_countdown.continue_from(-activity.idle_time);
				}
			}
		}
		
		base.waiting_timeout_cb(timeout, delta_millisecs);
	}
	
	protected override void active_timeout_cb(CleverTimeout timeout, int delta_millisecs) {
		ActivityMonitor.UserActivity activity = this.activity_monitor.get_activity();
		
		if (activity.is_active_within(4)) {
			// Pause countdown
			if (this.duration_countdown.is_counting()) {
				this.duration_countdown.pause();
				this.reminder_countdown.continue();
			}
			
			// Demand attention if paused for a long time
			if (this.reminder_countdown.get_time_remaining() == 0) {
				if (this.duration_countdown.get_penalty() < this.duration) {
					this.duration_countdown.add_penalty(this.duration/4);
				}
				this.attention_demanded();
				this.reminder_countdown.start();
			}
		} else {
			if (! this.duration_countdown.is_counting()) {
				if (activity.idle_time > 15) { // don't give back the space around pausing
					this.duration_countdown.continue_from(-activity.idle_time);
				}
			}
			
			this.reminder_countdown.pause();
		}
		
		base.active_timeout_cb(timeout, delta_millisecs);
	}
}

