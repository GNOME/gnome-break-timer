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

public class SettingsDialog : Gtk.Dialog {
	private ApplicationPanel application_panel;
	private Gtk.Grid breaks_grid;
	
	private Gee.Map<string, BreakType> break_types;
	
	private static const int ABOUT_BUTTON_RESPONSE = 5;
	
	public SettingsDialog() {
		Object();
		
		this.break_types = new Gee.HashMap<string, BreakType>();
		
		this.set_title(_("Break Settings"));
		this.set_resizable(false);
		this.set_size_request(325, -1);
		
		Gtk.Widget about_button = this.add_button(Gtk.Stock.ABOUT, Gtk.ResponseType.HELP);
		Gtk.Widget close_button = this.add_button(Gtk.Stock.CLOSE, Gtk.ResponseType.CLOSE);
		this.response.connect(this.response_cb);
		
		Gtk.Box content = (Gtk.Box) this.get_content_area();
		
		this.application_panel = new ApplicationPanel();
		Gtk.Widget status_widget = application_panel.get_status_widget();
		content.add(this.application_panel);
		
		this.breaks_grid = new Gtk.Grid();
		this.breaks_grid.set_orientation(Gtk.Orientation.VERTICAL);
		this.breaks_grid.margin = 12;
		this.breaks_grid.set_row_spacing(18);
		content.add(this.breaks_grid);
		
		Gtk.Grid extra_grid = new Gtk.Grid();
		extra_grid.set_orientation(Gtk.Orientation.VERTICAL);
		extra_grid.margin = 12;
		extra_grid.set_row_spacing(18);
		content.add(extra_grid);
		
		QuietMode quiet_mode = new QuietMode();
		Gtk.Widget quiet_panel = quiet_mode.get_settings_panel();
		extra_grid.add(quiet_panel);
		
		extra_grid.show();
		breaks_grid.show();
	}
	
	public void add_break_type(BreakType break_type) {
		this.break_types.set(break_type.name, break_type);
		
		break_type.notify["enabled"].connect((s, p) => {
			this.on_break_disabled();
		});
		Gtk.Widget settings_panel = break_type.get_settings_panel();
		breaks_grid.add(settings_panel);
		
		// update the master switch with any changes made externally
		this.on_break_disabled();
	}
	
	private void on_break_disabled() {
		bool any_enabled = false;
		foreach (BreakType break_type in this.break_types.values) {
			if (break_type.enabled) any_enabled = true;
		}
		this.application_panel.master_enabled = any_enabled;
	}
	
	private void response_cb(int response_id) {
		if (response_id == Gtk.ResponseType.CLOSE) {
			this.destroy ();
		} else if (response_id == Gtk.ResponseType.HELP) {
			Gtk.show_about_dialog(this,
				"program-name", _("Brain Break"),
				"comments", _("Computer break reminders for active minds"),
				"copyright", _("Copyright © Dylan McCall"),
				"website", "http://launchpad.net/brainbreak",
				"website-label", _("Brain Break Website")
			);
		}
	}
}

