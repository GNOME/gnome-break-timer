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

/* FIXME: This is getting to be a very deep class hierarchy with really awkward
          coupling.
          Move this to a mixin, or some helpful object that has nothing to do
          with Break, or something else. */

public abstract class ActivityTimerBreak : TimerBreak {
	public ActivityTimerBreak(FocusManager focus_manager, FocusPriority priority, Settings settings) {
		base(focus_manager, priority, settings);
	}
	
	protected override void waiting_timeout_cb(CleverTimeout timeout, int time_delta) {
		int idle_time = (int)(Magic.get_idle_time() / 1000);
		
		// if timeout hasn't been called for the entire break duration,
		// assume the best (system was sleeping?) and skip the break
		if (time_delta > this.duration) {
			idle_time = time_delta;
		}
		
		if (idle_time > time_delta) {
			this.interval_countdown.pause();
			
			if (! this.duration_countdown.is_counting()) {
				this.duration_countdown.continue();
				this.duration_countdown.add_bonus(idle_time);
			}
		} else {
			// user is actively using the computer
			this.interval_countdown.continue();
			this.duration_countdown.reset();
		}
		
		base.waiting_timeout_cb(timeout, time_delta);
	}
	
	/** Called when the user is being nice and not touching the computer during a break */
	protected abstract void active_nice();
	
	/** Called when the user is being naughty and playing with the computer during a break */
	protected abstract void active_naughty();
	
	protected override void active_timeout_cb(CleverTimeout timeout, int time_delta) {
		int idle_time = (int)(Magic.get_idle_time() / 1000);
		
		if (idle_time > time_delta*2) {
			this.active_nice();
		} else {
			this.active_naughty();
		}
		
		base.active_timeout_cb(timeout, time_delta);
	}
}

