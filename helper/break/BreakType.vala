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

public abstract class BreakType : Object {
	public string id;
	public Break brk;
	public BreakView view;
	
	public BreakType(string id, Break brk, BreakView view, FocusPriority priority, FocusManager<BreakType> focus_manager) {
		this.id = id;
		this.brk = brk;
		this.view = view;
		
		this.view.request_focus.connect(() => {
			focus_manager.request_focus(this, priority);
		});
		this.view.release_focus.connect(() => {
			focus_manager.release_focus(this);
		});
	}
}

