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

public class BreakManager : Object {
	private UIManager ui_manager;

	private Gee.Map<string, BreakType> breaks;
	
	public BreakManager(UIManager ui_manager) {
		this.ui_manager = ui_manager;
		this.breaks = new Gee.HashMap<string, BreakType>();
	}
	
	private void add_break(BreakType break_type) {
		this.breaks.set(break_type.id, break_type);
		break_type.initialize();
		
		// TODO: At the moment, we expect breaks to enable and disable
		// themselves using their own settings. In the future, it might be
		// useful to have a global list of enabled break types, instead.
	}
	
	public void load_breaks() {
		IActivityMonitorBackend? activity_monitor_backend;
		try {
			activity_monitor_backend = new X11ActivityMonitorBackend();
		} catch {
			GLib.warning("Failed to initialize activity monitor backend");
			activity_monitor_backend = null;
		}
		
		if (activity_monitor_backend != null) {
			ActivityMonitor activity_monitor = new ActivityMonitor(activity_monitor_backend);
			this.add_break(new MicroBreakType(activity_monitor, this.ui_manager));
			this.add_break(new RestBreakType(activity_monitor, this.ui_manager));
		}
	}
	
	public Gee.Iterable<BreakType> all_breaks() {
		return this.breaks.values;
	}
	
	public BreakType? get_break_type_for_name(string name) {
		return this.breaks.get(name);
	}
}

