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

public abstract class TimerBreakView : BreakView {
	protected TimerBreak timer_break;
	
	protected TimerBreakStatusWidget status_widget;
	
	public TimerBreakView(TimerBreak timer_break) {
		base(timer_break);
		
		this.timer_break = timer_break;
		
		this.status_widget = new TimerBreakStatusWidget();
		
		this.overlay_started.connect(this.overlay_started_cb);
		timer_break.break_update.connect(this.break_update_cb);
	}
	
	public override string get_status_message() {
		string message;
		if (this.timer_break.state < Break.State.ACTIVE) {
			int starts_in = this.timer_break.starts_in();
			if (starts_in < this.timer_break.interval) {
				message = _("Starts soon");
			} else {
				string start_time = NaturalTime.get_instance().get_countdown_for_seconds(starts_in);
				message = _("Starts in %s").printf(start_time);
			}
		} else if (this.timer_break.state == Break.State.ACTIVE) {
			int time_remaining = this.timer_break.get_time_remaining();
			string finish_time = NaturalTime.get_instance().get_countdown_for_seconds(time_remaining);
			message = _("Finishes in %s").printf(finish_time);
		} else {
			message = "";
		}
		return message;
	}
	
	public override Gtk.Widget get_overlay_content() {
		return this.status_widget;
	}
	
	private void break_update_cb(int time_remaining) {
		stdout.printf("Timer break. %f remaining\n", time_remaining);
		this.status_widget.set_time(time_remaining);
	}
	
	private void overlay_started_cb() {
		TimerBreak timer_break = (TimerBreak)this.break_scheduler;
		int time_remaining = timer_break.get_time_remaining();
		this.status_widget.set_time(time_remaining);
	}
}

