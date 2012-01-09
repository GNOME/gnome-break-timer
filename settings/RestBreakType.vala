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

public class RestBreakType : TimerBreakType {
	static string title = _("Rest Break");
	static string description = _("And take some longer breaks to stretch your legs");
	
	public RestBreakType() {
		Settings settings = new Settings("org.brainbreak.breaks.restbreak");
		base("restbreak", settings);
	}
	
	protected override BreakPanel make_settings_panel() {
		int[] interval_options = {1800, 2400, 3000, 3600};
		int[] duration_options = {300, 360, 420, 480, 540, 600};
		TimerBreakPanel panel = new TimerBreakPanel(title, description, interval_options, duration_options);
		
		this.bind_to_settings_panel(panel);
		
		return panel;
	}
}

