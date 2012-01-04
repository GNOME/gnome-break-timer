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

public abstract class Panel : Gtk.Grid {
	private PanelHeader header;
	private Gtk.Grid details_grid;
	
	public Panel(string title) {
		Object();
		
		this.set_row_spacing(4);
		
		this.header = new PanelHeader(title);
		this.attach(header, 0, 0, 1, 1);
		
		this.details_grid = new Gtk.Grid();
		this.details_grid.set_margin_left(12);
		this.details_grid.set_orientation(Gtk.Orientation.VERTICAL);
		this.attach_next_to(this.details_grid, this.header, Gtk.PositionType.BOTTOM, 1, 1);
		
		this.show_all();
	}
	
	public void set_status_text(string text) {
		this.header.set_status_text(text);
	}
	
	public virtual Gtk.Grid get_content_area() {
		return this.details_grid;
	}
}

private class PanelHeader : Gtk.Grid {
	private Gtk.Label title_label;
	private Gtk.Label status_label;
	
	public PanelHeader(string title) {
		Object();
		
		this.set_column_spacing(24);
		this.set_row_spacing(6);
		
		this.title_label = new Gtk.Label.with_mnemonic(title);
		this.title_label.set_halign(Gtk.Align.START);
		this.title_label.get_style_context().add_class("brainbreak-settings-title");
		this.attach(this.title_label, 0, 0, 1, 1);
		
		this.status_label = new Gtk.Label(null);
		this.status_label.set_hexpand(true);
		this.status_label.set_halign(Gtk.Align.FILL);
		this.status_label.set_alignment(0, 0);
		this.status_label.get_style_context().add_class("brainbreak-settings-status");
		this.attach_next_to(this.status_label, this.title_label, Gtk.PositionType.RIGHT, 1, 1);
		
		this.show_all();
	}
	
	public void set_status_text(string text) {
		this.status_label.set_markup("<i>%s</i>".printf(text));
	}
}

