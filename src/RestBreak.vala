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

public class RestBreak : Break {
	public signal void active_update(int time_remaining);
	
	private int duration;
	
	private Timer rest_break_timer;
	private bool rest_break_paused;
	
	public RestBreak(BreakManager manager) {
		/* 2400s (40 minute) interval */
		base(manager, BreakManager.FocusPriority.HIGH, 240);
		
		this.duration = 120; /* 360s (6 minute) duration */
		
		this.rest_break_timer = new Timer();
		Timeout.add_seconds(this.duration, this.idle_timeout);
		
		this.started.connect(this.started_cb);
	}
	
	private bool idle_timeout() {
		/* break has been satisfied if user is idle for longer than break duration */
		int idle_time = (int)(Magic.get_idle_time() / 1000);
		
		if (idle_time > this.duration) {
			this.break_satisfied();
		}
		
		return true;
	}
	
	private void pause_rest_break() {
		this.rest_break_timer.stop();
		this.rest_break_paused = true;
	}
	
	private void resume_rest_break() {
		this.rest_break_timer.continue();
		this.rest_break_paused = false;
	}
	
	/**
	 * Per-second timeout during rest break.
	 */
	private bool rest_break_timeout() {
		if (this.state != Break.State.ACTIVE) return false;
		
		/* Delay during active computer use */
		/* FIXME: timer wrongly pauses when system suspends */
		int idle_time = (int)(Magic.get_idle_time() / 1000);
		
		if (this.rest_break_paused) {
			if (idle_time > 1) {
				this.resume_rest_break();
			}
		} else {
			if (idle_time < 1) {
				this.pause_rest_break();
			}
		}
		
		int time_elapsed_seconds = (int)Math.round(this.rest_break_timer.elapsed());
		int time_remaining = (int)this.duration - time_elapsed_seconds;
		
		if (time_remaining < 1) {
			this.end();
			return false;
		} else {
			this.active_update(time_remaining);
			return true;
		}
	}
	
	private void started_cb() {
		this.rest_break_timer.start();
		this.rest_break_paused = false;
		Timeout.add_seconds(1, this.rest_break_timeout);
	}
}

