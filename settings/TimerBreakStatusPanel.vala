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

class TimerBreakStatusPanel : Gtk.Grid {
	private TimerBreakType break_type;
	private IBreakHelper_TimerBreak? break_server {public get; private set;}

	private string upcoming_text;
	private string ongoing_text;

	private Gtk.Image time_icon;
	private Gtk.Label status_label;
	private Gtk.Label time_label;

	private uint update_timeout_id;

	public TimerBreakStatusPanel(TimerBreakType break_type, string upcoming_text, string ongoing_text) {
		Object();
		this.break_type = break_type;
		this.upcoming_text = upcoming_text;
		this.ongoing_text = ongoing_text;

		this.set_column_spacing(12);
		this.set_row_spacing(10);
		this.get_style_context().add_class("_break-status");

		// FIXME: This is an application icon. It doesn't make sense here.
		this.time_icon = new Gtk.Image.from_icon_name(
			"preferences-system-time-symbolic",
			Gtk.IconSize.DIALOG
		);
		this.attach(this.time_icon, 0, 0, 1, 2);
		this.time_icon.set_pixel_size(90);
		this.time_icon.get_style_context().add_class("_break-status-icon");

		this.status_label = new Gtk.Label(null);
		this.attach(this.status_label, 1, 0, 1, 1);
		this.status_label.set_width_chars(25);

		this.time_label = new Gtk.Label(null);
		this.attach(this.time_label, 1, 1, 1, 1);
		this.time_label.set_width_chars(25);

		Bus.watch_name(BusType.SESSION, HELPER_BUS_NAME, BusNameWatcherFlags.NONE,
				this.breakhelper_appeared, this.breakhelper_disappeared);
	}

	private void show_status(TimerBreakStatus? status) {
		if (status != null && status.is_enabled) {
			this.show();
			if (status.is_active) {
				// TODO: Instead of this, explain the current break. Implement
				// the "What should I do?" button from the mockup, seen at
				// https://raw.github.com/gnome-design-team/gnome-mockups/master/break-timer/wires-notifications.png
				this.status_label.set_label(this.ongoing_text);
				string time_text = NaturalTime.instance.get_countdown_for_seconds_with_start(
					status.time_remaining, status.current_duration);
				this.time_label.set_label(time_text);
			} else {
				this.status_label.set_label(this.upcoming_text);
				string time_text = NaturalTime.instance.get_countdown_for_seconds(status.starts_in);
				this.time_label.set_label(time_text);
			}
		} else {
			this.hide();
		}
	}

	private bool update_status_cb() {
		TimerBreakStatus? status = this.get_status();
		this.show_status(status);
		return true;
	}

	private TimerBreakStatus? get_status() {
		if (this.break_server != null) {
			try {
				return this.break_server.get_status();
			} catch (IOError error) {
				GLib.warning("Error getting break status: %s", error.message);
				return null;
			}
		} else {
			return null;
		}
	}

	private void breakhelper_appeared() {
		try {
			this.break_server = Bus.get_proxy_sync(
				BusType.SESSION,
				HELPER_BUS_NAME,
				HELPER_BREAK_OBJECT_BASE_PATH+this.break_type.id
			);
			this.update_timeout_id = Timeout.add_seconds(1, this.update_status_cb);
			this.update_status_cb();
		} catch (IOError error) {
			this.break_server = null;
			GLib.warning("Error connecting to break helper service: %s", error.message);
		}
	}

	private void breakhelper_disappeared() {
		if (this.update_timeout_id > 0) {
			Source.remove(this.update_timeout_id);
			this.update_timeout_id = 0;
		}
		this.break_server = null;
		this.update_status_cb();
	}
}