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

public abstract class TimerBreakType : BreakType {
	public int duration {get; set;}
	
	protected int[] interval_options;
	protected int[] duration_options;
	
	public TimerBreakType(Settings settings, string name) {
		base(settings, name);
		
		this.settings.bind("duration-seconds", this, "duration", SettingsBindFlags.DEFAULT);
	}
	
	protected new void bind_to_settings_panel(TimerBreakPanel panel) {
		base.bind_to_settings_panel(panel);
		this.settings.bind("interval-seconds", panel.interval_chooser, "time-seconds", SettingsBindFlags.DEFAULT);
		this.settings.bind("duration-seconds", panel.duration_chooser, "time-seconds", SettingsBindFlags.DEFAULT);
	}
}

