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

// FIXME: we should inherit from something less loaded
public class QuietModePanel : TogglePanel {
	private Settings settings;
	
	public int64 expire_time {get; set;}
	
	private Gtk.Label countdown_label;
	private uint countdown_source_id;
	
	public QuietModePanel() {
		base(_("Quiet Mode"));
		
		this.countdown_source_id = 0;
		
		Gtk.Grid details_grid = new Gtk.Grid();
		details_grid.set_column_spacing(8);
		details_grid.set_row_spacing(8);
		
		this.get_content_area().add(details_grid);
		
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

