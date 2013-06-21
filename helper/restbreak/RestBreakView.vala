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
	private string[] rest_quotes;
	
	public RestBreakView(BreakType break_type, RestBreakController rest_break, UIManager ui_manager) {
		base(break_type, rest_break, ui_manager);
		
		this.title = _("Rest break");
		
		this.rest_quotes = {
			_("The quieter you become, the more you can hear."),
			_("Knock on the sky and listen to the sound."),
			_("So little time, so little to do."),
			_("Sometimes the questions are complicated and the answers are simple."),
			_("You cannot step into the same river twice."),
			_("The obstacle is the path."),
			_("No snowflake ever falls in the wrong place."),
			_("The energy of the mind is the essence of life.")
		};
		
		this.overlay_started.connect(this.overlay_started_cb);

		rest_break.warned.connect(this.warned_cb);
		rest_break.unwarned.connect(this.unwarned_cb);
		rest_break.activated.connect(this.activated_cb);
		rest_break.finished.connect(this.finished_cb);
	}

	private void warned_cb() {
		this.request_ui_focus(FocusPriority.HIGH);
	}

	private void unwarned_cb() {
		this.release_ui_focus();
	}

	private void activated_cb() {
		this.request_ui_focus(FocusPriority.HIGH);
	}

	private void finished_cb() {
		this.release_ui_focus();

		if (ui_manager.is_focusing(this) && ! ui_manager.break_overlay.is_showing()) {
			BreakView.NotificationContent notification_content = this.get_finish_notification();
			ui_manager.show_notification(notification_content, Notify.Urgency.LOW);
		}
	}

	protected override void show_active_ui() {
		if (ui_manager.break_overlay.is_showing()) {
			ui_manager.break_overlay.show_with_source(this);
			GLib.debug("show_break: replaced");
		} else {
			BreakView.NotificationContent notification_content = this.get_start_notification();
			ui_manager.show_notification(notification_content, Notify.Urgency.NORMAL);
			Timeout.add_seconds(this.get_lead_in_seconds(), () => {
				if (this.has_ui_focus() && this.break_controller.is_active()) {
					ui_manager.break_overlay.show_with_source(this);
				}
				return false;
			});
			GLib.debug("show_break: notified");
		}
	}

	protected override void hide_active_ui() {
		ui_manager.break_overlay.remove_source(this);
	}





	protected override string get_countdown_label(int time_remaining, int start_time) {
		NaturalTime natural_time = NaturalTime.get_instance();
		if (this.break_controller.is_active()) {
			return natural_time.get_countdown_for_seconds_with_start(time_remaining, start_time);
		} else {
			return _("Thank you");
		}
	}
	
	public override BreakView.NotificationContent get_start_notification() {
		return NotificationContent() {
			summary = _("Time for a rest break"),
			body = null,
			icon = null
		};
	}
	
	public override BreakView.NotificationContent get_finish_notification() {
		return NotificationContent() {
			summary = _("Rest break finished"),
			body = _("Thank you"),
			icon = null
		};
	}
	
	private void overlay_started_cb() {
		int quote_number = Random.int_range(0, this.rest_quotes.length);
		string random_quote = this.rest_quotes[quote_number];
		this.status_widget.set_message(random_quote);
	}
}

