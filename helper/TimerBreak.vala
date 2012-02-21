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

/**
 * A type of break that is activated and finished according to timers.
 * The TimerBreak has two timers: an interval (time between breaks) and
 * a duration (the length of each break). Once started, the TimerBreak
 * continuously counts down for its interval, then activates and counts
 * down for its duration.
 */
public abstract class TimerBreak : Break {
	/**
	 * The break is active and time_remaining has changed.
	 */
	public signal void active_countdown_changed(int time_remaining);
	
	/**
	 * The break is active and the user is not paying attention to it.
	 * At this point, a time penalty may have been added.
	 */
	public signal void attention_demanded();
	
	public int interval {get; protected set;}
	public int duration {get; protected set;}
	
	protected Countdown interval_countdown;
	protected CleverTimeout waiting_timeout;
	
	protected Countdown duration_countdown;
	protected CleverTimeout active_timeout;
	
	public TimerBreak(FocusManager focus_manager, FocusPriority priority, Settings settings) {
		base(focus_manager, priority, settings);
		
		settings.bind("interval-seconds", this, "interval", SettingsBindFlags.GET);
		settings.bind("duration-seconds", this, "duration", SettingsBindFlags.GET);
		
		this.interval_countdown = new Countdown(this.interval);
		this.waiting_timeout = new CleverTimeout(this.waiting_timeout_cb, this.get_waiting_update_frequency());
		
		this.duration_countdown = new Countdown(this.duration);
		this.active_timeout = new CleverTimeout(this.active_timeout_cb, 1);
		
		this.notify["interval"].connect((s, p) => {
			this.interval_countdown.set_base_duration(this.interval);
			this.waiting_timeout.set_frequency(this.get_waiting_update_frequency());
		});
		this.notify["duration"].connect((s, p) => {
			this.duration_countdown.set_base_duration(this.duration);
			this.waiting_timeout.set_frequency(this.get_waiting_update_frequency());
		});
		
		this.enabled.connect(this.enabled_cb);
		this.disabled.connect(this.disabled_cb);
		
		this.activated.connect(this.activated_cb);
		this.finished.connect(this.finished_cb);
	}
	
	private int get_waiting_update_frequency() {
		int update_frequency = 5;
		update_frequency = int.min(update_frequency, this.interval / 2);
		update_frequency = int.min(update_frequency, this.duration / 2);
		return update_frequency;
	}
	
	private void enabled_cb() {
		this.waiting_timeout.start();
	}
	
	private void disabled_cb() {
		this.interval_countdown.pause();
		this.waiting_timeout.stop();
		
		this.duration_countdown.pause();
		this.active_timeout.stop();
	}
	
	private void activated_cb() {
		this.interval_countdown.pause();
		this.waiting_timeout.stop();
		this.active_timeout.start();
	}
	
	private void finished_cb() {
		this.interval_countdown.reset();
		this.waiting_timeout.start();
		
		this.duration_countdown.reset();
		this.active_timeout.stop();
	}
	
	/**
	 * @return Time until the next scheduled break, in seconds.
	 */
	public int starts_in() {
		return this.interval_countdown.get_time_remaining();
	}
	
	public int get_time_remaining() {
		return this.duration_countdown.get_time_remaining();
	}
	
	public int get_current_duration() {
		return this.duration_countdown.get_duration();
	}
	
	/**
	 * Runs frequently to test if it is time to activate the break.
	 * @param time_delta The time, in seconds, since the timeout was last run.
	 */
	protected virtual void waiting_timeout_cb(CleverTimeout timeout, int time_delta) {
		if (this.get_time_remaining() <= 0) {
			this.finish();
		}
		
		if (this.starts_in() <= 0) {
			this.activate();
		} else if (this.starts_in() <= duration) {
			this.warn();
		}
	}
	
	/**
	 * Per-second timeout during break.
	 * Aggressively checks if break is satisfied and updates watchers.
	 * @param time_delta The time, in seconds, since the timeout was last run.
	 */
	protected virtual void active_timeout_cb(CleverTimeout timeout, int time_delta) {
		if (this.state != Break.State.ACTIVE) {
			stderr.printf("TimerBreak active_timeout_cb called while Break.State != ACTIVE\n");
		}
		
		int time_remaining = this.get_time_remaining();
		
		if (time_remaining <= 0) {
			this.finish();
		}
		
		this.active_countdown_changed(time_remaining);
	}
}

