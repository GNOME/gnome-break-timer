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
	private BreakManager break_manager;

	private Gd.HeaderBar header;
	private BreakSettingsDialog break_settings_dialog;
	private Gd.Stack main_stack;

	private WelcomePanel welcome_panel;
	private StatusPanel status_panel;

	public MainWindow(Application application, BreakManager break_manager) {
		Object(application: application);
		this.break_manager = break_manager;
		
		this.set_title(_("Break Timer"));
		this.set_hide_titlebar_when_maximized(true);

		Gtk.Builder builder = new Gtk.Builder ();
		try {
			builder.add_from_resource("/org/brainbreak/settings/settings-panels.ui");
		} catch (Error e) {
			GLib.error ("Error loading UI: %s", e.message);
		}

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
		break_manager.bind_property("master-enabled", master_switch, "active", BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE);

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
		main_stack.set_margin_top(20);
		main_stack.set_margin_right(20);
		main_stack.set_margin_bottom(20);
		main_stack.set_margin_left(20);

		this.status_panel = new StatusPanel(break_manager, builder);
		this.main_stack.add(this.status_panel);

		this.welcome_panel = new WelcomePanel(break_manager, builder);
		this.main_stack.add(this.welcome_panel);
		this.welcome_panel.tour_finished.connect(this.on_tour_finished);

		content.show_all();
		
		break_manager.break_added.connect(this.break_added_cb);
		break_manager.notify["foreground-break"].connect(this.update_visible_panel);
		this.update_visible_panel();
	}

	private void break_added_cb(BreakType break_type) {
		var info_panel = break_type.info_panel;
		this.main_stack.add(info_panel);
		info_panel.set_halign(Gtk.Align.CENTER);
		info_panel.set_valign(Gtk.Align.CENTER);
	}

	private void update_visible_panel() {
		// Use a transition when switching from the welcome panel
		// TODO: Once we switch to GtkStack, use set_visible_child_full
		if (this.main_stack.get_visible_child() == this.welcome_panel) {
			main_stack.set_transition_type(Gd.StackTransitionType.SLIDE_LEFT);
			main_stack.set_transition_duration(250);
		} else {
			main_stack.set_transition_type(Gd.StackTransitionType.NONE);
		}

		BreakType? foreground_break = this.break_manager.foreground_break;
		if (this.welcome_panel.is_active()) {
			this.main_stack.set_visible_child(this.welcome_panel);
			this.header.set_title(_("Welcome Tour"));
		} else if (foreground_break != null) {
			this.main_stack.set_visible_child(foreground_break.info_panel);
			this.header.set_title(foreground_break.info_panel.title);
		} else {
			this.main_stack.set_visible_child(this.status_panel);
			this.header.set_title(_("Break Timer"));
		}
	}

	private void on_tour_finished() {
		this.update_visible_panel();
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
		this.welcome_panel.settings_button_clicked();
	}
}

/* TODO: It would be nice to move some of this code to a UI file built with
 *       Glade. Especially anything involving long strings. */
private class WelcomePanel : Gd.Stack {
	private BreakManager break_manager;

	private enum Step {
		WELCOME,
		BREAKS,
		READY
	}
	private Step current_step;

	private Gtk.Widget start_page;
	private Gtk.Widget breaks_page;
	private Gtk.Widget ready_page;

	public WelcomePanel(BreakManager break_manager, Gtk.Builder builder) {
		this.break_manager = break_manager;

		if (this.break_manager.master_enabled) {
			this.current_step = Step.READY;
		} else {
			this.current_step = Step.WELCOME;
		}

		this.set_transition_type(Gd.StackTransitionType.SLIDE_LEFT);
		this.set_transition_duration(250);

		this.start_page = builder.get_object("welcome_start") as Gtk.Widget;
		this.add(this.start_page);

		this.breaks_page = builder.get_object("welcome_breaks") as Gtk.Widget;
		this.add(this.breaks_page);
		var breaks_ok_button = builder.get_object("welcome_breaks_ok_button") as Gtk.Button;
		breaks_ok_button.clicked.connect(this.on_breaks_confirmed);

		this.ready_page = builder.get_object("welcome_ready") as Gtk.Widget;
		this.add(this.ready_page);
		var ready_ok_button = builder.get_object("welcome_ready_ok_button") as Gtk.Button;
		ready_ok_button.clicked.connect(this.on_ready_confirmed);

		break_manager.notify["master-enabled"].connect(this.on_master_switch_toggled);
	}

	public signal void tour_finished();

	public bool is_active() {
		return this.current_step < Step.READY;
	}

	internal void settings_button_clicked() {
		if (this.current_step == Step.BREAKS) {
			this.on_breaks_confirmed();
		}
	}

	private void on_master_switch_toggled() {
		if (this.break_manager.master_enabled) {
			this.advance_current_step(Step.BREAKS);
		} else {
			// TODO: Should we jump back to the first step, or keep going?
		}
	}

	private void on_breaks_confirmed() {
		this.advance_current_step(Step.READY);
	}

	private void on_ready_confirmed() {
		this.tour_finished();
	}

	private void advance_current_step(Step next_step) {
		if (next_step > this.current_step) this.current_step = next_step;

		if (this.current_step == Step.WELCOME) {
			this.set_visible_child(this.start_page);
		} else if (this.current_step == Step.BREAKS) {
			this.set_visible_child(this.breaks_page);
		} else {
			this.set_visible_child(this.ready_page);
		}
	}
}

private class StatusPanel : Gd.Stack {
	private BreakManager break_manager;

	private Gtk.Grid breaks_list;
	private Gtk.Widget no_breaks_message;
	private Gtk.Widget error_message;

	public StatusPanel(BreakManager break_manager, Gtk.Builder builder) {
		// TODO: Once we port to Gtk.Stack, set property "homogenous: false"
		Object();

		this.break_manager = break_manager;

		this.margin = 12;
		this.set_hexpand(true);
		this.set_vexpand(true);

		this.breaks_list = this.build_breaks_list(break_manager);
		this.add(this.breaks_list);
		
		this.no_breaks_message = builder.get_object("status_stopped") as Gtk.Widget;
		this.add(this.no_breaks_message);

		this.error_message = builder.get_object("status_error") as Gtk.Widget;
		this.add(this.error_message);

		break_manager.break_added.connect(this.break_added_cb);
		break_manager.status_changed.connect(this.status_changed_cb);
	}

	private Gtk.Grid build_breaks_list(BreakManager break_manager) {
		var breaks_list = new Gtk.Grid();
		breaks_list.set_orientation(Gtk.Orientation.VERTICAL);
		breaks_list.set_halign(Gtk.Align.CENTER);
		breaks_list.set_valign(Gtk.Align.CENTER);

		return breaks_list;
	}

	private void break_added_cb(BreakType break_type) {
		var status_panel = break_type.status_panel;
		this.breaks_list.add(status_panel);
		status_panel.set_margin_top(18);
		status_panel.set_margin_bottom(18);
	}

	private void status_changed_cb() {
		bool any_breaks_enabled = false;

		unowned List<BreakType> all_breaks = this.break_manager.all_breaks();
		foreach (BreakType break_type in all_breaks) {
			var status = break_type.status;
			if (status != null) {
				if (status.is_enabled) {
					break_type.status_panel.show();
					any_breaks_enabled = true;
				} else {
					break_type.status_panel.hide();
				}
			}
		}

		if (any_breaks_enabled) {
			this.set_visible_child(this.breaks_list);
		} else if (this.break_manager.is_working()) {
			this.set_visible_child(this.no_breaks_message);
		} else {
			this.set_visible_child(this.error_message);
		}
	}
}

