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
	
	private Gtk.Label countdown_label;
	
	private uint countdown_source_id;
	
	public QuietModePanel() {
		base();
		
		Gtk.Container header = this.get_header();
		
		Gtk.Label title_label = new Gtk.Label(_("Quiet Mode"));
		title_label.set_halign(Gtk.Align.START);
		title_label.get_style_context().add_class("_settings-title");
		header.add(title_label);
		
		this.countdown_label = new Gtk.Label(null);
		this.countdown_label.set_hexpand(true);
		this.countdown_label.set_halign(Gtk.Align.END);
		header.add(this.countdown_label);
		
		Gtk.Container content = this.get_content();
		
		this.toggle_switch = new Gtk.CheckButton.with_label(_("Please don't interrupt me. I'm doing something important"));
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
		this.countdown_label.set_markup("");
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
			string countdown = NaturalTime.instance.get_countdown_for_seconds((int)time_remaining);
			this.countdown_label.set_markup(_("<small>Turns off in %s</small>").printf(countdown));
		} else {
			this.end_countdown();
			return false;
		}
		
		return true;
	}
	
	
}

