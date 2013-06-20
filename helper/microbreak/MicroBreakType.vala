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

public class MicroBreakType : BreakType {
	public MicroBreakType(IActivityMonitorBackend activity_monitor_backend) {
		MicroBreakController break_controller = new MicroBreakController(activity_monitor_backend);
		MicroBreakView break_view = new MicroBreakView(break_controller);
		base("microbreak", break_controller, break_view);
	}
}

