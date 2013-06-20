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
	private Gee.Map<string, BreakType> breaks;
	
	public signal void break_loaded(BreakType break_type);
	
	public BreakManager() {
		this.breaks = new Gee.HashMap<string, BreakType>();
	}
	
	private void break_enable_change(BreakController break_controller) {
		bool enabled = break_controller.settings.get_boolean("enabled");
		break_controller.set_enabled(enabled);
	}
	
	private void register_break(BreakType break_type) {
		this.breaks.set(break_type.id, break_type);
		this.break_loaded(break_type);
		
		BreakController break_controller = break_type.break_controller;
		
		// FIXME: Breaks are currently enabled by their own settings.
		// Instead, enabled breaks should be stored in a list somewhere.
		break_controller.settings.changed["enabled"].connect(() => {
			break_controller.set_enabled(break_controller.settings.get_boolean("enabled"));
		});
		break_controller.set_enabled(break_controller.settings.get_boolean("enabled"));
	}
	
	public void load_breaks() {
		IActivityMonitorBackend activity_monitor_backend;
		try {
			activity_monitor_backend = new X11ActivityMonitorBackend();
		} catch {
			activity_monitor_backend = null;
		}
		
		if (activity_monitor_backend != null) {
			this.register_break(new MicroBreakType(activity_monitor_backend));
			this.register_break(new RestBreakType(activity_monitor_backend));
		}
	}
	
	public Gee.Iterable<BreakType> all_breaks() {
		return this.breaks.values;
	}
	
	public BreakType? get_break_type_for_name(string name) {
		return this.breaks.get(name);
	}
}

