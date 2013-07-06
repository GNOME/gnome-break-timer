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

public abstract class SettingsPanel : Gtk.Grid {
	private Gtk.Grid header;
	private Gtk.Grid details;
	
	public SettingsPanel() {
		Object();
		
		this.set_orientation(Gtk.Orientation.VERTICAL);
		this.set_row_spacing(12);
		
		this.header = new Gtk.Grid();
		this.header.set_column_spacing(12);
		this.add(header);
		
		this.details = new Gtk.Grid();
		this.details.set_margin_left(12);
		this.add(this.details);
		
		this.show_all();
	}
	
	public void set_header(Gtk.Widget content) {
		this.header.attach(content, 0, 0, 1, 1);
	}

	public void set_header_action(Gtk.Widget content) {
		this.header.attach(content, 1, 0, 1, 1);
		content.set_halign(Gtk.Align.END);
		content.set_valign(Gtk.Align.CENTER);
	}
	
	public void set_details(Gtk.Widget content) {
		this.details.add(content);
	}

	public void set_editable(bool sensitive) {
		this.details.sensitive = sensitive;
	}
}

