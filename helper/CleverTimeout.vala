/**
 * A wrapper around GLib's Timeout functionality, specifically intended for
 * timeouts that persist. The TimeoutCB callback can be stopped and started at
 * any time, and it is provided with the time since its last call.
 */
public class CleverTimeout : Object {
	public delegate void TimeoutCB(CleverTimeout timeout, int time_delta);
	
	public signal void started();
	public signal void stopped();
	
	private unowned TimeoutCB timeout_cb;
	private uint source_id;
	private int64 last_time;
	
	public CleverTimeout(TimeoutCB callback) {
		this.timeout_cb = callback;
	}
	
	private bool timeout_wrapper() {
		int64 now = new DateTime.now_utc().to_unix();
		int64 time_delta = now - this.last_time;
		this.last_time = now;
		
		assert(this.is_running());
		this.timeout_cb(this, (int)time_delta);
		
		return true;
	}
	
	public void start(int interval) {
		if (this.is_running()) {
			Source.remove(this.source_id);
		}
		
		int64 now = new DateTime.now_utc().to_unix();
		this.last_time = now;
		
		this.source_id = Timeout.add_seconds(interval, this.timeout_wrapper);
		
		this.started();
	}
	
	public void stop() {
		if (this.is_running()) {
			Source.remove(this.source_id);
			this.source_id = 0;
		}
		
		this.stopped();
	}
	
	public bool is_running() {
		return this.source_id > 0;
	}
}

