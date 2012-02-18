/**
 * A countdown timer that counts seconds from a start time down to 0. Uses
 * system time, so it will count regardless of system state.
 * The countdown can be paused, and its duration can be adjusted at any time
 * using penalty and bonus time.
 */
public class Countdown : Object {
	private int64 start_time;
	
	private bool paused;
	private int pause_time_elapsed;
	
	private int duration;
	private int penalty;
	
	public Countdown() {
	}
	
	public void start(int initial_duration) {
		this.start_time = new DateTime.now_utc().to_unix();
		this.duration = initial_duration;
		this.penalty = 0;
		this.pause_time_elapsed = 0;
		this.paused = false;
	}
	
	public void pause() {
		if (this.paused) return;
		
		this.pause_time_elapsed = this.get_time_elapsed();
		this.paused = true;
	}
	
	public void continue() {
		if (! this.paused) return;
		
		this.start_time = new DateTime.now_utc().to_unix();
		this.paused = false;
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
	
	public bool is_paused() {
		return this.paused;
	}
	
	public int get_duration() {
		return int.max(0, this.duration + this.penalty);
	}
	
	private int get_time_elapsed() {
		int time_elapsed = this.pause_time_elapsed;
		
		if (! this.paused) {
			int64 now = new DateTime.now_utc().to_unix();
			time_elapsed += (int)(now - this.start_time);
		}
		
		return int.max(0, time_elapsed);
	}
	
	public int get_time_remaining() {
		int time_remaining = this.get_duration() - this.get_time_elapsed();
		return time_remaining;
	}
}

