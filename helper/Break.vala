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
 * A break can be started or stopped, and once started it will be activated
 * and finished either manually or autonomously based on things like user
 * activity. The mechanism for activating a break and for satisfying it is
 * unique to each implementation.
 * As well as the fundamentals of break state, this base class provides a
 * timeout that is run at a set interval to determine when it is time for a
 * break, and it refers to FocusManager to make sure it is the only break
 * in focus at a given time.
 */
public abstract class Break : Object, Focusable {
	private FocusManager focus_manager;
	
	public Settings settings {get; private set;}
	
	public enum State {
		WAITING,
		WARN,
		ACTIVE,
		DISABLED
	}
	public State state {get; private set;}
	
	/**
	 * The break has been enabled. It will monitor user activity and
	 * emit activated() or finished() signals until it is disabled.
	 */
	public signal void enabled();
	
	/**
	 * The break has been disabled. Its timers have been stopped and
	 * it will not do anything until it is enabled again.
	 */
	public signal void disabled();
	
	/**
	 * The break has been activated and is now counting down
	 * aggressively until it is satisfied.
	 */
	public signal void activated();
	
	/**
	 * The break has been satisfied. This can happen at any time, including
	 * while the break is waiting or after it has been activiated.
	 */
	public signal void finished();
	
	public signal void focus_started();
	
	public signal void focus_ended();
	
	private BreakView break_view;
	
	public Break(FocusManager focus_manager, FocusPriority priority, Settings settings) {
		this.focus_manager = focus_manager;
		this.priority = priority;
		this.settings = settings;
		
		this.state = State.DISABLED;
		
		this.break_view = this.make_view();
	}
	
	protected abstract BreakView make_view();
	
	/**
	 * Set whether the break is enabled or disabled. If it is enabled,
	 * it will periodically update in the background, and if it is
	 * disabled it will do nothing (and consume fewer resources).
	 * This will also emit the enabled() or disabled() signal.
	 * @param enable True to enable the break, false to disable it
	 */
	public void set_enabled(bool enable) {
		if (enable) {
			this.state = State.WAITING;
			this.focus_manager.release_focus(this);
			this.enabled();
		} else {
			this.state = State.DISABLED;
			this.focus_manager.release_focus(this);
			this.disabled();
		}
	}
	
	/**
	 * @return true if the break is enabled and waiting to start automatically
	 */
	public bool is_enabled() {
		return this.state != State.DISABLED;
	}
	
	/**
	 * @return true if the break has been activated, is in focus, and expects to be satisfied
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
			this.activated();
			this.focus_manager.request_focus(this);
		}
	}
	
	/**
	 * Break's requirements have been satisfied. Start counting from
	 * the beginning again.
	 */
	public void finish() {
		this.state = State.WAITING;
		this.finished();
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
		this.focus_started();
	}
	
	public void stop_focus(bool replaced) {
		this.focused = false;
		this.focus_ended();
	}
}

