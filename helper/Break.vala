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
 * Base class for a type of break.
 * A break inherently activates according to a set time interval, but the
 * mechanism for finishing a break is unique to each implementation.
 */
public abstract class Break : Object, Focusable {
	private FocusManager focus_manager;
	
	public Settings settings {get; private set;}
	
	public bool enabled {get; set; default=false;}
	
	public enum State {
		WAITING,
		WARN,
		ACTIVE,
		STOPPED
	}
	public State state {get; private set;}
	
	/**
	 * The break has been stopped. Its timers have been stopped and
	 * it will not do anything until it is started again.
	 * If the break has already been stopped and you call stop(),
	 * this signal will not be emitted.
	 */
	public signal void stopped();
	
	/**
	 * The break has been started. It will monitor user activity and
	 * emit activated() or finished() signals when appropriate.
	 * If the break has already been started and you call start(),
	 * this signal will not be emitted.
	 */
	public signal void started();
	
	/**
	 * The break has been activated and is now counting down
	 * aggressively until it is satisfied. This is the point where
	 * the UI should block the screen and notify the user to take a
	 * break.
	 */
	public signal void activated();
	
	/**
	 * The break has been satisfied. This can happen at any point.
	 * while the break is waiting or after it has been activiated.
	 */
	public signal void finished();
	
	private BreakView break_view;
	
	private int waiting_update_interval;
	private uint waiting_update_source_id;
	
	
	public Break(FocusManager focus_manager, FocusPriority priority, Settings settings, int waiting_update_interval) {
		this.focus_manager = focus_manager;
		this.priority = priority;
		this.settings = settings;
		this.waiting_update_interval = waiting_update_interval;
		
		this.state = State.STOPPED;
		
		this.waiting_update_source_id = 0;
		
		this.break_view = this.make_view();
		
		settings.changed.connect(() => {
			// restart the break with new settings, if necessary
			if (this.is_started()) this.start();
		});
		
		this.notify["enabled"].connect(() => {
			if (this.enabled) {
				this.start();
			} else {
				this.stop();
			}
		});
	}
	
	protected abstract BreakView make_view();
	
	protected virtual void start() {
		bool was_started = this.is_started();
		
		this.finish();
		this.state = State.WAITING;
		this.start_waiting_update_timeout();
		if (!was_started) this.started();
	}
	protected virtual void stop() {
		bool was_started = this.is_started();
		
		this.finish();
		this.stop_waiting_update_timeout();
		this.state = State.STOPPED;
		if (was_started) this.stopped();
	}
	
	protected virtual void start_waiting_update_timeout() {
		this.stop_waiting_update_timeout();
		this.waiting_update_source_id = Timeout.add_seconds(this.waiting_update_interval, this.waiting_update_timeout_cb);
	}
	protected virtual void stop_waiting_update_timeout() {
		if (this.waiting_update_source_id > 0) {
			Source.remove(this.waiting_update_source_id);
			this.waiting_update_source_id = 0;
		}
	}
	
	/**
	 * Runs frequently to test if it is time to activate the break.
	 */
	protected abstract void waiting_update();
	private bool waiting_update_timeout_cb() {
		this.waiting_update();
		return true;
	}
	
	/**
	 * Break is enabled and periodically updating in the background.
	 */
	public bool is_started() {
		return this.state != State.STOPPED;
	}
	
	/**
	 * Break has been triggered and is counting down to completion.
	 */
	public bool is_active() {
		return this.state == State.ACTIVE;
	}
	
	/**
	 * A scheduled break is coming up.
	 * This will prevent lower priority breaks from gaining focus.
	 */
	public void warn() {
		if (this.state < State.WARN) {
			this.state = State.WARN;
			this.focus_manager.set_hold(this);
		}
	}
	
	/**
	 * Start a break.
	 * This is usually triggered automatically, but may be triggered
	 * externally as well.
	 */
	public void activate() {
		if (this.state < State.ACTIVE) {
			this.state = State.ACTIVE;
			this.focus_manager.request_focus(this);
		}
	}
	
	/**
	 * Break's requirements have been satisfied. Start counting from
	 * the beginning again.
	 */
	public void finish() {
		this.state = State.WAITING;
		this.start_waiting_update_timeout();
		this.focus_manager.release_focus(this);
	}
	
	/**
	 * @return the BreakView for this break
	 */
	public BreakView get_view() {
		return this.break_view;
	}
	
	
	
	/***** Focusable interface ******/
	
	private FocusPriority priority;
	private bool focused;
	
	public FocusPriority get_priority() {
		return this.priority;
	}
	
	public bool is_focused() {
		return this.focused;
	}
	
	public void start_focus() {
		this.focused = true;
		this.activated();
	}
	
	public void stop_focus(bool replaced) {
		this.focused = false;
		this.finished();
	}
}

