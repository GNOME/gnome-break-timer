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

public class RestBreakType : TimerBreakType {
	private ActivityMonitor activity_monitor;

	public RestBreakType (ActivityMonitor activity_monitor) {
		Settings settings = new Settings ("org.gnome.BreakTimer.restbreak");
		base ("restbreak", settings);
		this.activity_monitor = activity_monitor;
	}

	protected override BreakController get_break_controller () {
		return new RestBreakController (
			this.activity_monitor
		);
	}

	protected override BreakView get_break_view (BreakController controller, UIManager ui_manager) {
		return new RestBreakView (
			(RestBreakController)controller,
			ui_manager
		);
	}
}