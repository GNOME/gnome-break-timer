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

public abstract class TimerBreakType : BreakType {
	private BreakHelper_TimerBreakServer break_type_server;

	public TimerBreakType(string id, Settings settings) {
		base(id, settings);
	}

	protected override void initialize(UIManager ui_manager) {
		base.initialize(ui_manager);

		this.break_type_server = new BreakHelper_TimerBreakServer(
			(TimerBreakController)this.break_controller
		);
		string object_path = "/org/brainbreak/Breaks/%s".printf(this.id);
		try {
			DBusConnection connection = Bus.get_sync(BusType.SESSION, null);
			connection.register_object (object_path, break_type_server);
		} catch (IOError error) {
			GLib.error("Error registering break type on the session bus: %s", error.message);
		}
	}
}

[DBus (name = "org.brainbreak.Breaks.TimerBreak")]
private class BreakHelper_TimerBreakServer : Object, IBreakHelper_TimerBreak {
	// FIXME: this used to implement IBreakHelper, but currently
	// it does not due to a problem detected by Debian's build log filter.
	private TimerBreakController break_controller;
	
	public BreakHelper_TimerBreakServer(TimerBreakController break_controller) {
		this.break_controller = break_controller;
	}
	
	public TimerBreakStatus get_status() {
		return TimerBreakStatus() {
			is_active = this.break_controller.is_active(),
			starts_in = this.break_controller.starts_in(),
			time_remaining = this.break_controller.get_time_remaining(),
			current_duration = this.break_controller.get_current_duration()
		};
	}

	public void activate() {
		this.break_controller.activate();
	}
}
