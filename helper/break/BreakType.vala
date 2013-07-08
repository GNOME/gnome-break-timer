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
	public BreakController break_controller;
	public BreakView break_view;

	protected Settings settings;
	
	public BreakType(string id, Settings settings) {
		this.id = id;
		this.settings = settings;
	}

	public virtual void initialize(UIManager ui_manager) {
		this.break_controller = this.get_break_controller(this.settings);
		this.break_view = this.get_break_view(this.break_controller, ui_manager);

		this.settings.changed["enabled"].connect(() => {
			this.break_controller.set_enabled(this.settings.get_boolean("enabled"));
		});
		this.break_controller.set_enabled(this.settings.get_boolean("enabled"));
	}

	protected abstract BreakController get_break_controller(Settings settings);
	protected abstract BreakView get_break_view(BreakController controller, UIManager ui_manager);
}
