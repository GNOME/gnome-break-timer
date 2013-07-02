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
 * A type of timer break designed for longer durations. Satisfied when the user
 * is inactive for its entire duration, but allows the user to interact with
 * the computer while it counts down. The timer will stop until the user has
 * finished using the computer, and then it will start to count down again.
 */
public class RestBreakController : TimerBreakController {
	private ActivityMonitor activity_monitor;
	private Countdown reminder_countdown;
	
	public RestBreakController(BreakType break_type, Settings settings, IActivityMonitorBackend activity_monitor_backend) {
		base(break_type, settings, activity_monitor_backend);
		this.fuzzy_delay_seconds = 5;
		
		// Countdown for an extra reminder that a break is ongoing, if the
		// user is ignoring it
		this.reminder_countdown = new Countdown(this.interval / 4);
		this.notify["interval"].connect((s, p) => {
			this.reminder_countdown.set_base_duration(this.interval / 4);
		});
		this.activated.connect(() => {
			this.reminder_countdown.reset();
		});


		this.counting.connect(this.counting_cb);
		this.delayed.connect(this.delayed_cb);
	}

	private void counting_cb(int time_counting) {
		this.reminder_countdown.pause();
		if (time_counting > 60) {
			this.reminder_countdown.reset();
		}
	}

	private void delayed_cb(int time_delayed) {
		/* FIXME: After some delay ... */
		if (this.state == State.WAITING && time_delayed > 10) {
			this.duration_countdown.reset();
		}
		this.reminder_countdown.continue();

		if (this.reminder_countdown.is_finished()) {
			// Demand attention if the break is delayed for a long time
			int new_penalty = this.duration_countdown.get_penalty() + (this.duration/4);
			new_penalty = int.min(new_penalty, this.duration/2);
			this.duration_countdown.reset();
			this.duration_countdown.set_penalty(new_penalty);
			this.attention_demanded();
			this.reminder_countdown.start();
		}
	}
}

