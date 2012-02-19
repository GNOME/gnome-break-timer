/**
 * A countdown timer that counts seconds from a start time down to 0. Uses
 * "wall-clock" time instead of monotonic time, so it will count
 * regardless of system state.
 * The countdown can be paused, and its duration can be adjusted at any time
 * using penalty and bonus time.
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
		this.reset();
		this.continue();
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
			this.start_time = new DateTime.now_utc().to_unix();
			this.state = State.COUNTING;
		}
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
}

