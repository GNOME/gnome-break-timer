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

class MicroBreakView : BreakView {
	private BreakOverlay break_overlay;
	
	public MicroBreakView(BreakViewCommon common, MicroBreak break_scheduler) {
		base(common, break_scheduler);
		
		break_scheduler.finished.connect(this.break_finished_cb);
		break_scheduler.active_update.connect(this.break_active_update_cb);
	}
	
	protected override void show_break_ui() {
		/** Initial notification period before more aggressive UI */
		
		Notify.Notification notification = new Notification("Micro break", "It's time for a short break.", null);
		notification.set_urgency(Notify.Urgency.CRITICAL);
		notification.show();
		Timeout.add_seconds(5, () => {
			notification.close();
			/* show the big break message, hook up to active_timeout */
			this.show_break_overlay();
			return false;
		});
	}
	
	protected override void hide_break_ui() {
		if (this.break_overlay != null) {
			this.break_overlay.destroy();
			this.break_overlay = null;
		}
	}
	
	private void break_finished_cb() {
		/* TODO: show notification if break dialog was not shown */
		/* FIXME: tell gnome shell this notification is transient! */
		/*Notify.Notification notification = new Notification("Micro break finished", "", null);
		notification.set_urgency(Notify.Urgency.LOW);
		notification.show();*/
	}
	
	private void show_break_overlay() {
		/* FIXME: ask the application for a break dialog. That way RestView can take it over as necessary */
		if (this.break_is_active()) {
			this.break_overlay = new BreakOverlay();
		
			this.break_overlay.set_title("Micro break");
			this.break_overlay.set_message("Just give your eyes and your fingers a moment of rest");
			this.break_overlay.show_all();
		}
	}
	
	private void update_break_overlay(int time_remaining) {
		stdout.printf("Pause break. %f remaining\n", time_remaining);
		if (this.break_overlay != null) {
			string label_text = TimerString.get_countdown_for_seconds(time_remaining);
			this.break_overlay.set_timer(label_text);
		}
	}
	
	private void break_active_update_cb(int time_remaining) {
		this.update_break_overlay(time_remaining);
	}
}
