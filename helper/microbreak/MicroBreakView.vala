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

public class MicroBreakView : TimerBreakView {
	public MicroBreakView(MicroBreakController break_controller) {
		base(break_controller, FocusPriority.LOW);
		
		this.title = _("Micro break");
		
		this.status_widget.set_message("Take a moment to rest your eyes");
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
			summary = _("Time for a micro break"),
			body = null,
			icon = null
		};
	}
	
	public override BreakView.NotificationContent get_finish_notification() {
		return NotificationContent() {
			summary = _("Micro break finished"),
			body = null,
			icon = null
		};
	}
}

