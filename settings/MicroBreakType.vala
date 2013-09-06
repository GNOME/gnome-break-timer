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

public class MicroBreakType : TimerBreakType {
	public MicroBreakType () {
		Settings settings = new Settings ("org.gnome.break-timer.microbreak");
		base ("microbreak", settings);

		this.interval_options = { 240, 300, 360, 480, 600 };
		this.duration_options = { 15, 30, 45, 60 };
	}

	protected override BreakInfoPanel get_info_panel () {
		return new MicroBreakInfoPanel (this);
	}

	protected override BreakStatusPanel get_status_panel () {
		return new MicroBreakStatusPanel (this);
	}
	
	protected override BreakSettingsPanel get_settings_panel () {
		return new MicroBreakSettingsPanel (this);
	}
}

class MicroBreakInfoPanel : BreakInfoPanel {
	const string ACTIVE_DESCRIPTION_FORMAT = 
_("Take a break from typing and look away from the screen for %s.

I'll chime when it’s time to use the computer again.");

	private TimerBreakStatus? status;

	public MicroBreakInfoPanel (MicroBreakType break_type) {
		base (
			break_type,
			_("Microbreak")
		);

		break_type.timer_status_changed.connect (this.timer_status_changed_cb);
	}

	private void timer_status_changed_cb (TimerBreakStatus? status) {
		this.status = status;
		this.update_description ();
	}

	private void update_description () {
		this.set_heading ( _("It’s microbreak time"));

		if (this.status != null && this.status.is_active) {
			string duration_text = NaturalTime.instance.get_label_for_seconds (this.status.current_duration);
			this.set_description (ACTIVE_DESCRIPTION_FORMAT.printf (duration_text));
		}
	}
}

class MicroBreakStatusPanel : TimerBreakStatusPanel {
	public MicroBreakStatusPanel (MicroBreakType break_type) {
		base (
			break_type,
			_("Your next microbreak is in"),
			_("It's time for a microbreak")
		);
	}
}

class MicroBreakSettingsPanel : TimerBreakSettingsPanel {
	public MicroBreakSettingsPanel (MicroBreakType break_type) {
		base (
			break_type,
			_("Microbreak"),
			_("Pause frequently to relax your eyes")
		);
	}
}