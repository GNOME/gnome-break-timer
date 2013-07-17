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

public abstract class BreakView : UIManager.UIFragment {
	protected BreakType break_type;
	protected BreakController break_controller;

	/** The break is active and has been given UI focus */
	public signal void focused_and_activated();
	public signal void lost_ui_focus();
	
	public BreakView(BreakType break_type, BreakController break_controller, UIManager ui_manager) {
		this.ui_manager = ui_manager;
		this.break_type = break_type;
		this.break_controller = break_controller;

		break_controller.enabled.connect(() => { this.ui_manager.add_break(this); });
		break_controller.disabled.connect(() => { this.ui_manager.remove_break(this); });

		break_controller.warned.connect(() => { this.request_ui_focus(); });
		break_controller.unwarned.connect(() => { this.release_ui_focus(); });
		break_controller.activated.connect(() => { this.request_ui_focus(); });
		break_controller.finished.connect_after(() => { this.release_ui_focus(); });
	}

	public abstract string get_status_message();

	protected void show_break_info() {
		// TODO: Use dbus activation once we can depend on GLib >= 2.37
		AppInfo settings_app_info = new DesktopAppInfo("brainbreak-settings.desktop");
		AppLaunchContext app_launch_context = new AppLaunchContext();
		try {
			settings_app_info.launch(null, app_launch_context);
		} catch (Error error) {
			stderr.printf("Error launching settings application: %s\n", error.message);
		}
	}

	/* UIFragment interface */

	public override string get_id() {
		return this.break_type.id;
	}

	protected override void focus_started() {
		if (this.break_controller.is_active()) {
			this.focused_and_activated();
		}
		// else the break may have been given focus early. (See the BreakController.warned signal).
	}

	protected override void focus_stopped() {
		this.hide_overlay();
		this.lost_ui_focus();
		// We don't hide the current notification, because we might have a
		// "Finished" notification that outlasts the UIFragment
	}
}

