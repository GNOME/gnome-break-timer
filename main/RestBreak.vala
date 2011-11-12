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
	public RestBreak(FocusManager focus_manager) {
		Settings settings = new Settings("org.brainbreak.breaks.restbreak");
		
		base(focus_manager, FocusPriority.HIGH, settings);
	}
	
	protected override BreakView make_view() {
		BreakView break_view = new RestBreakView(this);
		return break_view;
	}
	
	protected override void update() {
		/* break has been satisfied if user is idle for longer than break duration */
		int idle_time = (int)(Magic.get_idle_time() / 1000);
		
		if (idle_time > this.duration) {
			this.finish();
		}
		
		if (this.starts_in() <= this.duration) {
			this.warn();
		}
		
		base.update();
	}
	
	protected override void active_timeout() {
		/* Delay during active computer use */
		int idle_time = (int)(Magic.get_idle_time() / 1000);
		
		// use time since last timeout; not arbitrary 2 seconds
		
		if (this.break_timer_is_paused()) {
			if (idle_time > 2) {
				this.resume_break_timer();
			}
		} else {
			if (idle_time < 2) {
				this.pause_break_timer();
			}
		}
		
		base.active_timeout();
	}
}

