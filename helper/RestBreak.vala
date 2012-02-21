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
public class RestBreak : ActivityTimerBreak {
	private Timer activity_timer; // time the user has been active during break
	
	public RestBreak(FocusManager focus_manager) {
		Settings settings = new Settings("org.brainbreak.breaks.restbreak");
		
		base(focus_manager, FocusPriority.HIGH, settings);
		
		this.activity_timer = new Timer();
	}
	
	protected override BreakView make_view() {
		BreakView break_view = new RestBreakView(this);
		return break_view;
	}
	
	protected override void active_nice() {
		this.duration_countdown.continue();
	}
	
	protected override void active_naughty() {
		// Pause countdown
		if (this.duration_countdown.is_counting()) {
			this.duration_countdown.pause();
			this.activity_timer.start();
		}
		
		// Demand attention if countdown is paused for a long time
		if (this.activity_timer.elapsed() >= this.interval/6) {
			if (this.duration_countdown.get_penalty() < this.duration) {
				this.duration_countdown.add_penalty(this.duration/4);
			}
			this.attention_demanded();
			this.activity_timer.start();
		}
	}
}

