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

public abstract class BreakPanel : Panel {
	// FIXME: we're only exposing this so we can use GSettings.bind to its active property
	public Gtk.Switch toggle_switch;
	
	public signal void toggled(bool enabled);
	
	public BreakPanel(string title, string? description) {
		base();
		
		Gtk.Container header = this.get_header();
		
		Gtk.Grid title_grid = new Gtk.Grid();
		title_grid.set_orientation(Gtk.Orientation.VERTICAL);
		title_grid.set_row_spacing(4);
		header.add(title_grid);
		
		Gtk.Label title_label = new Gtk.Label(title);
		title_label.set_halign(Gtk.Align.START);
		title_label.get_style_context().add_class("_settings-title");
		title_grid.add(title_label);
		
		Gtk.Label description_label = new Gtk.Label("<small>%s</small>".printf(description));
		description_label.set_use_markup(true);
		description_label.set_halign(Gtk.Align.START);
		description_label.get_style_context().add_class("_settings-description");
		title_grid.add(description_label);
		
		this.toggle_switch = new Gtk.Switch();
		toggle_switch.set_hexpand(true);
		toggle_switch.set_halign(Gtk.Align.END);
		toggle_switch.set_valign(Gtk.Align.CENTER);
		header.add(toggle_switch);
		
		this.show_all();
		
		this.toggle_switch.notify["active"].connect((s, p) => {
			this.toggled(this.toggle_switch.active);
		});
		this.toggled.connect((enabled) => {
			this.get_content().sensitive = this.toggle_switch.active;
		});
	}
}
