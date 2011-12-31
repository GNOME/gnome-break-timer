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
	private Gtk.Label timer_label;
	private Gtk.Label message_label;
	
	public TimerBreakStatusWidget() {
		Object();
		
		this.set_column_spacing(12);
		this.set_row_spacing(12);
		
		Gtk.Label timer_label = new Gtk.Label(null);
		Gtk.StyleContext timer_style = timer_label.get_style_context();
		timer_style.add_class("brainbreak-timer-label");
		
		Gtk.Label message_label = new Gtk.Label(null);
		
		this.attach(timer_label, 0, 0, 1, 1);
		this.attach(message_label, 0, 1, 1, 1);
		
		this.timer_label = timer_label;
		this.message_label = message_label;
		
		this.show_all();
	}
	
	/** Set a reassuring message to accompany the break timer */
	public void set_message(string message) {
		this.message_label.set_text(message);
	}
	
	/** Set the time remaining */
	public void set_time(string time) {
		this.timer_label.set_text(time);
	}
}

