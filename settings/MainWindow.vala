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

public class MainWindow : Gtk.ApplicationWindow {
	private Settings settings;

	private SettingsDialog settings_dialog;
	private Gtk.Grid breaks_grid;

	public MainWindow(Application application) {
		Object(application: application);

		this.settings = new Settings("org.brainbreak.breaks");
		
		this.set_title(_("Break Timer"));
		this.set_hide_titlebar_when_maximized(true);

		this.settings_dialog = new SettingsDialog(application);
		this.settings_dialog.set_modal(true);
		this.settings_dialog.set_transient_for(this);
		
		Gtk.Grid content = new Gtk.Grid();
		this.add(content);
		content.set_orientation(Gtk.Orientation.VERTICAL);

		Gd.HeaderBar header = new Gd.HeaderBar();
		content.add(header);
		header.set_hexpand(true);

		header.set_title("Break Timer");

		Gtk.Switch master_switch = new Gtk.Switch();
		header.pack_start(master_switch);
		this.settings.bind("master-enabled", master_switch, "active", SettingsBindFlags.DEFAULT);

		Gtk.Button settings_button = new Gtk.Button();
		header.pack_end(settings_button);
		settings_button.clicked.connect(this.settings_clicked_cb);
		// FIXME: This icon is not semantically correct. (Wrong category, especially).
		settings_button.set_image(new Gtk.Image.from_icon_name(
			"preferences-system-symbolic",
			Gtk.IconSize.SMALL_TOOLBAR)
		);
		settings_button.set_always_show_image(true);

		this.breaks_grid = new Gtk.Grid();
		content.add(this.breaks_grid);
		this.breaks_grid.set_orientation(Gtk.Orientation.VERTICAL);
		this.breaks_grid.set_row_spacing(36);
		this.breaks_grid.margin = 12;
		this.breaks_grid.set_vexpand(true);
		this.breaks_grid.set_halign(Gtk.Align.CENTER);
		this.breaks_grid.set_valign(Gtk.Align.CENTER);

		foreach (BreakType break_type in application.breaks) {
			this.add_break_type(break_type);
		}
		
		content.show_all();
	}

	public void show_about_dialog() {
		Gtk.show_about_dialog(this,
			"program-name", _("Brain Break"),
			"comments", _("Computer break reminders for active minds"),
			"copyright", _("Copyright © Dylan McCall"),
			"website", "http://launchpad.net/brainbreak",
			"website-label", _("Brain Break Website")
		);
	}

	private void add_break_type(BreakType break_type) {
		// Get break_type info panel and put it in this window
		Gtk.Widget status_panel = break_type.get_status_panel();
		this.breaks_grid.add(status_panel);

		break_type.notify["enabled"].connect((s, p) => {
			this.on_break_disabled();
		});
		this.on_break_disabled();
	}

	private void settings_clicked_cb() {
		this.settings_dialog.show();
	}

	private void on_break_disabled() {
		/*
		bool any_enabled = false;
		foreach (BreakType break_type in this.break_types.values) {
			if (break_type.enabled) any_enabled = true;
		}
		this.application_panel.master_enabled = any_enabled;
		*/
	}

	private void launch_helper() {
		AppInfo helper_app_info = new DesktopAppInfo("brainbreak.desktop");
		AppLaunchContext app_launch_context = new AppLaunchContext();
		
		try {
			helper_app_info.launch(null, app_launch_context);
		} catch (Error error) {
			stderr.printf("Error launching brainbreak helper: %s\n", error.message);
		}
	}
}

