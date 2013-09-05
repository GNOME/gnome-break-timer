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

public class TimerBreakStatusWidget : Gtk.Grid, IScreenOverlayContent {
	private TimerBreakController timer_break;

	private Gtk.Label timer_label;
	private Gtk.Label message_label;
	
	public TimerBreakStatusWidget (TimerBreakController timer_break) {
		Object ();
		this.timer_break = timer_break;
		
		this.set_column_spacing (12);
		this.set_row_spacing (12);
		
		this.timer_label = new Gtk.Label (null);
		this.attach (this.timer_label, 0, 0, 1, 1);
		Gtk.StyleContext timer_style = this.timer_label.get_style_context ();
		timer_style.add_class ("_timer-label");
		
		this.message_label = new Gtk.Label (null);
		this.attach (this.message_label, 0, 1, 1, 1);
		this.message_label.set_line_wrap (true);

		this.show_all ();
	}

	private void active_changed_cb () {
		int time_remaining = this.timer_break.get_time_remaining ();
		if (this.timer_break.is_active ()) {
			int start_time = this.timer_break.get_current_duration ();
			string countdown = NaturalTime.instance.get_countdown_for_seconds_with_start (
				time_remaining, start_time);
			this.timer_label.set_text (countdown);
		}
	}

	private void finished_cb (BreakController.FinishedReason reason) {
		if (reason == BreakController.FinishedReason.SATISFIED) {
			this.timer_label.set_text (_("Thank you"));
		}
	}

	private void update_content () {
		// Make sure the content being displayed is up to date. This is
		// usually called when the widget is about to appear.
		this.active_changed_cb ();
	}
	
	/** Set a reassuring message to accompany the break timer */
	public void set_message (string message) {
		this.message_label.set_text (message);
	}

	/* IScreenOverlayContent interface */

	public void added_to_overlay () {
		this.timer_break.active_changed.connect (this.active_changed_cb);
		this.timer_break.finished.connect (this.finished_cb);
		this.update_content ();
	}

	public void removed_from_overlay () {
		this.timer_break.active_changed.disconnect (this.active_changed_cb);
		this.timer_break.finished.disconnect (this.finished_cb);
	}

	public void before_fade_in () {
		this.update_content ();
	}

	public void before_fade_out () {
		this.update_content ();
	}
}