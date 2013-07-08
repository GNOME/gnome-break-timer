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

public class MicroBreakType : TimerBreakType {
	private BreakHelper_TimerBreakServer break_type_server;

	private ActivityMonitor activity_monitor;

	public MicroBreakType(ActivityMonitor activity_monitor) {
		Settings settings = new Settings("org.brainbreak.breaks.microbreak");
		base("microbreak", settings);
		this.activity_monitor = activity_monitor;
	}

	protected override BreakController get_break_controller(Settings settings) {
		return new MicroBreakController(
			this,
			settings,
			this.activity_monitor
		);
	}

	protected override BreakView get_break_view(BreakController controller, UIManager ui_manager) {
		return new MicroBreakView(
			this,
			(MicroBreakController)controller,
			ui_manager
		);
	}
}
