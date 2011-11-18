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

public class MicroBreak : TimerBreak {
	public MicroBreak(FocusManager focus_manager) {
		Settings settings = new Settings("org.brainbreak.breaks.microbreak");
		
		base(focus_manager, FocusPriority.LOW, settings);
	}
	
	protected override BreakView make_view() {
		BreakView break_view = new MicroBreakView(this);
		return break_view;
	}
	
	protected override void waiting_timeout(int time_delta) {
		/* break has been satisfied if user is idle for longer than break duration */
		int idle_time = (int)(Magic.get_idle_time() / 1000);
		
		// detect system sleep and count time sleeping as idle_time
		if (time_delta > idle_time) {
			idle_time = time_delta;
		}
		
		if (idle_time > this.duration) {
			this.finish();
		}
		
		base.waiting_timeout(time_delta);
	}
	
	protected override void active_timeout(int time_delta) {
		// Reset countdown from active computer use
		int idle_time = (int)(Magic.get_idle_time() / 1000);
		if (idle_time < this.get_break_time()) {
			this.reset_active_timer();
		}
		
		// Detect system sleep and assume this counts as time away from the computer
		if (time_delta > 10) {
			this.add_bonus(time_delta);
		}
		
		base.active_timeout(time_delta);
	}
}

