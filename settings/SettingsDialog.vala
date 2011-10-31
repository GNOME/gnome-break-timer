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
	public SettingsDialog(BreakPanel[] settings_panels, Settings breaks_settings) {
		Object();
		
		this.set_title("Break Settings");
		this.set_resizable(false);
		
		this.add_buttons(Gtk.Stock.CLOSE, Gtk.ResponseType.CLOSE);
		this.response.connect(this.response_cb);
		
		Gtk.Box content = (Gtk.Box) this.get_content_area();
		
		Gtk.Grid breaks_grid = new Gtk.Grid();
		breaks_grid.margin = 12;
		breaks_grid.set_row_spacing(18);
		content.add(breaks_grid);
		
		int insert_row = 0;
		foreach (BreakPanel panel in settings_panels) {
			Gtk.Widget settings_widget = panel.get_settings_widget();
			breaks_grid.attach(settings_widget, 0, insert_row, 1, 1);
			insert_row += 1;
		}
		
		breaks_grid.show();
	}
	
	private void response_cb(int response_id) {
		if (response_id == Gtk.ResponseType.CLOSE) {
			this.destroy ();
		}
	}
}

