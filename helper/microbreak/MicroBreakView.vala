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

/* TODO: notification when user is away for rest duration */
/* TODO: replace pause break if appropriate */

public class MicroBreakView : TimerBreakView {
	protected MicroBreakController micro_break {
		get { return (MicroBreakController)this.break_controller; }
	}

	public MicroBreakView(BreakType break_type, MicroBreakController micro_break, UIManager ui_manager) {
		base(break_type, micro_break, ui_manager);
		this.focus_priority = FocusPriority.LOW;

		this.focused_and_activated.connect(this.focused_and_activated_cb);
		this.lost_ui_focus.connect(this.lost_ui_focus_cb);
		this.micro_break.finished.connect(this.finished_cb);
	}

	protected new void show_break_notification(Notify.Notification notification) {
		notification.add_action("skip", _("Skip this one"), this.notification_action_skip_cb);
		base.show_break_notification(notification);
	}

	private void show_start_notification() {
		var notification = this.build_common_notification(
			_("It’s time for a micro break"),
			_("Take a break from typing and look away from the screen"),
			"alarm-symbolic"
		);
		notification.set_urgency(Notify.Urgency.NORMAL);
		notification.set_hint("sound-name", "message");
		this.show_break_notification(notification);
	}

	private void show_overdue_notification() {
		int time_since_start = this.micro_break.get_seconds_since_start();
		string delay_string = NaturalTime.instance.get_simplest_label_for_seconds(
			time_since_start);
		var notification = this.build_common_notification(
			_("Overdue break"),
			_("You were due to take a break %s ago").printf(delay_string),
			"alarm-symbolic"
		);
		notification.set_urgency(Notify.Urgency.NORMAL);
		this.show_break_notification(notification);
	}

	private void show_finished_notification() {
		var notification = this.build_common_notification(
			_("Break is over"),
			_("Your break time has ended"),
			"alarm-symbolic"
		);
		notification.set_urgency(Notify.Urgency.NORMAL);
		this.show_lock_notification(notification);

		this.play_sound_from_id("complete");
	}

	private void focused_and_activated_cb() {
		var status_widget = new TimerBreakStatusWidget(this.micro_break);
		status_widget.set_message(_("Take a moment to rest your eyes"));
		this.set_overlay(status_widget);

		if (! this.overlay_is_visible()) {
			this.show_start_notification();

			Timeout.add_seconds(this.get_lead_in_seconds(), () => {
				this.reveal_overlay();
				return false;
			});
		}

		this.micro_break.delayed.connect(this.delayed_cb);
	}

	private void lost_ui_focus_cb() {
		this.micro_break.delayed.disconnect(this.delayed_cb);
	}

	private void finished_cb(BreakController.FinishedReason reason, bool was_active) {
		if (reason == BreakController.FinishedReason.SATISFIED && was_active) {
			this.show_finished_notification();
		} else {
			this.hide_notification();
		}
	}

	private void delayed_cb(int lap_time, int total_time) {
		if (total_time > this.micro_break.interval) {
			this.show_overdue_notification();
		}
	}

	private void notification_action_skip_cb() {
		this.break_controller.skip();
	}
}

