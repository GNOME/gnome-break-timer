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
 * A type of break that times user activity. It activates after a particular
 * amount of uninterupted activity, and the break is finished after a
 * different amount of inactivity. The timer break has two timers: an interval
 * (time between breaks) and a duration (the length of each break). Once
 * started, the timer break continuously counts down for its interval, then
 * activates and counts down for its duration.
 */
public abstract class TimerBreakController : BreakController {
	/** The break is active and time_remaining has changed. */
	public signal void active_countdown_changed(int time_remaining);
	/** Fires continually, as long as the break is active and counting down. */
	public signal void counting(int time_counting);
	/** Fires as long as the break is active but is not counting down. */
	public signal void delayed(int time_delayed);

	// FIXME: GET RID OF THIS
	public signal void attention_demanded();
	
	public int interval {get; protected set;}
	public int duration {get; protected set;}
	
	protected Countdown interval_countdown;
	protected Countdown duration_countdown;
	protected PausableTimeout countdowns_timeout;

	protected int fuzzy_seconds = 0;

	private StatefulTimer counting_timer = new StatefulTimer();
	private StatefulTimer delayed_timer = new StatefulTimer();

	private Settings settings;

	private ActivityMonitor activity_monitor;
	
	public TimerBreakController(BreakType break_type, Settings settings, ActivityMonitor activity_monitor) {
		base(break_type);
		this.settings = settings;
		this.activity_monitor = activity_monitor;
		
		settings.bind("interval-seconds", this, "interval", SettingsBindFlags.GET);
		settings.bind("duration-seconds", this, "duration", SettingsBindFlags.GET);
		
		this.interval_countdown = new Countdown(this.interval);
		this.duration_countdown = new Countdown(this.duration);
		this.countdowns_timeout = new PausableTimeout(this.update_countdowns, 1);

		this.notify["interval"].connect((s, p) => {
			this.interval_countdown.set_base_duration(this.interval);
		});
		this.notify["duration"].connect((s, p) => {
			this.duration_countdown.set_base_duration(this.duration);
		});

		this.activity_monitor.detected_activity.connect(this.detected_activity_cb);
		this.activity_monitor.detected_idle.connect(this.detected_idle_cb);
		
		this.enabled.connect(this.enabled_cb);
		this.disabled.connect(this.disabled_cb);
		
		this.activated.connect(this.activated_cb);
		this.finished.connect(this.finished_cb);
	}
	
	private void enabled_cb() {
		this.interval_countdown.continue();
		this.activity_monitor.start();
		this.countdowns_timeout.start();
	}
	
	private void disabled_cb() {
		this.interval_countdown.pause();
		this.duration_countdown.pause();
		this.activity_monitor.stop();
		this.countdowns_timeout.stop();
	}
	
	private void activated_cb() {
		this.interval_countdown.pause();
		this.duration_countdown.continue();
	}
	
	private void finished_cb(BreakController.FinishedReason reason) {
		this.interval_countdown.reset();
		this.duration_countdown.pause();
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
	
	/**
	 * @return Idle time remaining until the break is satisfied.
	 */
	public int get_time_remaining() {
		return this.duration_countdown.get_time_remaining();
	}
	
	/**
	 * @return Total length of the break, taking into account extra time that
	 *         may have been added outside of the break's settings.
	 */
	public int get_current_duration() {
		return this.duration_countdown.get_duration();
	}

	private void detected_idle_cb(ActivityMonitor.UserActivity activity) {
		if (activity.time_since_active < this.fuzzy_seconds) {
			this.detected_activity_cb(activity);
			return;
		}

		if (activity.time_correction > 0) {
			this.duration_countdown.advance_time(activity.time_correction);
		}

		int time_counting;
		this.delayed_timer.stop();
		if (this.counting_timer.is_stopped()) {
			this.counting_timer.start();
			time_counting = activity.idle_time;
		} else {
			time_counting = (int)this.counting_timer.elapsed();
		}

		if (this.state == State.WAITING) {
			if (this.interval_countdown.get_time_elapsed() > 0) {
				this.duration_countdown.continue();
			}
			this.interval_countdown.pause();
		} else {
			this.duration_countdown.continue();
		}

		this.counting(time_counting);
	}

	private void detected_activity_cb(ActivityMonitor.UserActivity activity) {
		int time_delayed;

		this.counting_timer.stop();
		if (this.delayed_timer.is_stopped()) {
			this.delayed_timer.start();
			time_delayed = 0;
		} else {
			time_delayed = (int)this.delayed_timer.elapsed();
		}
		
		this.duration_countdown.pause();
		if (this.state == State.WAITING) {
			this.interval_countdown.continue();
		}

		this.delayed(time_delayed);
	}

	/**
	 * Checks if it is time to activate the break. The break will activate as
	 * soon as soon as interval_countdown reaches 0. The break's "warned"
	 * signal is fired when the break is close (within its set duration) to
	 * starting.
	 */
	private void update_countdowns(PausableTimeout timeout, int delta_millisecs) {
		if (this.duration_countdown.is_finished()) {
			this.duration_countdown.reset();
			this.finish();
		}

		if (this.state == State.WAITING) {
			if (this.starts_in() == 0) {
				this.activate();
			} else if (this.starts_in() <= this.duration) {
				this.warn();
			} else {
				this.unwarn();
			}
		} else if (this.state == State.ACTIVE) {
			this.active_countdown_changed(this.get_time_remaining());
		}
	}
}
