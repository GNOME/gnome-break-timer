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

using Gtk;
using GLib;

namespace BreakTimer.Settings {

public class MicroBreakType : TimerBreakType {
	public MicroBreakType () {
		GLib.Settings settings = new GLib.Settings ("org.gnome.break-timer.microbreak");
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
		if (this.status == null) return;

		int time_remaining_value;
		string time_remaining_text = NaturalTime.instance.get_countdown_for_seconds_with_start (
			this.status.time_remaining, this.status.current_duration, out time_remaining_value);
		string description_text = ngettext (
			/* %s will be replaced with a string that describes a time interval, such as "2 minutes", "40 seconds" or "1 hour" */
			"Take a break from typing and look away from the screen for %s.",
			"Take a break from typing and look away from the screen for %s.",
			time_remaining_value
		).printf (time_remaining_text);

		this.set_heading ( _("It’s microbreak time"));
		this.set_description (description_text);
		this.set_detail (_("I'll chime when it’s time to use the computer again."));
	}
}

class MicroBreakStatusPanel : TimerBreakStatusPanel {
	public MicroBreakStatusPanel (MicroBreakType break_type) {
		base (
			break_type,
			/* Label that explains a countdown timer, which shows a string such as "5 minutes" */
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

}
