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

public class TimerBreakStatusWidget : Gtk.Grid {
	private TimerBreakController timer_break;

	private Gtk.Label timer_label;
	private Gtk.Label message_label;
	
	public TimerBreakStatusWidget(TimerBreakController timer_break) {
		Object();
		this.timer_break = timer_break;
		
		this.set_column_spacing(12);
		this.set_row_spacing(12);
		
		this.timer_label = new Gtk.Label(null);
		this.attach(this.timer_label, 0, 0, 1, 1);
		Gtk.StyleContext timer_style = this.timer_label.get_style_context();
		timer_style.add_class("brainbreak-timer-label");
		
		this.message_label = new Gtk.Label(null);
		this.attach(this.message_label, 0, 1, 1, 1);
		this.message_label.set_line_wrap(true);

		this.show_all();

		this.timer_break.active_countdown_changed.connect(this.active_countdown_changed_cb);
		// Make sure visible time is correct when the widget first appears,
		// to avoid stammering
		int time_remaining = this.timer_break.get_time_remaining();
		this.active_countdown_changed_cb(time_remaining);
	}

	private void active_countdown_changed_cb(int time_remaining) {
		int start_time = this.timer_break.get_current_duration();
		string countdown = this.get_countdown_text(time_remaining, start_time);
		this.timer_label.set_text(countdown);
	}

	private string get_countdown_text(int time_remaining, int start_time) {
		NaturalTime natural_time = NaturalTime.get_instance();
		if (this.timer_break.is_active()) {
			return natural_time.get_countdown_for_seconds_with_start(time_remaining, start_time);
		} else {
			return _("Thank you");
		}
	}
	
	/** Set a reassuring message to accompany the break timer */
	public void set_message(string message) {
		this.message_label.set_text(message);
	}
}

