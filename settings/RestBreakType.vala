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
	public RestBreakType () {
		Settings settings = new Settings ("org.gnome.break-timer.restbreak");
		base ("restbreak", settings);

		this.interval_options = { 1800, 2400, 3000, 3600 };
		this.duration_options = { 240, 300, 360, 480, 600 };
	}

	protected override BreakInfoPanel get_info_panel () {
		return new RestBreakInfoPanel (this);
	}
	
	protected override BreakStatusPanel get_status_panel () {
		return new RestBreakStatusPanel (this);
	}

	protected override BreakSettingsPanel get_settings_panel () {
		return new RestBreakSettingsPanel (this);
	}
}

class RestBreakInfoPanel : BreakInfoPanel {
	private TimerBreakStatus? status;

	public RestBreakInfoPanel (RestBreakType break_type) {
		base (
			break_type,
			_("Break")
		);

		break_type.notify["duration"].connect (this.update_description);
		break_type.timer_status_changed.connect (this.timer_status_changed_cb);
	}

	private void timer_status_changed_cb (TimerBreakStatus? status) {
		this.status = status;
		this.update_description ();
	}

	private void update_description () {
		if (this.status == null) return;

		int time_remaining_value;
		string time_remaining_text = NaturalTime.instance.get_countdown_for_seconds_with_start (
			this.status.time_remaining, this.status.current_duration, out time_remaining_value);
		string detail_text = ngettext (
			/* %s will be replaced with a string that describes a time interval, such as "2 minutes", "40 seconds" or "1 hour" */
			"Your break has %s remaining. I’ll remind you when it’s over.",
			"Your break has %s remaining. I’ll remind you when it’s over.",
			time_remaining_value
		).printf (time_remaining_text);

		this.set_heading ( _("It’s break time"));
		this.set_description (_("Take some time away from the computer. Stretch and move around."));
		this.set_detail (detail_text);
	}
}

class RestBreakStatusPanel : TimerBreakStatusPanel {
	public RestBreakStatusPanel (RestBreakType break_type) {
		base (
			break_type,
			/* Label that explains a countdown timer, which shows a string such as "30 minutes" */
			_("Your next full break is in"),
			_("It's break time")
		);
	}
}

class RestBreakSettingsPanel : TimerBreakSettingsPanel {
	public RestBreakSettingsPanel (RestBreakType break_type) {
		base (
			break_type,
			_("Full break"),
			_("And take some longer breaks to stretch your legs")
		);
	}
}