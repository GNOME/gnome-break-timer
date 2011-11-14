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

public abstract class BreakView : BreakOverlaySource, Object {
	protected Break break_scheduler {get; private set;}
	
	public string title {get; protected set;}
	public int warn_time {get; protected set;}
	
	public BreakView(Break break_scheduler) {
		this.break_scheduler = break_scheduler;
	}
	
	public abstract Notify.Notification get_start_notification();
	public abstract Notify.Notification get_finish_notification();
	//public abstract int get_lead_in_seconds();
	
	public abstract string get_status_message();
	
	/***** BreakOverlaySource interface ******/
	
	public string get_overlay_title() {
		return this.title;
	}
	
	public abstract Gtk.Widget get_overlay_content();
}

