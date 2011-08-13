using Notify;

public class PauseScheduler : Scheduler {
	/* TODO: test if we should manually add idle time every second,
	 * (which implicitly pauses when computer is in use),
	 * or use a real Timer
	 */
	private Timer time_idle;
	
	public PauseScheduler () {
		/* 480s = 8 minutes */
		/* 20s */
		base(480, 20);
		
		time_idle = new Timer();
	}
	
	/**
	 * Per-second timeout during pause break.
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
		base.activate ();
		
		/* TODO: Start with a notification, then transition to a more visible interface after 30s */
		time_idle.start();
		Timeout.add_seconds (1, active_timeout);
		
		Notify.Notification notification = new Notification ("Micro break", "It's time for a short break.", null);
		notification.show();
	}
	
	public override void end (bool quiet = false) {
		base.end(quiet);
		
		/* display a happy notification if quiet == false */
	}
}

