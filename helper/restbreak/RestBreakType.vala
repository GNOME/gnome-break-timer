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

public class RestBreakType : BreakType {
	public RestBreakType(ActivityMonitor activity_monitor, UIManager ui_manager) {
		Settings settings = new Settings("org.brainbreak.breaks.restbreak");
		base("restbreak", settings);

		this.break_controller = new RestBreakController(this, settings, activity_monitor);
		this.break_view = new RestBreakView(this, (RestBreakController)this.break_controller, ui_manager);
	}
}

