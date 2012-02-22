/**
 * A wrapper around GLib's Timeout functionality, specifically intended for
 * timeouts that persist. The TimeoutCB callback can be stopped and started at
 * any time, and it is provided with the time since its last call.
 */
public class CleverTimeout : Object {
	public delegate void TimeoutCB(CleverTimeout timeout, int delta_millisecs);
	
	private unowned TimeoutCB timeout_cb;
	private int frequency;
	private uint source_id;
	private int64 last_time;
	
	public CleverTimeout(TimeoutCB callback, int frequency) {
		this.timeout_cb = callback;
		this.frequency = frequency;
	}
	
	private bool timeout_wrapper() {
		int64 now = get_monotonic_time();
		int64 time_delta = now - this.last_time;
		this.last_time = now;
		
		int delta_millisecs = (int) (time_delta / 1000);
		this.timeout_cb(this, delta_millisecs);
		
		return true;
	}
	
	public void start() {
		if (this.is_running()) {
			Source.remove(this.source_id);
		}
		
		this.last_time = get_monotonic_time();
		
		this.source_id = Timeout.add_seconds(this.frequency, this.timeout_wrapper);
	}
	
	public void set_frequency(int frequency) {
		this.frequency = frequency;
		if (this.is_running()) {
			this.start();
		}
	}
	
	public void stop() {
		if (this.is_running()) {
			Source.remove(this.source_id);
			this.source_id = 0;
		}
	}
	
	public bool is_running() {
		return this.source_id > 0;
	}
}

