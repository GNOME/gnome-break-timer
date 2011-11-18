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
	/**
	 * The break is active and time_remaining has changed.
	 */
	public signal void active_timer_update(int time_remaining);
	
	/**
	 * The break is active and the user is not paying attention to it.
	 * At this point, a time penalty may have been added.
	 */
	public signal void active_reminder();
	
	public int interval {get; protected set;}
	public int duration {get; protected set;}
	
	private uint active_timeout_source_id;
	
	private Timer interval_timer;
	
	private Timer active_timer;
	private bool active_timer_paused;
	private int current_duration;
	private int64 last_active_time;
	
	public TimerBreak(FocusManager focus_manager, FocusPriority priority, Settings settings) {
		int accurate_update_interval = settings.get_int("interval-seconds");
		if (accurate_update_interval > 10) accurate_update_interval = 10;
		
		base(focus_manager, priority, settings, accurate_update_interval);
		
		settings.bind("interval-seconds", this, "interval", SettingsBindFlags.GET);
		settings.bind("duration-seconds", this, "duration", SettingsBindFlags.GET);
		
		this.interval_timer = new Timer();
		this.active_timer = new Timer();
		
		this.active_timeout_source_id = 0;
		
		this.activated.connect(this.activated_cb);
		this.finished.connect(this.finished_cb);
	}
	
	protected override void start_waiting_update_timeout() {
		base.start_waiting_update_timeout();
		this.interval_timer.start();
	}
	protected override void stop_waiting_update_timeout() {
		base.stop_waiting_update_timeout();
		this.interval_timer.stop();
	}
	
	protected override void waiting_update() {
		/* Start break if the user has been active for interval */
		if (starts_in() <= 0) {
			this.activate();
		}
	}
	
	private void activated_cb() {
		this.reset_active_timer();
		this.last_active_time = new DateTime.now_utc().to_unix();
		this.active_timeout_source_id = Timeout.add_seconds(1, this.active_timeout_cb);
	}
	
	private void finished_cb() {
		this.pause_active_timer();
		if (this.active_timeout_source_id > 0) {
			Source.remove(this.active_timeout_source_id);
			this.active_timeout_source_id = 0;
		}
		this.start_waiting_update_timeout();
	}
	
	protected int get_break_time() {
		return (int)Math.round(this.active_timer.elapsed());
	}
	
	protected bool active_timer_is_paused() {
		return this.active_timer_paused;
	}
	
	protected void pause_active_timer() {
		this.active_timer.stop();
		this.active_timer_paused = true;
	}
	
	protected void resume_active_timer() {
		this.active_timer.continue();
		this.active_timer_paused = false;
	}
	
	protected void reset_active_timer() {
		this.current_duration = this.duration;
		this.active_timer.start();
		this.active_timer_paused = false;
	}
	
	protected void add_penalty(int penalty) {
		int maximum_duration = this.duration * 2;
		if (this.current_duration + penalty < maximum_duration) {
			this.current_duration += penalty;
		} else {
			this.current_duration = maximum_duration;
		}
	}
	
	protected void add_bonus(int bonus) {
		this.current_duration -= bonus;
	}
	
	public int get_time_remaining() {
		int time_remaining = 0;
		if (this.state == Break.State.ACTIVE) {
			int time_elapsed_seconds = (int)Math.round(this.active_timer.elapsed());
			time_remaining = this.current_duration - time_elapsed_seconds;
		}
		return time_remaining;
	}
	
	/**
	 * @return Time until the next scheduled break, in seconds.
	 */
	public int starts_in() {
		return this.interval - (int)this.interval_timer.elapsed();
	}
	
	/**
	 * Per-second timeout during break.
	 * Aggressively checks if break is satisfied and updates watchers.
	 */
	protected virtual void active_timeout() {
		assert(this.state == Break.State.ACTIVE);
		
		int64 now = new DateTime.now_utc().to_unix();
		int64 time_difference = now - this.last_active_time;
		if (time_difference > 10) {
			// Timeout hasn't run for 10 seconds!
			// We'll assume this is due to system sleep (or
			// inconcievably heavy load) and adjust current_duration
			// to account for the user not touching the computer
			// during this time.
			this.add_bonus((int)time_difference);
		}
		this.last_active_time = now;
		
		int time_remaining = this.get_time_remaining();
		
		if (time_remaining < 1) {
			this.finish();
		} else {
			this.active_timer_update(time_remaining);
		}
	}
	private bool active_timeout_cb() {
		this.active_timeout();
		return true;
	}
}

