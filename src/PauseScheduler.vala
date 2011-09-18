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

public class PauseScheduler : Scheduler {
	public signal void active_update(int time_remaining);
	
	/* TODO: test if we should manually add idle time every second,
	 *(which implicitly pauses when computer is in use),
	 * or use a real Timer
	 */
	private Timer break_timer;
	
	public PauseScheduler() {
		/* 480s = 8 minutes */
		/* 20s duration */
		base(5, 3);
		
		this.break_timer = new Timer();
	}
	
	/**
	 * Per-second timeout during pause break.
	 */
	private bool active_timeout() {
		/* Delay during active computer use */
		int idle_time = (int)(Magic.get_idle_time() / 1000);
		if (idle_time < this.break_timer.elapsed()) {
			this.break_timer.start();
		}
		
		/* Update watchers (count every minute) */
		int time_elapsed_seconds = (int)Math.round(this.break_timer.elapsed());
		int time_remaining = (int)this.duration - time_elapsed_seconds;
		
		/* End break */
		if (time_remaining < 0) {
			this.end();
			return false;
		} else {
			this.active_update(time_remaining);
			return true;
		}
	}
	
	public override void activate() {
		base.activate();
		
		break_timer.start();
		Timeout.add_seconds(1, active_timeout);
	}
	
	public override void end() {
		base.end();
	}
}

