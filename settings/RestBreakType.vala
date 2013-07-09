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
	public RestBreakType() {
		Settings settings = new Settings("org.brainbreak.breaks.restbreak");
		base("restbreak", settings);

		this.interval_options = {1800, 2400, 3000, 3600};
		this.duration_options = {300, 360, 420, 480, 540, 600};
	}
	
	public override Gtk.Widget get_status_panel() {
		return new RestBreakStatusPanel(this);
	}

	public override Gtk.Widget get_settings_panel() {
		return new RestBreakSettingsPanel(this);
	}
}

class RestBreakStatusPanel : TimerBreakStatusPanel {
	public RestBreakStatusPanel(RestBreakType break_type) {
		base(
			break_type,
			_("Your next full break is in"),
			_("It's break time")
		);
	}
}

class RestBreakSettingsPanel : TimerBreakSettingsPanel {
	public RestBreakSettingsPanel(RestBreakType break_type) {
		base(
			break_type,
			_("Rest Break"),
			_("And take some longer breaks to stretch your legs")
		);
	}
}

