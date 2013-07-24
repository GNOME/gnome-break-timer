/*
 * This file is part of GNOME Break Timer.
 * 
 * GNOME Break Timer is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * GNOME Break Timer is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with GNOME Break Timer.  If not, see <http://www.gnu.org/licenses/>.
 */

public interface IFocusable : Object {
	public abstract void focus_started();
	public abstract void focus_stopped();
	public abstract string get_id();
}

public enum FocusPriority {
	NONE,
	LOW,
	HIGH
}

/**
 * Keeps track of focus requests, ensuring that only a single Focusable object
 * will have focus at a given time. Any object that implements the IFocusable
 * interface may request focus, and the most recent request with the highest
 * priority will be given focus. Focus can change at any time as other objects
 * request or release focus.
 */
public class SimpleFocusManager : Object {
	private class Request : Object {
		public IFocusable owner;
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
	
	public SimpleFocusManager() {
		this.focus_requests = new SList<Request>();
		this.current_focus = null;
	}
	
	private void set_focus(Request? new_focus) {
		Request? old_focus = this.current_focus;
		
		if (new_focus != old_focus) {
			this.current_focus = new_focus;
			// the order is important so new_focus can gracefully replace old_focus
			if (new_focus != null) {
				new_focus.owner.focus_started();
				GLib.debug("New focus: %s", new_focus.owner.get_id());
			}
			if (old_focus != null) {
				old_focus.owner.focus_stopped();
				GLib.debug("(Old focus: %s)", old_focus.owner.get_id());
			}
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
	
	private bool focus_requested(IFocusable focusable) {
		foreach (Request request in this.focus_requests) {
			if (request.owner == focusable) return true;
		}
		return false;
	}
	
	public void request_focus(IFocusable focusable, FocusPriority priority) {
		GLib.debug("%s, request focus", focusable.get_id());
		if (! this.focus_requested(focusable)) {
			Request request = new Request();
			request.owner = focusable;
			request.priority = priority;
			
			this.focus_requests.insert_sorted(request, Request.priority_compare_func);
			this.update_focus();
		}
	}
	
	public void release_focus(IFocusable focusable) {
		GLib.debug("%s, release focus", focusable.get_id());
		foreach (Request request in this.focus_requests) {
			if (request.owner == focusable) this.focus_requests.remove(request);
		}
		this.update_focus();
	}
	
	public bool is_focusing(IFocusable focusable) {
		return this.current_focus != null && this.current_focus.owner == focusable;
	}
}

