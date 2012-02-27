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
 * Smooths interaction between multiple breaks by managing focus, where only a
 * single break can ask for focus at a single time; all others continue in idle
 * mode. The break manager can postpone breaks or cancel breaks as appropriate,
 * depending on others waiting in line.
 */
public class BreakFocusManager : Object, FocusManager<BreakType> {
	private class Request : Object {
		public BreakType owner;
		public FocusPriority priority;
	
		public static int priority_compare_func(Request a, Request b) {
			if (a.priority < b.priority) {
				return -1;
			} else if (a.priority == b.priority) {
				return 0;
			} else {
				return 1;
			}
		}
	}
	
	private SList<Request> focus_requests;
	private Request? current_focus;
	
	public BreakFocusManager() {
		this.focus_requests = new SList<Request>();
		this.current_focus = null;
	}
	
	private void set_focus(Request? new_focus) {
		Request? old_focus = this.current_focus;
		
		if (new_focus != old_focus) {
			this.current_focus = new_focus;
			// the order is very important here
			// this way, new_focus can smoothly replace old_focus
			if (new_focus != null) this.focus_started(new_focus.owner);
			if (old_focus != null) this.focus_stopped(old_focus.owner);
		}
	}
	
	private void update_focus() {
		Request? new_focus = null;
		if (this.focus_requests.length() > 0) {
			new_focus = this.focus_requests.last().data;
		}
		this.set_focus(new_focus);
	}
	
	private bool focus_requested(BreakType owner) {
		foreach (Request request in this.focus_requests) {
			if (request.owner == owner) return true;
		}
		return false;
	}
	
	public void request_focus(BreakType owner, FocusPriority priority) {
		if (! this.focus_requested(owner)) {
			Request request = new Request();
			request.owner = owner;
			request.priority = priority;
			
			this.focus_requests.insert_sorted(request, Request.priority_compare_func);
			this.update_focus();
		}
	}
	
	public void release_focus(BreakType owner) {
		foreach (Request request in this.focus_requests) {
			if (request.owner == owner) this.focus_requests.remove(request);
		}
		this.update_focus();
	}
	
	public BreakType get_focus() {
		if (this.current_focus != null) {
			return this.current_focus.owner;
		} else {
			return null;
		}
	}
	
	/**
	 * Convenience function to attach the focus-related signals in
	 * BreakView directly to this focus manager.
	 */
	public void monitor_break_type(BreakType break_type) {
		BreakView view = break_type.view;
		view.focus_requested.connect((priority) => {
			this.request_focus(break_type, priority);
		});
		view.focus_released.connect((priority) => {
			this.release_focus(break_type);
		});
	}
}

