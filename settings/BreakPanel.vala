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

public abstract class BreakPanel : Gtk.Grid {
	protected BreakType break_type;
	
	protected int[] interval_options;
	
	private Gtk.Widget header_grid;
	private Gtk.Container details_grid;
	
	public Gtk.Switch toggle_switch;
	
	public BreakPanel(BreakType break_type, int[] interval_options) {
		Object();
		
		this.break_type = break_type;
		this.interval_options = interval_options;
		
		this.set_row_spacing(4);
		
		this.header_grid = this.build_header_grid_widget();
		this.attach(this.header_grid, 0, 0, 1, 1);
		
		this.details_grid = new Gtk.Grid();
		this.details_grid.set_halign(Gtk.Align.START);
		this.details_grid.set_margin_left(12);
		this.attach_next_to(this.details_grid, this.header_grid, Gtk.PositionType.BOTTOM, 1, 1);
		
		this.show_all();
		
		this.toggle_switch.notify["active"].connect((s, p) => {
			this.details_grid.sensitive = this.toggle_switch.active;
			this.toggle_switch.active = this.toggle_switch.active;
		});
	}
	
	public Gtk.Widget get_break_type_widget() {
		return this;
	}
	
	public Gtk.Container get_content_area() {
		return this.details_grid;
	}
	
	private Gtk.Widget build_header_grid_widget() {
		Gtk.Grid header_grid = new Gtk.Grid();
		
		Gtk.Label break_label = new Gtk.Label.with_mnemonic(this.break_type.name);
		break_label.set_halign(Gtk.Align.END);
		break_label.set_margin_right(12);
		break_label.get_style_context().add_class("brainbreak-settings-title");
		header_grid.attach(break_label, 0, 0, 1, 1);
		
		this.toggle_switch = new Gtk.Switch();
		this.toggle_switch.set_hexpand(true);
		this.toggle_switch.set_halign(Gtk.Align.END);
		header_grid.attach_next_to(this.toggle_switch, break_label, Gtk.PositionType.RIGHT, 1, 1);
		break_label.set_mnemonic_widget(this.toggle_switch);
		
		header_grid.show_all();
		
		return header_grid;
	}
}

