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
public class BreakManager : Object {
	public delegate void FocusStart();
	public delegate void FocusStop(bool replaced);
	
	private class NullFocusable : Object, Focusable {
		public FocusPriority get_priority() {
			return FocusPriority.NONE;
		}
		public bool is_focused() {
			return false;
		}
		public void start_focus() {}
		public void stop_focus(bool replaced) {}
	}
	private static NullFocusable NULL_FOCUSABLE = new NullFocusable();
	
	private Gee.Set<Focusable> focus_requests;
	private Focusable current_hold;
	private Focusable current_focus;
	
	public BreakManager() {
		this.focus_requests = new Gee.HashSet<Focusable>();
		this.current_hold = NULL_FOCUSABLE;
		this.current_focus = NULL_FOCUSABLE;
	}
	
	private void set_focus(Focusable? new_focus) {
		Focusable old_focus = this.current_focus;
		if (new_focus == this.current_hold) {
			this.current_hold = NULL_FOCUSABLE;
		}
		if (new_focus != old_focus) {
			this.current_focus = new_focus;
			old_focus.stop_focus(true);
			new_focus.start_focus();
		}
	}
	
	private void update_focus() {
		stdout.printf("update_focus\n");
		Focusable new_focus = NULL_FOCUSABLE;
		
		foreach (Focusable request in this.focus_requests) {
			if (request.get_priority() >= new_focus.get_priority() &&
			    request.get_priority() >= this.current_hold.get_priority() ) {
				new_focus = request;
			} else {
				stdout.printf("Just blocked a request on a hold or an ongoing Focusable\n");
			}
		}
		
		this.set_focus(new_focus);
	}
	
	public void set_hold(Focusable hold) {
		if (hold.get_priority() >= this.current_hold.get_priority()) {
			this.current_hold = hold;
		}
	}
	
	public void request_focus(Focusable request) {
		stdout.printf("request_focus\n");
		this.focus_requests.add(request);
		this.update_focus();
	}
	
	public void release_focus(Focusable request) {
		stdout.printf("release_focus\n");
		this.focus_requests.remove(request);
		this.update_focus();
	}
}

public enum FocusPriority {
	NONE,
	LOW,
	HIGH
}

public interface Focusable : Object {
	public abstract FocusPriority get_priority();
	
	public abstract bool is_focused();
	public abstract void start_focus();
	public abstract void stop_focus(bool replaced);
}

