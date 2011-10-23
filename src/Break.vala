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
	private BreakManager manager;
	private BreakManager.FocusPriority priority;
	
	public enum State {
		WAITING,
		WARN,
		ACTIVE
	}
	public State state {get; private set;}
	
	protected int interval {get; private set;}
	
	/** Called when a break starts to run */
	public signal void started();
	/** Called when a break is finished running */
	public signal void finished();
	
	private Timer interval_timer;
	
	public Break(BreakManager manager, BreakManager.FocusPriority priority, int interval) {
		this.manager = manager;
		this.priority = priority;
		this.interval = interval;
		
		this.interval_timer = new Timer();
		Timeout.add_seconds(this.interval, this.interval_timeout);
	}
	
	/**
	 * Periodically tests if it is time for a break
	 */
	private bool interval_timeout() {
		/* Start break if the user has been active for interval */
		if (this.interval_timer.elapsed() >= this.interval && this.state == State.WAITING) {
			stdout.printf("Activating break %s!\n", this.get_type().name());
			this.activate();
		}
		
		return true;
	}
	
	public int starts_in() {
		return this.interval - (int)this.interval_timer.elapsed();
	}
	
	/**
	 * A scheduled break is coming up.
	 * This will prevent lower priority breaks from gaining focus.
	 */
	public void warn() {
		this.state = State.WARN;
		this.manager.request_focus(this);
	}
	
	/**
	 * Start a break.
	 * This is usually triggered automatically, but may be triggered
	 * externally as well.
	 */
	public void activate() {
		this.state = State.ACTIVE;
		this.manager.request_focus(this);
	}
	
	/**
	 * Break's requirements have been satisfied.
	 * Start counting from the beginning again.
	 */
	public void end() {
		this.state = State.WAITING;
		this.interval_timer.start();
		this.manager.release_focus(this);
	}
	
	
	/* Focusable interface */
	
	public BreakManager.FocusPriority get_priority() {
		return this.priority;
	}
	
	public void start_focus() {
		this.started();
	}
	
	public void stop_focus(bool replaced) {
		this.finished();
	}
}

