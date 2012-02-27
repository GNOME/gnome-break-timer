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
	private BreakFocusManager focus_manager;
	private Gee.Map<string, BreakType> breaks;
	
	public BreakManager() {
		this.focus_manager = new BreakFocusManager();
		this.breaks = new Gee.HashMap<string, BreakType>();
		
		this.register_break(new MicroBreakType(this.focus_manager));
		this.register_break(new RestBreakType(this.focus_manager));
	}
	
	private void break_enable_change(Break brk) {
		bool enabled = brk.settings.get_boolean("enabled");
		brk.set_enabled(enabled);
	}
	
	private void register_break(BreakType break_type) {
		this.breaks.set(break_type.id, break_type);
		
		Break brk = break_type.brk;
		
		// FIXME: Breaks are currently enabled by their own settings.
		// Instead, enabled breaks should be stored in a list somewhere.
		brk.settings.changed["enabled"].connect(() => {
			brk.set_enabled(brk.settings.get_boolean("enabled"));
		});
		brk.set_enabled(brk.settings.get_boolean("enabled"));
	}
	
	public FocusManager<BreakType> get_focus_manager() {
		return this.focus_manager;
	}
	
	public Gee.Iterable<BreakType> get_all_breaks() {
		return this.breaks.values;
	}
	
	[Deprecated]
	public Break get_break_for_name(string name) {
		return this.breaks.get(name).brk;
	}
	
	public BreakType get_break_type_for_name(string name) {
		return this.breaks.get(name);
	}
}

