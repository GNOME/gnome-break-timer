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
	
	private FocusManager focus_manager;
	private Gee.Map<string, Break> breaks;
	
	public BreakManager(UIManager ui_manager) {
		this.ui_manager = ui_manager;
		
		this.focus_manager = new FocusManager();
		this.breaks = new Gee.HashMap<string, Break>();
		
		this.register_break("restbreak", new RestBreak(this.focus_manager));
		this.register_break("microbreak", new MicroBreak(this.focus_manager));
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

