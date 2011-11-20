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

public class RestBreak : TimerBreak {
	private Timer paused_timer; // time the break has been paused due to user activity
	
	public RestBreak(FocusManager focus_manager) {
		Settings settings = new Settings("org.brainbreak.breaks.restbreak");
		
		base(focus_manager, FocusPriority.HIGH, settings);
		
		this.paused_timer = new Timer();
		this.paused_timer.stop();
		
		this.activated.connect(this.activated_cb);
		this.finished.connect(this.finished_cb);
	}
	
	private void activated_cb() {
		this.paused_timer.start();
		this.paused_timer.stop();
	}
	
	private void finished_cb() {
		this.paused_timer.stop();
	}
	
	protected override BreakView make_view() {
		BreakView break_view = new RestBreakView(this);
		return break_view;
	}
	
	protected override void waiting_timeout(int time_delta) {
		int idle_time = (int)(Magic.get_idle_time() / 1000);
		
		// detect system sleep and count time sleeping as idle_time
		if (time_delta > idle_time) {
			idle_time = time_delta;
		}
		
		if (idle_time > this.get_adjusted_duration()) {
			this.finish();
		} else if (this.starts_in() <= this.get_adjusted_duration()) {
			this.warn();
		}
		
		base.waiting_timeout(time_delta);
	}
	
	protected override void active_timeout(int time_delta) {
		// Delay during active computer use
		int idle_time = (int)(Magic.get_idle_time() / 1000);
		
		if (idle_time > 4) {
			if (this.active_timer_is_paused()) {
				this.resume_active_timer();
				this.paused_timer.stop();
			}
		} else {
			if (! this.active_timer_is_paused()) {
				this.pause_active_timer();
				this.paused_timer.continue();
			}
			
			if (this.paused_timer.elapsed() > this.interval/6) {
				this.add_penalty(this.duration/4);
				this.active_reminder();
				this.paused_timer.start();
			}
		}
		
		// Detect system sleep and assume this counts as time away from the computer
		if (time_delta > 10) {
			this.add_bonus(time_delta);
		}
		
		base.active_timeout(time_delta);
	}
}

