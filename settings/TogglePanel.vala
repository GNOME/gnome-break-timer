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

public abstract class TogglePanel : Panel {
	private Gtk.Grid inner_details_grid;
	
	// FIXME: we're only exposing this so QuietMode can do cool stuff with GSettings.bind to its active property
	public Gtk.Switch toggle_switch;
	public signal void toggled(bool enabled);
	
	public TogglePanel(string title) {
		base(title);
		
		Gtk.Grid content = base.get_content_area();
		
		this.toggle_switch = new Gtk.Switch();
		this.toggle_switch.set_halign(Gtk.Align.START);
		this.toggle_switch.set_valign(Gtk.Align.START);
		content.add(this.toggle_switch);
		
		this.inner_details_grid = new Gtk.Grid();
		this.inner_details_grid.set_margin_left(36);
		content.attach_next_to(this.inner_details_grid, this.toggle_switch, Gtk.PositionType.RIGHT, 1, 1);
		
		this.toggle_switch.notify["active"].connect((s, p) => {
			this.toggled(this.toggle_switch.active);
		});
		this.toggled.connect((enabled) => {
			this.get_content_area().sensitive = this.toggle_switch.active;
		});
		
		this.show_all();
	}
	
	public override Gtk.Grid get_content_area() {
		return this.inner_details_grid;
	}
}

