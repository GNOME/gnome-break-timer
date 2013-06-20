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
	string[] rest_quotes;
	
	public RestBreakView(RestBreakController break_controller) {
		base(break_controller, FocusPriority.HIGH);
		
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
	}

	protected override string get_countdown_label(int time_remaining, int start_time) {
		NaturalTime natural_time = NaturalTime.get_instance();
		if (time_remaining > 0) {
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

