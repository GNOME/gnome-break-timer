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

using Notify;

class TimerString : Object {
	private const string second_remaining_template = "%d second";
	private const string seconds_remaining_template = "%d seconds";
	private const string minute_remaining_template = "%d minute";
	private const string minutes_remaining_template = "%d minutes";
	
	public static string get_countdown_for_seconds (int seconds) {
		/* FIXME: handle plurals, nicely */
		int remaining;
		int interval;
		
		if (seconds < 10) {
			interval = 1;
		} else if (seconds < 30) {
			interval = 5;
		} else if (seconds < 60) {
			interval = 10;
		} else {
			interval = 60;
		}
		
		remaining = (int)((seconds + interval - 1) / interval);
		
		if (interval == 60) {
			return minutes_remaining_template.printf(remaining);
		} else {
			return seconds_remaining_template.printf(remaining * interval);
		}
	}
}

class PauseView : Object {
	private BreakOverlay break_overlay;
	private Gtk.Label timer_label;
	
	public PauseView(PauseScheduler scheduler) {
		scheduler.started.connect(this.break_started_cb);
		scheduler.finished.connect(this.break_finished_cb);
		scheduler.active_update.connect(this.break_active_update_cb);
	}
	
	private void show_break_overlay() {
		/* FIXME: ask the application for a break dialog. That way RestView can take it over as necessary */
		break_overlay = new BreakOverlay();
		
		break_overlay.set_title("Micro break");
		
		Gtk.Alignment alignment = new Gtk.Alignment(0.5f, 0.5f, 1.0f, 1.0f);
		alignment.set_padding(8, 8, 12, 12);
		Gtk.VBox container = new Gtk.VBox(false, 12);
		
		Gtk.Label break_message = new Gtk.Label("Just give your eyes and your fingers a moment of rest");
		Gtk.Label timer_label = new Gtk.Label("");
		Gtk.StyleContext timer_style = timer_label.get_style_context();
		timer_style.add_class("timer_label");
		
		container.pack_end(break_message, false);
		container.pack_end(timer_label, true);
		
		alignment.add(container);
		break_overlay.add(alignment);
		
		break_overlay.show_all();
		
		this.timer_label = timer_label;
	}
	
	private void update_break_overlay(int time_remaining) {
		stdout.printf("Pause break. %f remaining\n", time_remaining);
		if (this.timer_label != null) {
			string new_label_text = TimerString.get_countdown_for_seconds(time_remaining);
			this.timer_label.set_text(new_label_text);
		}
	}
	
	private void hide_break_overlay() {
		if (this.break_overlay != null) {
			this.break_overlay.destroy();
			this.break_overlay = null;
		}
	}
	
	private void break_started_cb() {
		/** Initial notification period before more aggressive UI */
		Notify.Notification notification = new Notification("Micro break", "It's time for a short break.", null);
		notification.set_urgency(Notify.Urgency.CRITICAL);
		notification.show();
		Timeout.add_seconds(5, () => {
			notification.close();
			stdout.printf("Notification closed?");
			/* show the big break message, hook up to active_timeout */
			this.show_break_overlay();
			return false;
		});
	}
	
	private void break_active_update_cb(int time_remaining) {
		this.update_break_overlay(time_remaining);
	}
	
	private void break_finished_cb() {
		/* TODO: show notification only if break dialog was not visible */
		/* FIXME: tell gnome shell this notification is transient! */
		Notify.Notification notification = new Notification("Micro break finished", "", null);
		notification.set_urgency(Notify.Urgency.LOW);
		notification.show();
		
		this.hide_break_overlay();
	}
}
