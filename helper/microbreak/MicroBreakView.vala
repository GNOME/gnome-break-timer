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
	protected MicroBreakController micro_break {
		get { return (MicroBreakController)this.break_controller; }
	}

	private bool notified_start = false;

	public MicroBreakView(BreakType break_type, MicroBreakController micro_break, UIManager ui_manager) {
		base(break_type, micro_break, ui_manager);
		this.focus_priority = FocusPriority.LOW;

		this.focused_and_activated.connect(this.focused_and_activated_cb);
		this.micro_break.finished.connect(this.finished_cb);
	}

	private void finished_cb(BreakController.FinishedReason reason) {
		if (reason == BreakController.FinishedReason.SATISFIED && this.notified_start && ! this.overlay_is_visible()) {
			Notify.Notification notification = new Notify.Notification(
				_("Break is over"),
				_("Your break time has ended"),
				null
			);
			if (SessionStatus.instance.is_locked()) {
				notification.set_urgency(Notify.Urgency.NORMAL);
				this.show_lock_notification(notification);
			} else {
				notification.set_hint("transient", true);
				notification.set_urgency(Notify.Urgency.LOW);
				this.show_notification(notification);
			}
			this.play_sound_from_id("complete");
		}

		this.notified_start = false;
	}

	private void notification_action_skip_cb() {
		this.micro_break.skip();
	}

	private void notification_action_info_cb() {
		this.show_break_info();
	}

	private void focused_and_activated_cb() {
		var status_widget = new TimerBreakStatusWidget(this.micro_break);
		status_widget.set_message(_("Take a moment to rest your eyes"));
		this.set_overlay(status_widget);

		if (! this.overlay_is_visible()) {
			Notify.Notification notification = new Notify.Notification(
				_("It’s time for a micro break"),
				_("Take a break from typing and look away from the screen"),
				null
			);
			notification.set_hint("sound-name", "message");
			notification.add_action("skip", _("Skip this one"), this.notification_action_skip_cb);
			notification.add_action("info", _("What should I do?"), this.notification_action_info_cb);
			notification.set_urgency(Notify.Urgency.NORMAL);
			this.show_notification(notification);
			
			this.notified_start = true;

			Timeout.add_seconds(this.get_lead_in_seconds(), () => {
				if (this.has_ui_focus() && this.micro_break.is_active()) {
					this.reveal_overlay();
				}
				return false;
			});
		}
	}
}

