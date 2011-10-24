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
	public RestBreak(FocusManager manager) {
		/* 2400s (40 minute) interval, 360s (6 minute) duration */
		base(manager, FocusPriority.HIGH, 90, 40);
	}
	
	protected override void idle_update_timeout() {
		/* break has been satisfied if user is idle for longer than break duration */
		int idle_time = (int)(Magic.get_idle_time() / 1000);
		
		if (idle_time > this.duration) {
			this.end();
		}
	}
	
	protected override void interval_timeout() {
		if (this.starts_in() <= this.duration) {
			this.warn();
		}
		base.interval_timeout();
	}
	
	protected override void break_update_timeout() {
		/* Delay during active computer use */
		int idle_time = (int)(Magic.get_idle_time() / 1000);
		
		// use time since last timeout; not arbitrary 2 seconds
		
		if (this.break_timer_is_paused()) {
			if (idle_time > 2) {
				this.unpause_break_timer();
			}
		} else {
			if (idle_time < 2) {
				this.pause_break_timer();
			}
		}
		
		base.break_update_timeout();
	}
}

