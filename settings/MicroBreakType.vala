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
		base("microbreak", settings);

		this.interval_options = {240, 360, 480, 600};
		this.duration_options = {15, 20, 25, 30, 45};

		
	}

	public override Gtk.Widget get_status_panel() {
		return new MicroBreakStatusPanel(this);
	}
	
	public override Gtk.Widget get_settings_panel() {
		return new MicroBreakSettingsPanel(this);
	}
}

class MicroBreakStatusPanel : TimerBreakStatusPanel {
	public MicroBreakStatusPanel(MicroBreakType break_type) {
		base(
			break_type,
			_("Your next microbreak is in"),
			_("It's time for a microbreak")
		);
	}
}

class MicroBreakSettingsPanel : TimerBreakSettingsPanel {
	public MicroBreakSettingsPanel(MicroBreakType break_type) {
		base(
			break_type,
			_("Micro Break"),
			_("Pause frequently to relax your eyes")
		);
	}
}

