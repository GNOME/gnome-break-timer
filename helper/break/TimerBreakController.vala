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
 * The timer break has two timers: an interval (time between breaks) and
 * a duration (the length of each break). Once started, the timer break
 * continuously counts down for its interval, then activates and counts
 * down for its duration.
 */
public abstract class TimerBreakController : BreakController {
	/**
	 * The break is active and time_remaining has changed.
	 */
	public signal void active_countdown_changed(int time_remaining);
	
	/**
	 * The break may start soon, according to its schedule. The break
	 * view should subscribe to this to request early focus.
	 */
	public signal void warned();
	
	public signal void unwarned();
	
	/**
	 * The break is active and the user is not paying attention to it.
	 * At this point, a time penalty may have been added.
	 */
	public signal void attention_demanded();
	
	public int interval {get; protected set;}
	public int duration {get; protected set;}
	
	protected Countdown interval_countdown;
	protected PausableTimeout waiting_timeout;
	
	protected Countdown duration_countdown;
	protected PausableTimeout active_timeout;

	protected Settings settings;
	
	public TimerBreakController(BreakType break_type, Settings settings) {
		base(break_type);
		this.settings = settings;
		
		settings.bind("interval-seconds", this, "interval", SettingsBindFlags.GET);
		settings.bind("duration-seconds", this, "duration", SettingsBindFlags.GET);
		
		this.interval_countdown = new Countdown(this.interval);
		this.waiting_timeout = new PausableTimeout(this.waiting_timeout_cb, this.get_waiting_update_frequency());
		
		this.duration_countdown = new Countdown(this.duration);
		this.active_timeout = new PausableTimeout(this.active_timeout_cb, 1);
		
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
		this.interval_countdown.continue();
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
		
		this.duration_countdown.continue();
		this.active_timeout.start();
	}
	
	private void finished_cb() {
		this.interval_countdown.reset();
		this.waiting_timeout.start();
		
		this.duration_countdown.pause();
		this.active_timeout.stop();
	}
	
	bool is_warned;
	private void warn() {
		if (! is_warned) {
			is_warned = true;
			this.warned();
		}
	}
	private void unwarn() {
		if (is_warned) {
			is_warned = false;
			this.unwarned();
		}
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
	 * Runs frequently to test if it is time to activate the break. With the
	 * default implementation, it is activated as soon as interval_countdown
	 * reaches 0. In addition, the break's "warned" signal is fired when the
	 * break is close (within its set duration) to starting.
	 * @param timeout The PausableTimeout which is calling this function.
	 * @param delta_millisecs The time since the last time this function was called.
	 */
	protected virtual void waiting_timeout_cb(PausableTimeout timeout, int delta_millisecs) {
		if (this.starts_in() == 0) {
			this.activate();
		} else if (this.starts_in() <= duration) {
			this.warn();
		} else {
			this.unwarn();
		}
	}
	
	/**
	 * Per-second timeout that runs during a break.
	 * Aggressively checks if break is satisfied and updates watchers with the
	 * amount of time remaining.
	 * @param time_delta The time, in seconds, since the timeout was last run.
	 */
	protected virtual void active_timeout_cb(PausableTimeout timeout, int delta_millisecs) {
		if (this.state != BreakController.State.ACTIVE) {
			GLib.warning("TimerBreakController active_timeout_cb called while BreakController.State != ACTIVE");
		}
		
		if (this.duration_countdown.is_finished()) {
			this.duration_countdown.reset();
			this.finish();
		}
		
		this.active_countdown_changed(this.get_time_remaining());
	}

	/**
	 * Helper function for counting down to a break's start based on user
	 * activity data. While the user is using the computer, interval_countdown
	 * counts down normally. When the user is not using the computer, we
	 * instead count down duration_countdown, and if that reaches 0 we reset
	 * interval_countdown. This way, the user can take a break at any time.
	 * duration_countdown resets to the beginning when the user is active, but
	 * we provide some buffer because we can't be sure that the user activity
	 * information is entirely accurate.
	 *
	 * This function should be called from waiting_timeout_cb.
	 *
	 * @param activity User activity data from ActivityMonitor.get_activity
	 * @see ActivityMonitor
	 * @see waiting_timeout_cb
	 */
	protected void update_waiting_countdowns_for_activity(ActivityMonitor.UserActivity activity) {
		if (activity.is_active) {
			this.interval_countdown.continue();
			// Pause duration_countdown if the user is active, and reset the
			// countdown if that activity continues. This assumes that the
			// function is being called a particular, regular but reasonably
			// large interval.
			if (this.duration_countdown.is_counting()) {
				this.duration_countdown.pause();
			} else {
				this.duration_countdown.reset();
			}
		} else {
			if (this.interval_countdown.is_counting()) {
				this.interval_countdown.pause();
				if (! this.duration_countdown.is_counting()) {
					this.duration_countdown.continue_from(-activity.idle_time);
				}
			}
		}

		if (this.duration_countdown.is_finished()) {
			this.duration_countdown.reset();
			this.finish();
		}
	}

	/**
	 * Helper function for counting down to a break's finish based on user
	 * activity data. While the user is not using the computer,
	 * duration_countdown counts down normally. If the user is using the
	 * computer, we pause duration_countdown.
	 *
	 * This function should be called from active_timeout_cb.
	 *
	 * @param activity User activity data from ActivityMonitor.get_activity
	 * @param pause_penalty Extra time to pause duration_countdown if the user is using the computer
	 * @return true if the break is being delayed for user activity
	 * @see ActivityMonitor
	 * @see active_timeout_cb
	 */
	protected bool update_active_countdowns_for_activity(ActivityMonitor.UserActivity activity, int pause_penalty=0) {
		if (activity.is_active_within(pause_penalty)) {
			if (this.duration_countdown.is_counting()) {
				this.duration_countdown.pause();
			} else {
				// we say the break is being delayed if activity.is_active was
				// true for at least two consecutive calls to this function
				return true;
			}
		} else {
			if (! this.duration_countdown.is_counting()) {
				this.duration_countdown.continue_from(-activity.idle_time);
				if (activity.idle_time > 15) {
					// Update duration_countdown to catch up unexpected extra
					// idle time. This can happen if the user suspends the
					// computer during a break, for example.
					this.duration_countdown.continue_from(-activity.idle_time);
				} else {
					this.duration_countdown.continue();
				}
			}
		}
		return false;
	}
}

