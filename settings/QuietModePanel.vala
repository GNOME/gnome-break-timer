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

public class QuietModePanel : Panel {
	public int64 expire_time {get; set;}
	
	public Gtk.ToggleButton toggle_switch;
	
	public signal void toggled(bool enabled);
	
	private uint countdown_source_id;
	
	public QuietModePanel() {
		base("Quiet Mode");
		
		Gtk.Grid content = this.get_content_area();
		
		this.toggle_switch = new Gtk.CheckButton.with_label(_("Please don't interrupt me. I'm doing something important."));
		content.add(this.toggle_switch);
		
		this.show_all();
		
		this.toggle_switch.notify["active"].connect((s, p) => {
			this.toggled(this.toggle_switch.active);
		});
		
		this.countdown_source_id = 0;
		
		this.notify["expire-time"].connect((s, p) => {
			if (this.toggle_switch.active == true) {
				this.start_countdown();
			} else {
				this.end_countdown();
			}
		});
	}
	
	public void start_countdown() {
		this.countdown_source_id = Timeout.add_seconds(1, this.countdown_timeout);
		this.countdown_timeout();
	}
	
	public void end_countdown() {
		this.set_status_text("");
		this.toggle_switch.active = false;
		if (this.countdown_source_id > 0) {
			Source.remove(this.countdown_source_id);
			this.countdown_source_id = 0;
		}
	}
	
	private bool countdown_timeout() {
		DateTime now = new DateTime.now_utc();
		int64 time_remaining = this.expire_time - now.to_unix();
		
		if (time_remaining > 0) {
			string label = NaturalTime.get_instance().get_countdown_for_seconds((int)time_remaining);
			this.set_status_text("%s".printf(label));
		} else {
			this.end_countdown();
			return false;
		}
		
		return true;
	}
	
	
}

