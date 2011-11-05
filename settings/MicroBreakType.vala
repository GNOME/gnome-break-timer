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

public class MicroBreakType : TimerBreakType {
	public MicroBreakType() {
		Settings settings = new Settings("org.brainbreak.breaks.microbreak");
		string name = _("Micro break");
		base(settings, name);
	}
	
	public override Gtk.Widget make_settings_panel() {
		int[] interval_options = {480, 600, 720, 900};
		int[] duration_options = {15, 20, 30, 45, 60};
		TimerBreakPanel panel = new TimerBreakPanel(this.name, interval_options, duration_options);
		
		this.bind_to_settings_panel(panel);
		
		return panel;
	}
}

