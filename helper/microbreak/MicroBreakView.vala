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

/* TODO: notification when user is away for rest duration */
/* TODO: replace pause break if appropriate */

public class MicroBreakView : TimerBreakView {
	private TimerBreakStatusWidget? status_widget;

	public MicroBreakView(BreakType break_type, MicroBreakController micro_break, UIManager ui_manager) {
		base(break_type, micro_break, ui_manager);

		micro_break.warned.connect(this.warned_cb);
		micro_break.unwarned.connect(this.unwarned_cb);
		micro_break.activated.connect(this.activated_cb);
		micro_break.finished.connect(this.finished_cb);
	}

	private void warned_cb() {
		this.request_ui_focus(FocusPriority.LOW);
	}

	private void unwarned_cb() {
		this.release_ui_focus();
	}

	private void activated_cb() {
		this.request_ui_focus(FocusPriority.LOW);
	}

	private void finished_cb() {
		if (this.has_ui_focus()) {
			if (! ui_manager.screen_overlay.is_showing_content(this.status_widget)) {
				BreakView.NotificationContent notification_content = this.get_finish_notification();
				ui_manager.show_notification(notification_content, Notify.Urgency.LOW);
			}
		}
		this.release_ui_focus();
	}

	private void build_screen_overlay() {
		this.status_widget = new TimerBreakStatusWidget((TimerBreakController)this.break_controller);
		this.status_widget.set_message(_("Take a moment to rest your eyes"));
		ui_manager.screen_overlay.reveal_content(this.status_widget);
	}

	protected override void show_active_ui() {
		if (ui_manager.screen_overlay.is_showing()) {
			this.build_screen_overlay();
			GLib.debug("show_break: replaced");
		} else {
			BreakView.NotificationContent notification_content = this.get_start_notification();
			ui_manager.show_notification(notification_content, Notify.Urgency.NORMAL);
			Timeout.add_seconds(this.get_lead_in_seconds(), () => {
				if (this.has_ui_focus() && this.break_controller.is_active()) {
					this.build_screen_overlay();
				}
				return false;
			});
			GLib.debug("show_break: notified");
		}
	}

	protected override void hide_active_ui() {
		ui_manager.screen_overlay.disappear_content(this.status_widget);
	}




	
	
	public override BreakView.NotificationContent get_start_notification() {
		return NotificationContent() {
			summary = _("Time for a micro break"),
			body = null,
			icon = null
		};
	}
	
	public override BreakView.NotificationContent get_finish_notification() {
		return NotificationContent() {
			summary = _("Micro break finished"),
			body = null,
			icon = null
		};
	}
}

