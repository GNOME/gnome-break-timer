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

public class RestBreakView : TimerBreakView {
	protected RestBreakController rest_break {
		get { return (RestBreakController)this.break_controller; }
	}

	private string[] rest_quotes = {
		_("The quieter you become, the more you can hear."),
		_("Knock on the sky and listen to the sound."),
		_("So little time, so little to do."),
		_("Sometimes the questions are complicated and the answers are simple."),
		_("You cannot step into the same river twice."),
		_("The obstacle is the path."),
		_("No snowflake ever falls in the wrong place."),
		_("The energy of the mind is the essence of life.")
	};

	private bool proceeding_happily;
	
	public RestBreakView(BreakType break_type, RestBreakController rest_break, UIManager ui_manager) {
		base(break_type, rest_break, ui_manager);
		this.focus_priority = FocusPriority.HIGH;

		rest_break.activated.connect(this.activated_cb);
		rest_break.finished.connect(this.finished_cb);
		rest_break.counting.connect(this.counting_cb);
		rest_break.delayed.connect(this.delayed_cb);
		rest_break.attention_demanded.connect(this.attention_demanded_cb);
	}

	private void activated_cb() {
		this.proceeding_happily = false;
	}

	private void finished_cb(BreakController.FinishedReason reason) {
		if (! this.overlay_is_visible() && reason == BreakController.FinishedReason.SATISFIED) {
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
		}
	}

	private void counting_cb(int time_counting) {
		this.proceeding_happily = time_counting > 20;
	}

	private void delayed_cb(int time_delayed) {
		if (this.proceeding_happily) {
			// Show a "Break interrupted" notification if the break has been
			// counting down happily for a while

			this.proceeding_happily = false;

			int time_remaining = this.rest_break.get_time_remaining();
			int start_time = this.rest_break.get_current_duration();
			string countdown = NaturalTime.instance.get_countdown_for_seconds_with_start(
				time_remaining, start_time);

			Notify.Notification notification = new Notify.Notification(
				_("Break interrupted"),
				_("%s of break remaining").printf(countdown),
				null
			);
			notification.set_hint("transient", true);
			notification.set_urgency(Notify.Urgency.CRITICAL);
			this.show_notification(notification);
		}
	}

	private void attention_demanded_cb() {
		this.shake_overlay();
	}

	private void notification_action_delay_cb() {
		// TODO: Don't bother the user for a while
		// Show another notification in a minute or so
	}

	protected override void show_active_ui() {
		var status_widget = new TimerBreakStatusWidget(this.rest_break);
		int quote_number = Random.int_range(0, this.rest_quotes.length);
		string random_quote = this.rest_quotes[quote_number];
		status_widget.set_message(random_quote);
		this.set_overlay(status_widget);

		if (! this.overlay_is_visible()) {
			// FIXME: This should say something like "It's time to take a 5 minute break..."
			Notify.Notification notification = new Notify.Notification(
				_("Time for a break"),
				_("It’s time to take a break. Get away from the computer for a little while!"),
				null
			);
			notification.add_action("delay", _("Remind me later"), this.notification_action_delay_cb);
			notification.set_urgency(Notify.Urgency.CRITICAL);
			this.show_notification(notification);

			Timeout.add_seconds(this.get_lead_in_seconds(), () => {
				if (this.has_ui_focus() && this.break_controller.is_active()) {
					this.reveal_overlay();
				}
				return false;
			});
		}
	}
}

