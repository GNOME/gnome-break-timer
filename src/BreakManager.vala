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
public class BreakManager {
	public enum FocusPriority {
		LOW,
		HIGH
	}
	
	public delegate void FocusStart();
	public delegate void FocusStop(bool replaced);
	
	public class FocusRequest {
		public Break break_scheduler;
		public FocusPriority priority;
		
		public unowned FocusStart start;
		public unowned FocusStop stop;
		
		public bool focused;
		
		public FocusRequest(Break break_scheduler, FocusPriority priority, FocusStart start_cb, FocusStop stop_cb) {
			this.break_scheduler = break_scheduler;
			this.priority = priority;
			this.start = start_cb;
			this.stop = stop_cb;
		}
	}
	
	private SList<FocusRequest> focus_requests;
	private FocusRequest current_focus;
	
	public BreakManager() {
		this.focus_requests = new SList<FocusRequest>();
	}
	
	private void set_focus(FocusRequest? new_focus) {
		FocusRequest old_focus = this.current_focus;
		if (new_focus != old_focus) {
			this.current_focus = new_focus;
			if (old_focus != null) {
				old_focus.stop(true);
			}
			if (new_focus != null) {
				new_focus.start();
			}
		}
	}
	
	private void update_focus() {
		FocusRequest new_focus = null;
		foreach (FocusRequest request in this.focus_requests) {
			if (new_focus == null || request.priority > new_focus.priority) {
				new_focus = request;
			}
		}
		this.set_focus(new_focus);
	}
	
	public void request_focus(FocusRequest request) {
		this.focus_requests.append(request);
		this.update_focus();
	}
	
	public void release_focus(FocusRequest request) {
		stdout.printf("Release_focus\n");
		request.stop(false);
		this.focus_requests.remove(request);
		this.update_focus();
	}
}

