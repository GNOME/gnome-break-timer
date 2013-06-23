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
 * A FocusManager that keeps track of focus between BreakViews, so only one
 * break is shown to the user at a time.
 */
public class BreakFocusManager : Object, FocusManager<BreakView> {
	private class Request : Object {
		public BreakView owner;
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
			if (new_focus != null) GLib.debug("New focus: %s", new_focus.owner.get_id());
			if (old_focus != null) GLib.debug("(Old focus: %s)", old_focus.owner.get_id());
			if (new_focus != null) this.focus_started(new_focus.owner);
			if (old_focus != null) this.focus_stopped(old_focus.owner);
		}
	}
	
	private void update_focus() {
		Request? new_focus = null;
		GLib.debug("update_focus");
		if (this.focus_requests.length() > 0) {
			new_focus = this.focus_requests.last().data;
		}
		this.set_focus(new_focus);
	}
	
	private bool focus_requested(BreakView break_view) {
		foreach (Request request in this.focus_requests) {
			if (request.owner == break_view) return true;
		}
		return false;
	}
	
	public void request_focus(BreakView break_view, FocusPriority priority) {
		GLib.debug("%s, request focus", break_view.get_id());
		if (! this.focus_requested(break_view)) {
			Request request = new Request();
			request.owner = break_view;
			request.priority = priority;
			
			this.focus_requests.insert_sorted(request, Request.priority_compare_func);
			this.update_focus();
		}
	}
	
	public void release_focus(BreakView break_view) {
		GLib.debug("%s, release focus", break_view.get_id());
		foreach (Request request in this.focus_requests) {
			if (request.owner == break_view) this.focus_requests.remove(request);
		}
		this.update_focus();
	}
	
	/**
	 * @return the break that is currently in focus, or null if there is not one.
	 */
	// This is not defined in the interface, because we can't make T
	// nullable in the interface.
	public BreakView? get_focus() {
		if (this.current_focus != null) {
			return this.current_focus.owner;
		} else {
			return null;
		}
	}
	
	public bool is_focusing(BreakView break_view) {
		return this.get_focus() == break_view;
	}
}

