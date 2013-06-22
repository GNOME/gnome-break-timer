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
 * A countdown timer that counts seconds from a start time down to 0. Uses
 * "wall-clock" time instead of monotonic time, so it will count regardless
 * of system state. The countdown can be paused, and its duration can be
 * adjusted at any time using penalty and bonus time.
 */
public class Countdown : Object {
	private enum State {
		STOPPED,
		PAUSED,
		COUNTING
	}
	private State state;
	
	private int base_duration;
	
	private int64 start_time;
	private int stop_time_elapsed;
	private int penalty;
	
	public Countdown(int base_duration) {
		this.base_duration = base_duration;
		this.reset();
	}
	
	/**
	 * Stop the countdown and forget its current position.
	 * This is the same as calling Countdown.start(), except the countdown
	 * will not advance.
	 */
	public void reset() {
		this.penalty = 0;
		this.stop_time_elapsed = 0;
		this.state = State.STOPPED;
	}
	
	/**
	 * Start counting down from the time set with set_base_duration.
	 * This is the same as calling Countdown.stop() followed by
	 * Countdown.continue().
	 */
	public void start() {
		this.start_from(0);
	}
	
	/**
	 * Start counting with the time offset by the given number of seconds.
	 * Useful if the countdown should have started in the past.
	 * @param start_offset the number of seconds by which to offset the start time
	 */
	public void start_from(int start_offset) {
		this.reset();
		this.continue_from(start_offset);
	}
	
	/**
	 * Pause the countdown, keeping its current position.
	 */
	public void pause() {
		this.stop_time_elapsed = this.get_time_elapsed();
		this.state = State.PAUSED;
	}
	
	/**
	 * Start the countdown, continuing from the current position if
	 * possible.
	 */
	public void continue() {
		this.continue_from(0);
	}
	
	public void continue_from(int start_offset) {
		if (this.state < State.COUNTING) {
			int64 now = new DateTime.now_utc().to_unix();
			this.start_time = now + start_offset;
			this.state = State.COUNTING;
		}
	}

	public void set_penalty(int penalty) {
		this.penalty = penalty;
	}
	
	public void add_penalty(int penalty) {
		this.penalty += penalty;
	}
	
	public void add_bonus(int bonus) {
		this.penalty -= bonus;
	}
	
	public int get_penalty() {
		return this.penalty;
	}
	
	public bool is_counting() {
		return this.state == State.COUNTING;
	}
	
	public void set_base_duration(int base_duration) {
		this.base_duration = base_duration;
	}
	
	public int get_duration() {
		return int.max(0, this.base_duration + this.penalty);
	}
	
	private int get_time_elapsed() {
		int time_elapsed = this.stop_time_elapsed;
		
		if (this.state == State.COUNTING) {
			int64 now = new DateTime.now_utc().to_unix();
			time_elapsed += (int)(now - this.start_time);
		}
		
		return int.max(0, time_elapsed);
	}
	
	public int get_time_remaining() {
		int time_remaining = this.get_duration() - this.get_time_elapsed();
		return int.max(0, time_remaining);
	}

	public bool is_finished() {
		return this.get_time_remaining() == 0;
	}
}

