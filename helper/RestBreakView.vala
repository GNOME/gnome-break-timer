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

using Notify;

public class RestBreakView : TimerBreakView {
	string[] rest_quotes;
	
	public RestBreakView(RestBreak rest_break) {
		base(rest_break);
		
		this.title = _("Rest break");
		this.warn_time = 30;
		
		this.rest_quotes = {
			_("The quieter you become, the more you can hear."),
			_("Knock on the sky and Listen to the sound."),
			_("So little time, so little to do.")
		};
		
		this.overlay_started.connect(this.overlay_started_cb);
	}
	
	public override Notify.Notification get_start_notification() {
		Notify.Notification notification = new Notification(_("Time for a rest break"), null, null);
		return notification;
	}
	
	public override Notify.Notification get_finish_notification() {
		Notify.Notification notification = new Notification(_("Rest break finished"), _("Thank you"), null);
		return notification;
	}
	
	private void overlay_started_cb() {
		int quote_number = Random.int_range(0, this.rest_quotes.length);
		string random_quote = this.rest_quotes[quote_number];
		this.status_widget.set_message(random_quote);
	}
}

