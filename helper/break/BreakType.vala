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
	protected Settings global_settings;
	
	public BreakType(string id, Settings settings) {
		this.id = id;
		this.settings = settings;
		this.global_settings = new Settings("org.brainbreak.breaks");
	}

	public virtual void initialize(UIManager ui_manager) {
		this.break_controller = this.get_break_controller(this.settings);
		this.break_view = this.get_break_view(this.break_controller, ui_manager);

		this.global_settings.changed["master-enabled"].connect(this.update_enabled);
		this.settings.changed["enabled"].connect(this.update_enabled);
		this.update_enabled();
	}

	private void update_enabled() {
		bool is_enabled = this.global_settings.get_boolean("master-enabled") &&
			this.settings.get_boolean("enabled");
		this.break_controller.set_enabled(is_enabled);
	}

	protected abstract BreakController get_break_controller(Settings settings);
	protected abstract BreakView get_break_view(BreakController controller, UIManager ui_manager);
}
