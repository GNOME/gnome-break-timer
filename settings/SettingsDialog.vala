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
	
	private static const int ABOUT_BUTTON_RESPONSE = 5;
	
	public SettingsDialog(Application application) {
		Object();
		
		this.set_title(_("Choose Your Break Preferences"));
		this.set_resizable(false);

		this.delete_event.connect(this.hide_on_delete);
		
		Gtk.Widget close_button = this.add_button(Gtk.Stock.CLOSE, Gtk.ResponseType.CLOSE);
		this.response.connect(this.response_cb);
		
		Gtk.Box content = (Gtk.Box) this.get_content_area();
		
		this.breaks_grid = new Gtk.Grid();
		this.breaks_grid.set_orientation(Gtk.Orientation.VERTICAL);
		this.breaks_grid.margin = 12;
		this.breaks_grid.set_row_spacing(18);
		content.add(this.breaks_grid);

		foreach (BreakType break_type in application.breaks) {
			this.add_break_type(break_type);
		}
		
		content.show_all();
	}
	
	private void add_break_type(BreakType break_type) {
		Gtk.Widget settings_panel = break_type.get_settings_panel();
		breaks_grid.add(settings_panel);
	}
	
	private void response_cb(int response_id) {
		if (response_id == Gtk.ResponseType.CLOSE) {
			this.hide();
		}
	}
}

