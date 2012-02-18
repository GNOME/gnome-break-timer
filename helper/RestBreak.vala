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
public class RestBreak : TimerBreak {
	private Countdown paused_countdown; // time the break has been paused due to user activity
	
	public RestBreak(FocusManager focus_manager) {
		Settings settings = new Settings("org.brainbreak.breaks.restbreak");
		
		base(focus_manager, FocusPriority.HIGH, settings);
		
		this.paused_countdown = new Countdown();
	}
	
	protected override BreakView make_view() {
		BreakView break_view = new RestBreakView(this);
		return break_view;
	}
	
	protected override void waiting_timeout_cb(CleverTimeout timeout, int time_delta) {
		int idle_time = (int)(Magic.get_idle_time() / 1000);
		
		// detect system sleep and count time sleeping as idle_time
		if (time_delta > idle_time) {
			idle_time = time_delta;
		}
		
		if (idle_time > this.duration) {
			this.finish();
		} else if (this.starts_in() <= duration) {
			this.warn();
		}
		
		base.waiting_timeout_cb(timeout, time_delta);
	}
	
	protected override void active_timeout_cb(CleverTimeout timeout, int time_delta) {
		int idle_time = (int)(Magic.get_idle_time() / 1000);
		
		if (idle_time < time_delta*2) {
			// Pause during active computer use
			if (! this.duration_countdown.is_paused()) {
				this.duration_countdown.pause();
				this.paused_countdown.start(this.interval/6);
			}
			if (this.paused_countdown.get_time_remaining() <= 0) {
				if (this.duration_countdown.get_penalty() < this.duration) {
					this.duration_countdown.add_penalty(this.duration/4);
				}
				this.active_reminder();
				this.paused_countdown.start(this.interval/6);
			}
		} else {
			if (this.duration_countdown.is_paused()) {
				this.duration_countdown.continue();
			}
		}
		
		base.active_timeout_cb(timeout, time_delta);
	}
}

