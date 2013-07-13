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

	private IBreakHelper? break_helper_server;

	private Gd.HeaderBar header;
	private BreakSettingsDialog break_settings_dialog;
	private Gd.Stack main_stack;

	private StatusPanel status_panel;

	public MainWindow(Application application, BreakManager break_manager) {
		Object(application: application);

		this.settings = new Settings("org.brainbreak.breaks");
		
		this.set_title(_("Break Timer"));
		this.set_hide_titlebar_when_maximized(true);

		this.break_settings_dialog = new BreakSettingsDialog(break_manager);
		this.break_settings_dialog.set_modal(true);
		this.break_settings_dialog.set_transient_for(this);
		
		Gtk.Grid content = new Gtk.Grid();
		this.add(content);
		content.set_orientation(Gtk.Orientation.VERTICAL);
		content.set_vexpand(true);

		this.header = new Gd.HeaderBar();
		content.add(this.header);
		this.header.set_hexpand(true);

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

		this.main_stack = new Gd.Stack();
		content.add(this.main_stack);
		main_stack.set_margin_left(10);
		main_stack.set_margin_right(10);

		this.status_panel = new StatusPanel(break_manager);
		this.main_stack.add(this.status_panel);

		content.show_all();
		
		break_manager.break_added.connect(this.break_added_cb);
		break_manager.foreground_break_changed.connect(this.foreground_break_changed_cb);
		this.foreground_break_changed_cb(null);
	}

	private void break_added_cb(BreakType break_type) {
		var info_panel = break_type.info_panel;
		this.main_stack.add(info_panel);
		info_panel.set_halign(Gtk.Align.CENTER);
		info_panel.set_valign(Gtk.Align.CENTER);
	}

	private void foreground_break_changed_cb(BreakType? break_type) {
		if (break_type != null) {
			this.main_stack.set_visible_child(break_type.info_panel);
			this.header.set_title(break_type.info_panel.title);
		} else {
			this.main_stack.set_visible_child(this.status_panel);
			this.header.set_title("Break Timer");
		}
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

	private void settings_clicked_cb() {
		this.break_settings_dialog.show();
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

private class WelcomePanel : Gd.Stack {
	
}

private class StatusPanel : Gd.Stack {
	private BreakManager break_manager;

	private Gtk.Grid breaks_list;
	private Gtk.Grid no_breaks_message;
	private Gtk.Grid error_message;

	public StatusPanel(BreakManager break_manager) {
		// TODO: Once we port to Gtk.Stack, set property "homogenous: false"
		Object();

		this.break_manager = break_manager;

		this.margin = 12;
		this.set_hexpand(true);
		this.set_vexpand(true);

		this.breaks_list = this.build_breaks_list(break_manager);
		this.add(this.breaks_list);
		
		this.no_breaks_message = this.build_no_breaks_message();
		this.add(this.no_breaks_message);

		this.error_message = this.build_error_message();
		this.add(this.error_message);

		break_manager.break_added.connect(this.break_added_cb);
	}

	private Gtk.Grid build_breaks_list(BreakManager break_manager) {
		var breaks_list = new Gtk.Grid();
		breaks_list.set_orientation(Gtk.Orientation.VERTICAL);
		breaks_list.set_halign(Gtk.Align.CENTER);
		breaks_list.set_valign(Gtk.Align.CENTER);

		return breaks_list;
	}

	private Gtk.Grid build_message(string icon_name, string heading, string detail) {
		var message = new Gtk.Grid();
		message.set_orientation(Gtk.Orientation.VERTICAL);
		message.set_halign(Gtk.Align.CENTER);
		message.set_valign(Gtk.Align.CENTER);
		message.set_row_spacing(12);

		var image = new Gtk.Image.from_icon_name(icon_name, Gtk.IconSize.DIALOG);
		message.add(image);
		image.set_pixel_size(120);
		image.get_style_context().add_class("_break-status-icon");

		var heading_label = new Gtk.Label(heading);
		message.add(heading_label);
		heading_label.get_style_context().add_class("_break-status-heading");

		var detail_label = new Gtk.Label(null);
		message.add(detail_label);
		detail_label.set_markup(detail);
		detail_label.get_style_context().add_class("_break-status-hint");
		detail_label.set_max_width_chars(60);

		return message;
	}

	private Gtk.Grid build_no_breaks_message() {
		return this.build_message(
			"face-sad-symbolic",
			_("Break Timer is taking a break"),
			_("Turn me on to get those breaks going")
		);
	}

	private Gtk.Grid build_error_message() {
		return this.build_message(
			"face-sick-symbolic",
			_("Break Timer isn’t responding"),
			_("If this continues the next time you log in, please <a href=\"https://bugs.launchpad.net/brainbreak\">open a bug report</a>.")
		);
	}

	private void break_added_cb(BreakType break_type) {
		var status_panel = break_type.status_panel;
		this.breaks_list.add(status_panel);
		status_panel.set_margin_top(18);
		status_panel.set_margin_bottom(18);

		break_type.status_changed.connect(() => {
			this.update_breaks_list();
		});
		this.update_breaks_list();
	}

	private void update_breaks_list() {
		bool success = false;
		bool any_breaks_enabled = false;

		unowned List<BreakType> all_breaks = this.break_manager.all_breaks();
		foreach (BreakType break_type in all_breaks) {
			var status = break_type.status;
			if (status != null) {
				success = true;
				if (status.is_enabled) {
					break_type.status_panel.show();
					any_breaks_enabled = true;
				} else {
					break_type.status_panel.hide();
				}
			}
		}
		if (all_breaks.length() == 0) success = true;

		if (any_breaks_enabled) {
			this.set_visible_child(this.breaks_list);
		} else if (success || !this.break_manager.master_enabled) {
			this.set_visible_child(this.no_breaks_message);
		} else {
			this.set_visible_child(this.error_message);
		}
	}
}

