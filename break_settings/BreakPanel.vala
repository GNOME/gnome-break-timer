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
	public string break_name {get; private set;}
	public string break_id {get; private set;}
	
	protected int[] interval_options;
	
	private Gtk.Widget header_grid;
	private Gtk.Switch break_switch;
	
	private Gtk.Container details_grid;
	
	public BreakPanel(string break_name, string break_id, int[] interval_options) {
		Object();
		
		this.break_name = break_name;
		this.break_id = break_id;
		this.interval_options = interval_options;
		
		this.set_row_spacing(4);
		
		this.header_grid = this.build_header_grid_widget();
		this.attach(this.header_grid, 0, 0, 1, 1);
		
		this.details_grid = new Gtk.Grid();
		this.details_grid.set_halign(Gtk.Align.CENTER);
		this.attach_next_to(this.details_grid, this.header_grid, Gtk.PositionType.BOTTOM, 1, 1);
		
		this.show_all();
		
		this.set_enabled(true);
	}
	
	public Gtk.Widget get_settings_widget() {
		return this;
	}
	
	public Gtk.Container get_content_area() {
		return this.details_grid;
	}
	
	private Gtk.Widget build_header_grid_widget() {
		Gtk.Grid header_grid = new Gtk.Grid();
		
		Gtk.Label break_label = new Gtk.Label.with_mnemonic(this.break_name);
		break_label.set_halign(Gtk.Align.END);
		break_label.set_margin_right(12);
		break_label.get_style_context().add_class("brainbreak-settings-break-title");
		header_grid.attach(break_label, 0, 0, 1, 1);
		
		Gtk.Switch break_switch = new Gtk.Switch();
		this.break_switch = break_switch;
		break_switch.set_hexpand(true);
		break_switch.set_halign(Gtk.Align.END);
		header_grid.attach_next_to(break_switch, break_label, Gtk.PositionType.RIGHT, 1, 1);
		break_label.set_mnemonic_widget(break_switch);
		
		break_switch.notify["active"].connect((s, p) => {
			this.set_enabled(break_switch.active);
			
		});
		
		header_grid.show_all();
		
		return header_grid;
	}
	
	private void set_enabled(bool enabled) {
		this.details_grid.set_sensitive(enabled);
		this.break_switch.set_active(enabled);
	}
}

