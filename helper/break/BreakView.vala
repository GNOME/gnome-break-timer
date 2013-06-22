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

public abstract class BreakView : Object {
	protected BreakType break_type;
	protected BreakController break_controller {get; private set;}
	protected UIManager ui_manager;
	
	public struct NotificationContent {
		public string summary;
		public string? body;
		public string? icon;
	}
	
	public BreakView(BreakType break_type, BreakController break_controller, UIManager ui_manager) {
		this.break_type = break_type;
		this.break_controller = break_controller;
		this.ui_manager = ui_manager;

		break_controller.enabled.connect(() => {
			this.ui_manager.add_break(this);
		});

		break_controller.disabled.connect(() => {
			this.ui_manager.remove_break(this);
		});
	}

	public string get_id() {
		return this.break_type.id;
	}
	
	protected void request_ui_focus(FocusPriority priority) {
		if (this.has_ui_focus()) {
			// If we already gained focus earlier, UIManager will not call
			// begin_ui_focus again - we need to call it ourselves
			this.begin_ui_focus();
		} else {
			this.ui_manager.request_focus(this, priority);
		}
	}
	
	protected void release_ui_focus() {
		this.ui_manager.release_focus(this);
	}

	public void begin_ui_focus() {
		if (this.break_controller.is_active()) {
			this.show_active_ui();
		}
	}

	public void end_ui_focus() {
		this.hide_active_ui();
	}

	protected bool has_ui_focus() {
		return this.ui_manager.is_focusing(this);
	}

	protected abstract void show_active_ui();
	protected abstract void hide_active_ui();

	


	public abstract string get_status_message();
	
	public abstract NotificationContent get_start_notification();
	public abstract NotificationContent get_finish_notification();
}

