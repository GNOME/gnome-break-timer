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

public abstract class BreakType : Object {
	public string id {get; private set;}
	public bool enabled {get; protected set;}
	public BreakStatus status;

	public BreakInfoPanel info_panel;
	public BreakStatusPanel status_panel;
	public BreakSettingsPanel settings_panel;

	public Settings settings;
	
	public BreakType(string id, Settings settings) {
		this.id = id;
		this.settings = settings;

		settings.bind("enabled", this, "enabled", SettingsBindFlags.DEFAULT);
	}

	public signal void status_changed(BreakStatus status);

	public virtual void initialize() {
		this.info_panel = this.get_info_panel();
		this.status_panel = this.get_status_panel();
		this.settings_panel = this.get_settings_panel();
	}

	protected void update_status(BreakStatus status) {
		this.status = status;
		this.status_changed(status);
	}
	
	protected abstract BreakInfoPanel get_info_panel();
	protected abstract BreakStatusPanel get_status_panel();
	protected abstract BreakSettingsPanel get_settings_panel();
}

public abstract class BreakInfoPanel : Gtk.Grid {
	public BreakType break_type {public get; private set;}
	public string title {public get; private set;}

	private Gtk.Label heading_label;
	private Gtk.Label description_label;

	public BreakInfoPanel(BreakType break_type, string title) {
		Object();
		this.break_type = break_type;
		this.title = title;

		this.set_orientation(Gtk.Orientation.VERTICAL);
		this.set_hexpand(true);
		this.set_row_spacing(18);
		this.get_style_context().add_class("_break-info");

		this.heading_label = new Gtk.Label(null);
		this.add(this.heading_label);
		this.heading_label.get_style_context().add_class("_break-info-heading");

		this.description_label = new Gtk.Label(null);
		this.add(this.description_label);
		this.description_label.set_line_wrap(true);
		this.description_label.set_justify(Gtk.Justification.CENTER);
		this.description_label.set_max_width_chars(60);

		this.show_all();
	}

	protected void set_heading(string heading) {
		this.heading_label.set_label(heading);
	}

	protected void set_description(string description) {
		this.description_label.set_label(description);
	}
}

public abstract class BreakStatusPanel : Gtk.Grid {
	public BreakType break_type {public get; private set;}
	public bool is_enabled {get; set; default=false;}

	public BreakStatusPanel(BreakType break_type) {
		Object();
		this.break_type = break_type;

		this.get_style_context().add_class("_break-status");
	}
}

public abstract class BreakSettingsPanel : SettingsPanel {
	public BreakSettingsPanel(BreakType break_type, string title, string? description) {
		base();
		
		var title_grid = new Gtk.Grid();
		this.set_header(title_grid);
		title_grid.set_orientation(Gtk.Orientation.VERTICAL);
		title_grid.set_row_spacing(4);
		
		var title_label = new Gtk.Label(title);
		title_label.set_halign(Gtk.Align.START);
		title_label.get_style_context().add_class("_settings-title");
		title_grid.add(title_label);
		
		var description_label = new Gtk.Label("<small>%s</small>".printf(description));
		description_label.set_use_markup(true);
		description_label.set_halign(Gtk.Align.START);
		description_label.get_style_context().add_class("_settings-description");
		title_grid.add(description_label);
		
		var toggle_switch = new Gtk.Switch();
		this.set_header_action(toggle_switch);
		toggle_switch.set_hexpand(true);
		toggle_switch.set_halign(Gtk.Align.END);
		toggle_switch.set_valign(Gtk.Align.CENTER);
		break_type.settings.bind("enabled", toggle_switch, "active", SettingsBindFlags.DEFAULT);

		this.show_all();
		
		toggle_switch.notify["active"].connect((s, p) => {
			bool enabled = toggle_switch.active;
			this.set_editable(enabled);
		});
	}
}
