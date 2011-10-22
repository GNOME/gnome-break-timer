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

public abstract class TimerBreak : Break {
	public signal void break_update(int time_remaining);
	
	protected int duration {get; private set;}
	
	private uint idle_update_source_id;
	private uint break_update_source_id;
	
	private Timer break_timer;
	private bool break_timer_paused;
	
	public TimerBreak(BreakManager manager, BreakManager.FocusPriority priority, int interval, int duration) {
		base(manager, priority, interval);
		
		this.duration = duration;
		
		this.break_timer = new Timer();
		
		this.idle_update_source_id = Timeout.add_seconds(this.duration, this.idle_update_timeout_cb);
		this.break_update_source_id = 0;
		
		this.started.connect(this.started_cb);
		this.finished.connect(this.finished_cb);
	}
	
	private void started_cb() {
		this.reset_break_timer();
		this.break_update_source_id = Timeout.add_seconds(1, this.break_update_timeout_cb);
	}
	
	private void finished_cb() {
		this.pause_break_timer();
		if (this.break_update_source_id > 0) {
			Source.remove(this.break_update_source_id);
			this.break_update_source_id = 0;
		}
	}
	
	protected int get_break_time() {
		return (int)Math.round(this.break_timer.elapsed());
	}
	
	protected bool break_timer_is_paused() {
		return this.break_timer_paused;
	}
	
	protected void pause_break_timer() {
		this.break_timer.stop();
		this.break_timer_paused = true;
	}
	
	protected void unpause_break_timer() {
		this.break_timer.continue();
		this.break_timer_paused = false;
	}
	
	protected void reset_break_timer() {
		this.break_timer.start();
		this.break_timer_paused = false;
	}
	
	/**
	 * @return Time remaining in break, in seconds, or 0 if break has been satisfied.
	 */
	public int get_time_remaining() {
		int time_remaining = 0;
		if (this.state == Break.State.ACTIVE) {
			int time_elapsed_seconds = (int)Math.round(this.break_timer.elapsed());
			time_remaining = (int)this.duration - time_elapsed_seconds;
		}
		return time_remaining;
	}
	
	/**
	 * Timeout between breaks.
	 * Runs occasionally to test if break has been satisfied.
	 */
	protected abstract void idle_update_timeout();
	
	private bool idle_update_timeout_cb() {
		this.idle_update_timeout();
		return true;
	}
	
	/**
	 * Per-second timeout during break.
	 * Aggressively checks if break is satisfied and updates watchers.
	 */
	protected virtual void break_update_timeout() {
		stdout.printf("TimerBreak.break_update_timeout\n");
		if (this.state != Break.State.ACTIVE) stdout.printf("WTF THIS SHOULDN'T HAPPEN\n");
		
		/* FIXME: timer wrongly pauses when system suspends */
		
		int time_remaining = this.get_time_remaining();
		
		if (time_remaining < 1) {
			this.end();
		} else {
			this.break_update(time_remaining);
		}
	}
	
	private bool break_update_timeout_cb() {
		this.break_update_timeout();
		return true;
	}
}

