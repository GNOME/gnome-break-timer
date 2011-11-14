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
	private BreakStatusServer status_server;
	
	private FocusManager focus_manager;
	private Gee.Map<string, Break> breaks;
	
	public BreakManager(UIManager ui_manager) {
		this.ui_manager = ui_manager;
		
		this.focus_manager = new FocusManager();
		this.breaks = new Gee.HashMap<string, Break>();
		
		this.register_break("restbreak", new RestBreak(this.focus_manager));
		this.register_break("microbreak", new MicroBreak(this.focus_manager));
		
		DBusConnection connection = Bus.get_sync(BusType.SESSION, null);
		this.status_server = new BreakStatusServer(this);
		connection.register_object ("/org/brainbreak/Helper/Status", this.status_server);
	}
	
	private void register_break(string name, Break brk) {
		this.breaks.set(name, brk);
		this.ui_manager.watch_break(brk);
		
		// FIXME: Breaks are currently enabled by their own settings.
		// Instead, enabled breaks should be stored in a list somewhere.
		brk.settings.bind("enabled", brk, "enabled", SettingsBindFlags.GET);
	}
	
	public Break get_break_for_name(string name) {
		return this.breaks.get(name);
	}
}

[DBus (name = "org.brainbreak.Helper.Status")]
public class BreakStatusServer : Object {
	private BreakManager break_manager;
	
	public BreakStatusServer(BreakManager break_manager) {
		this.break_manager = break_manager;
	}
	
	public string get_status_for_break(string break_name) {
		Break brk = this.break_manager.get_break_for_name(break_name);
		return brk.get_view().get_status_message();
	}
}

