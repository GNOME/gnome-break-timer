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
	public RestBreakType(IActivityMonitorBackend activity_monitor_backend) {
		RestBreakController break_controller = new RestBreakController(activity_monitor_backend);
		RestBreakView break_view = new RestBreakView(break_controller);
		base("restbreak", break_controller, break_view);
	}
}

