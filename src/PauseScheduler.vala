public class PauseScheduler : Scheduler {
	public signal void active_update(int time_remaining);
	
	/* TODO: test if we should manually add idle time every second,
	 *(which implicitly pauses when computer is in use),
	 * or use a real Timer
	 */
	private Timer break_timer;
	
	public PauseScheduler() {
		/* 480s = 8 minutes */
		/* 20s duration */
		base(5, 3);
		
		this.break_timer = new Timer();
	}
	
	/**
	 * Per-second timeout during pause break.
	 */
	private bool active_timeout() {
		/* Delay during active computer use */
		int idle_time = (int)(Magic.get_idle_time() / 1000);
		if (idle_time < this.break_timer.elapsed()) {
			this.break_timer.start();
		}
		
		/* Update watchers (count every minute) */
		int time_elapsed_seconds = (int)Math.round(this.break_timer.elapsed());
		int time_remaining = (int)this.duration - time_elapsed_seconds;
		
		/* End break */
		if (time_remaining < 0) {
			this.end();
			return false;
		} else {
			this.active_update(time_remaining);
			return true;
		}
	}
	
	public override void activate() {
		base.activate();
		
		break_timer.start();
		Timeout.add_seconds(1, active_timeout);
	}
	
	public override void end() {
		base.end();
	}
}

