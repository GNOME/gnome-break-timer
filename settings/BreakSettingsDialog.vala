/*
 * This file is part of GNOME Break Timer.
 * 
 * GNOME Break Timer is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * GNOME Break Timer is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with GNOME Break Timer.  If not, see <http://www.gnu.org/licenses/>.
 */

public class BreakSettingsDialog : Gtk.Dialog {
	private BreakManager break_manager;

	private BreakConfigurationChooser configuration_chooser;
	private Gtk.Grid breaks_grid;
	
	private static const int ABOUT_BUTTON_RESPONSE = 5;
	
	public BreakSettingsDialog(BreakManager break_manager) {
		Object();
		this.break_manager = break_manager;

		Settings settings = new Settings("org.gnome.break-timer");
		
		this.set_title(_("Choose Your Break Schedule"));
		this.set_resizable(false);

		this.delete_event.connect(this.hide_on_delete);
		
		this.add_button(Gtk.Stock.CLOSE, Gtk.ResponseType.CLOSE);
		this.response.connect(this.response_cb);
		
		Gtk.Container content_area = (Gtk.Container)this.get_content_area();

		Gtk.Grid content = new Gtk.Grid();
		content_area.add(content);
		content.set_orientation(Gtk.Orientation.VERTICAL);
		content.set_margin_left(10);
		content.set_margin_right(10);

		this.configuration_chooser = new BreakConfigurationChooser();
		content.add(this.configuration_chooser);
		this.configuration_chooser.add_configuration(
			{"microbreak", "restbreak"},
			_("A mix of short breaks and long breaks")
		);
		this.configuration_chooser.add_configuration(
			{"restbreak"},
			_("Occasional long breaks")
		);
		this.configuration_chooser.add_configuration(
			{"microbreak"},
			_("Frequent short breaks")
		);
		settings.bind("selected-breaks", this.configuration_chooser, "selected-break-ids", SettingsBindFlags.DEFAULT);

		this.breaks_grid = new Gtk.Grid();
		content.add(this.breaks_grid);
		this.breaks_grid.set_orientation(Gtk.Orientation.VERTICAL);
		
		content.show_all();

		break_manager.break_added.connect(this.break_added_cb);
		this.configuration_chooser.notify["selected-break-ids"].connect(this.update_break_configuration);
	}

	private void update_break_configuration() {
		foreach (BreakType break_type in this.break_manager.all_breaks()) {
			if (break_type.id in this.configuration_chooser.selected_break_ids) {
				break_type.settings_panel.show();
			} else {
				break_type.settings_panel.hide();
			}
		}
	}

	private void break_added_cb(BreakType break_type) {
		var settings_panel = break_type.settings_panel;
		breaks_grid.add(settings_panel);
		settings_panel.set_margin_top(10);
		settings_panel.set_margin_bottom(10);
		this.update_break_configuration();
	}
	
	private void response_cb(int response_id) {
		if (response_id == Gtk.ResponseType.CLOSE) {
			this.hide();
		}
	}
}

class BreakConfigurationChooser : Gtk.ComboBox {
	public class Configuration : Object {
		public Gtk.TreeIter iter;
		public string[] break_ids;
		public string label;

		public Configuration(string[] break_ids, string label) {
			this.break_ids = break_ids;
			this.label = label;
		}

		public bool matches_breaks(string[] test_break_ids) {
			if (test_break_ids.length == this.break_ids.length) {
				foreach (string test_break_id in test_break_ids) {
					if (! (test_break_id in this.break_ids)) return false;
				}
				return true;
			} else {
				return false;
			}
		}
	}

	private Gtk.ListStore list_store;
	private List<Configuration> configurations;

	public string[] selected_break_ids {public get; public set;}

	public BreakConfigurationChooser() {
		Object();
		this.configurations = new List<Configuration>();

		this.list_store = new Gtk.ListStore(2, typeof(Configuration), typeof(string));
		this.set_model(this.list_store);

		var label_renderer = new Gtk.CellRendererText();
		this.pack_start(label_renderer, true);
		this.add_attribute(label_renderer, "text", 1);

		this.notify["active"].connect(this.send_selected_break);
		this.notify["selected-break-ids"].connect(this.receive_selected_break);
	}

	public void add_configuration(string[] break_ids, string label) {
		var configuration = new Configuration(break_ids, label);
		this.configurations.append(configuration);
		Gtk.TreeIter iter;
		this.list_store.append(out iter);
		this.list_store.set(iter, 0, configuration, 1, configuration.label);
		configuration.iter = iter;	
	}

	private void send_selected_break() {
		Gtk.TreeIter iter;
		if (this.get_active_iter(out iter)) {
			Value value;
			this.list_store.get_value(iter, 0, out value);
			Configuration configuration = (Configuration)value;
			this.selected_break_ids = configuration.break_ids;
		}
	}

	private void receive_selected_break() {
		var configuration = this.get_configuration_for_break_ids(this.selected_break_ids);
		if (configuration != null) {
			this.set_active_iter(configuration.iter);
		} else {
			this.set_active(-1);
		}
	}

	private Configuration? get_configuration_for_break_ids(string[] selected_breaks) {
		foreach (Configuration configuration in this.configurations) {
			if (configuration.matches_breaks(selected_breaks)) {
				return configuration;
			}
		}
		return null;
	}
}

