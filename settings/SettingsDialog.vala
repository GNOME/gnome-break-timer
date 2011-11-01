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
	private BreakType[] break_types;
	
	private static const int ABOUT_BUTTON_RESPONSE = 5;
	
	public SettingsDialog(BreakType[] break_types) {
		Object();
		
		this.break_types = break_types;
		
		this.set_title(_("Break Settings"));
		this.set_resizable(false);
		
		Gtk.Widget about_button = this.add_button(Gtk.Stock.ABOUT, Gtk.ResponseType.HELP);
		Gtk.Widget close_button = this.add_button(Gtk.Stock.CLOSE, Gtk.ResponseType.CLOSE);
		this.response.connect(this.response_cb);
		
		Gtk.Box content = (Gtk.Box) this.get_content_area();
		
		this.application_panel = new ApplicationPanel();
		Gtk.Widget status_widget = application_panel.get_status_widget();
		content.add(this.application_panel);
		
		Gtk.Grid breaks_grid = new Gtk.Grid();
		breaks_grid.margin = 12;
		breaks_grid.set_row_spacing(18);
		content.add(breaks_grid);
		
		int insert_row = 0;
		
		foreach (BreakType break_type in this.break_types) {
			break_type.notify["enabled"].connect((s, p) => {
				this.on_break_disabled();
			});
			Gtk.Widget settings_panel = break_type.make_settings_panel();
			breaks_grid.attach(settings_panel, 0, insert_row, 1, 1);
			insert_row += 1;
		}
		
		// update the master switch with any changes made externally
		this.on_break_disabled();
		
		breaks_grid.show();
	}
	
	private void on_break_disabled() {
		bool any_enabled = false;
		foreach (BreakType break_type in this.break_types) {
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
				"comments", _("Computer break tool for active minds"),
				"copyright", _("Copyright © Dylan McCall"),
				"website", "http://launchpad.net/brainbreak",
				"website-label", _("Brain Break Website")
			);
		}
	}
}

