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
	protected Settings settings;
	
	public string name {get; private set;}
	public bool enabled {get; set; default=true;}
	public int interval {get; set;}
	
	public BreakType(Settings settings, string name) {
		this.settings = settings;
		this.name = name;
		this.settings.bind("enabled", this, "enabled", SettingsBindFlags.DEFAULT);
		this.settings.bind("interval-seconds", this, "interval", SettingsBindFlags.DEFAULT);
	}
	
	public abstract Gtk.Widget make_settings_panel();
	
	protected void bind_to_settings_panel(BreakPanel panel) {
		this.settings.bind("enabled", panel.toggle_switch, "active", SettingsBindFlags.DEFAULT);
	}
}

