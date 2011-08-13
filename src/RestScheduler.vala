public class RestScheduler : Scheduler {
	/* TODO: test if we should manually add idle time every second,
	 * (which implicitly pauses when computer is in use),
	 * or use a real Timer
	 */
	private Timer time_idle;
	
	public RestScheduler () {
		/* 2400s = 40 minutes */
		/* 360s = 6 minutes */
		base(2400, 360);
		
		time_idle = new Timer();
	}
	
	/**
	 * Per-second timeout during rest break.
	 */
	private bool active_timeout () {
		/* TODO: Delay during active computer use */
		/* Update user interface (count every minute) */
		stdout.printf("%f spent idle", time_idle.elapsed());
		/* End break */
		if (time_idle.elapsed() >= duration) {
			end(false);
			return false;
		} else {
			return true;
		}
	}
	
	public override void activate () {
		base.activate();
		
		/* TODO: Start with a notification, then transition to a more visible interface after 60s */
		time_idle.start();
		Timeout.add_seconds (1, active_timeout);
	}
	
	public override void end (bool quiet = false) {
		base.end(quiet);
		
		/* display a happy notification if quiet == false */
	}
}

