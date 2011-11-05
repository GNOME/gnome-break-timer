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

public abstract class TogglePanel : Gtk.Grid {
	protected string title;
	
	private SwitchHeader header;
	private Gtk.Container details_grid;
	
	public Gtk.Switch toggle_switch {get; private set;}
	
	public TogglePanel(string title) {
		Object();
		
		this.title = title;
		
		this.set_row_spacing(4);
		
		this.header = new SwitchHeader(this.title);
		this.toggle_switch = header.toggle;
		this.attach(header, 0, 0, 1, 1);
		
		this.details_grid = new Gtk.Grid();
		this.details_grid.set_halign(Gtk.Align.START);
		this.details_grid.set_margin_left(12);
		this.attach_next_to(this.details_grid, this.header, Gtk.PositionType.BOTTOM, 1, 1);
		
		this.show_all();
		
		this.toggle_switch.notify["active"].connect((s, p) => {
			this.details_grid.sensitive = this.toggle_switch.active;
		});
	}
	
	public Gtk.Container get_content_area() {
		return this.details_grid;
	}
}

private class SwitchHeader : Gtk.Grid {
	public Gtk.Switch toggle {get; private set;}
	
	public SwitchHeader(string title) {
		Object();
		
		Gtk.Label break_label = new Gtk.Label.with_mnemonic(title);
		break_label.set_halign(Gtk.Align.END);
		break_label.set_margin_right(12);
		break_label.get_style_context().add_class("brainbreak-settings-title");
		this.attach(break_label, 0, 0, 1, 1);
		
		this.toggle = new Gtk.Switch();
		this.toggle.set_hexpand(true);
		this.toggle.set_halign(Gtk.Align.END);
		this.attach_next_to(this.toggle, break_label, Gtk.PositionType.RIGHT, 1, 1);
		break_label.set_mnemonic_widget(this.toggle);
		
		break_label.show();
		this.toggle.show();
	}
}

