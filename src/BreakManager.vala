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
	public enum FocusPriority {
		LOW,
		HIGH
	}
	
	public delegate void FocusStart();
	public delegate void FocusStop(bool replaced);
	
	private Gee.Set<Focusable> focus_requests;
	private Focusable current_focus;
	
	public BreakManager() {
		this.focus_requests = new Gee.HashSet<Focusable>();
	}
	
	private void set_focus(Focusable? new_focus) {
		Focusable old_focus = this.current_focus;
		if (new_focus != old_focus) {
			this.current_focus = new_focus;
			if (old_focus != null) {
				old_focus.stop_focus(true);
			}
			if (new_focus != null) {
				new_focus.start_focus();
			}
		}
	}
	
	private void update_focus() {
		Focusable new_focus = null;
		foreach (Focusable request in this.focus_requests) {
			if (new_focus == null || request.get_priority() > new_focus.get_priority()) {
				new_focus = request;
			}
		}
		this.set_focus(new_focus);
	}
	
	public void request_focus(Focusable request) {
		this.focus_requests.add(request);
		this.update_focus();
	}
	
	public void release_focus(Focusable request) {
		stdout.printf("Release_focus\n");
		this.focus_requests.remove(request);
		this.update_focus();
	}
}

public interface Focusable : Object {
	public abstract BreakManager.FocusPriority get_priority();
	
	public abstract void start_focus();
	
	public abstract void stop_focus(bool replaced);
}

