/**
 * Interface for a type of break. Each break type has a unique feedback
 * mechanism triggered by calling the begin method.
 */
public abstract class Scheduler : Object {
	public int interval {get; set;}
	/* TODO: duration should be private to child class */
	public int duration {get; set;}
	
	/** Called when a break starts to run */
	public signal void started();
	/** Called when a break is finished running */
	public signal void finished();
	
	public enum SchedulerState {
		WAITING,
		ACTIVE
	}
	private static SchedulerState state;
	
	protected Timer start_timer;
	
	public Scheduler(int interval, int duration) {
		this.interval = interval;
		this.duration = duration;
		
		start_timer = new Timer();
		
		/* FIXME: We need LCD of duration and interval so we catch idle>duration as well as start the rest on time */
		Timeout.add_seconds(duration, idle_timeout);
	}
	
	/**
	 * Periodically tests if it is time for a break
	 */
	protected bool idle_timeout() {
		int idle_time = (int)(Magic.get_idle_time() / 1000);
		
		/* Reset timer if the user takes a sufficiently long break */
		if (idle_time > duration) {
			stdout.printf("Resetting break timer for %s!\n", this.get_type().name());
			start_timer.start();
		}
		
		/* Start break if the user has been active for interval */
		if (start_timer.elapsed() >= interval && this.state == SchedulerState.WAITING) {
			stdout.printf("Activating break %s!\n", this.get_type().name());
			activate();
		}
		
		return true;
	}
	
	/**
	 * It is time for a break!
	 */
	public virtual void activate() {
		this.state = SchedulerState.ACTIVE;
		this.started();
	}
	
	public virtual void end() {
		this.state = SchedulerState.WAITING;
		this.finished();
	}
}

