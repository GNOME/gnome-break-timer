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
	private int64 active_timeout_last_time;
	
	private Timer interval_timer;
	
	private Timer active_timer;
	private bool active_timer_paused;
	private int duration_penalty;
	
	public TimerBreak(FocusManager focus_manager, FocusPriority priority, Settings settings) {
		int accurate_update_interval = 10;
		int test_interval = settings.get_int("interval-seconds");
		int test_duration = settings.get_int("duration-seconds");
		if (test_interval < accurate_update_interval) accurate_update_interval = test_interval;
		if (test_duration < accurate_update_interval) accurate_update_interval = test_duration;
		
		base(focus_manager, priority, settings, accurate_update_interval);
		
		settings.bind("interval-seconds", this, "interval", SettingsBindFlags.GET);
		settings.bind("duration-seconds", this, "duration", SettingsBindFlags.GET);
		
		this.interval_timer = new Timer();
		this.active_timer = new Timer();
		
		this.active_timeout_source_id = 0;
		this.active_timeout_last_time = 0;
		
		this.duration_penalty = 0;
		
		this.activated.connect(this.activated_cb);
		this.finished.connect(this.finished_cb);
	}
	
	protected override void start_waiting_timeout() {
		base.start_waiting_timeout();
		this.interval_timer.start();
	}
	protected override void stop_waiting_timeout() {
		base.stop_waiting_timeout();
		this.interval_timer.stop();
	}
	
	protected override void waiting_timeout(int time_delta) {
		/* Start break if the user has been active for interval */
		if (starts_in() <= 0) {
			this.activate();
		}
	}
	
	private void activated_cb() {
		this.reset_active_timer();
		this.active_timeout_source_id = Timeout.add_seconds(1, this.active_timeout_cb);
	}
	
	private void finished_cb() {
		this.pause_active_timer();
		if (this.active_timeout_source_id > 0) {
			Source.remove(this.active_timeout_source_id);
			this.active_timeout_source_id = 0;
			this.active_timeout_last_time = 0;
		}
		this.start_waiting_timeout();
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
		this.duration_penalty = 0;
		this.active_timer.start();
		this.active_timer_paused = false;
	}
	
	protected void add_penalty(int penalty) {
		this.duration_penalty += penalty;
	}
	
	protected void add_bonus(int bonus) {
		this.duration_penalty -= bonus;
	}
	
	protected int get_adjusted_duration() {
		int maximum_duration = this.duration * 2;
		int adjusted_duration = this.duration + this.duration_penalty;
		if (adjusted_duration > maximum_duration) {
			return maximum_duration;
		} else {
			return adjusted_duration;
		}
	}
	
	public int get_time_remaining() {
		int time_remaining = 0;
		if (this.state == Break.State.ACTIVE) {
			int time_elapsed_seconds = (int)Math.round(this.active_timer.elapsed());
			time_remaining = this.get_adjusted_duration() - time_elapsed_seconds;
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
	 * @param time_delta The time, in seconds, since the timeout was last run.
	 */
	protected virtual void active_timeout(int time_delta) {
		assert(this.state == Break.State.ACTIVE);
		
		int time_remaining = this.get_time_remaining();
		
		if (time_remaining < 1) {
			this.finish();
		} else {
			this.active_timer_update(time_remaining);
		}
	}
	private bool active_timeout_cb() {
		int64 now = new DateTime.now_utc().to_unix();
		int64 time_delta = 0;
		if (this.active_timeout_last_time > 0) {
			time_delta = now - this.active_timeout_last_time;
		}
		this.active_timeout_last_time = now;
		
		if (this.state == State.ACTIVE) {
			this.active_timeout((int)time_delta);
		}
		return true;
	}
}

