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

public class QuietMode : Object {
	private Settings settings;
	
	public bool active {get; set;}
	public int64 expire_time {get; set;}
	
	public QuietMode() {
		this.settings = new Settings("org.brainbreak.breaks");
		
		this.settings.bind("quiet-mode", this, "active", SettingsBindFlags.DEFAULT);
		this.settings.bind("quiet-mode-expire-time", this, "expire-time", SettingsBindFlags.DEFAULT);
	}
	
	public Gtk.Widget make_settings_panel() {
		QuietModePanel panel = new QuietModePanel();
		
		this.settings.bind("quiet-mode", panel.toggle_switch, "active", SettingsBindFlags.DEFAULT);
		this.settings.bind("quiet-mode-expire-time", panel, "expire-time", SettingsBindFlags.DEFAULT);
		
		panel.toggled.connect((enabled) => {
			if (enabled) {
				DateTime now = new DateTime.now_utc();
				DateTime later = now.add_hours(1);
				this.expire_time = later.to_unix();
				panel.start_countdown();
			} else {
				this.expire_time = 0;
				panel.end_countdown();
			}
		});
		
		return panel;
	}
}

