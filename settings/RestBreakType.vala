/*
 * This file is part of GNOME Break Timer.
 * 
 * GNOME Break Timer is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * GNOME Break Timer is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with GNOME Break Timer.  If not, see <http://www.gnu.org/licenses/>.
 */

public class RestBreakType : TimerBreakType {
	public RestBreakType() {
		Settings settings = new Settings("org.gnome.break-timer.restbreak");
		base("restbreak", settings);

		this.interval_options = {1800, 2400, 3000, 3600};
		this.duration_options = {240, 300, 360,  480, 600};
	}

	protected override BreakInfoPanel get_info_panel() {
		return new RestBreakInfoPanel(this);
	}
	
	protected override BreakStatusPanel get_status_panel() {
		return new RestBreakStatusPanel(this);
	}

	protected override BreakSettingsPanel get_settings_panel() {
		return new RestBreakSettingsPanel(this);
	}
}

class RestBreakInfoPanel : BreakInfoPanel {
	const string DESCRIPTION_FORMAT = _(
"Take some time away from the computer. Stretch and move around.

Your break is scheduled to last for %s. I’ll remind you when your time is up.");

	public RestBreakInfoPanel(RestBreakType break_type) {
		base(
			break_type,
			_("Break")
		);

		this.set_heading(_("It’s break time"));
		break_type.notify["duration"].connect(this.update_description);
		this.update_description();
	}

	private void update_description() {
		var timer_break_type = (TimerBreakType)this.break_type;
		string break_duration = NaturalTime.instance.get_label_for_seconds(timer_break_type.duration);
		this.set_description(DESCRIPTION_FORMAT.printf(break_duration));
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
			_("Full break"),
			_("And take some longer breaks to stretch your legs")
		);
	}
}

