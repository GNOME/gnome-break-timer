/*
 * This file is part of GNOME Break Timer.
 * 
 * GNOME Break Timer is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * GNOME Break Timer is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with GNOME Break Timer.  If not, see <http://www.gnu.org/licenses/>.
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

	public string serialize() {
		int serialized_time_counted = (int)(Util.get_real_time_seconds() - this.start_time);
		serialized_time_counted = int.max(0, serialized_time_counted);

		return string.joinv(",", {
			((int)this.state).to_string(),
			this.start_time.to_string(),
			this.stop_time_elapsed.to_string(),
			this.penalty.to_string(),
			serialized_time_counted.to_string()
		});
	}

	public void deserialize(string data, bool persistent = false) {
		string[] data_parts = data.split(",");

		State serialized_state = (State)int.parse(data_parts[0]);

		switch (serialized_state) {
			case State.STOPPED:
				this.reset();
				break;
			case State.PAUSED:
				this.pause();
				break;
			case State.COUNTING:
				this.start();
				break;
		}

		this.stop_time_elapsed = int.parse(data_parts[2]);
		this.penalty = int.parse(data_parts[3]);

		if (persistent) {
			// Pretend the countdown has been running since it was serialized
			this.start_time = int64.parse(data_parts[1]);
		} else {
			// Resume where the timer left off
			if (serialized_state == State.COUNTING) {
				int serialized_time_counted = int.parse(data_parts[4]);
				this.advance_time(serialized_time_counted);
			}
		}
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
		if (this.state < State.COUNTING) {
			this.continue_from(0);
		}
	}
	
	public void continue_from(int start_offset) {
		if (this.state < State.COUNTING) {
			int64 now = Util.get_real_time_seconds();
			this.start_time = now + start_offset;
			this.state = State.COUNTING;
		}
	}

	public void cancel_pause() {
		if (this.state == State.PAUSED) {
			this.stop_time_elapsed = 0;
			this.state = State.COUNTING;
		}
	}

	public void advance_time(int seconds_off) {
		int64 now = Util.get_real_time_seconds();
		if (this.state == State.COUNTING) {
			this.start_time = now - seconds_off;
		} else {
			this.stop_time_elapsed += seconds_off;
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
	
	public int get_time_elapsed() {
		int time_elapsed = this.stop_time_elapsed;
		
		if (this.state == State.COUNTING) {
			int64 now = Util.get_real_time_seconds();
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

