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

// TODO: This intentionally resembles BreakManager from the helper
// application. Ideally, it should be common code in the future.

using Gee;
using GLib;

namespace BreakTimer.Settings {

public class BreakManager : Object {
	private SettingsApplication application;

	private IBreakHelper break_helper;

	private Gee.Map<string, BreakType> breaks;
	private GLib.List<BreakType> breaks_ordered;

	private GLib.Settings settings;
	public bool master_enabled { get; set; }
	public string[] selected_break_ids { get; set; }
	public BreakType? foreground_break { get; private set; }

	public BreakManager (SettingsApplication application) {
		this.application = application;
		this.breaks = new Gee.HashMap<string, BreakType> ();
		this.breaks_ordered = new GLib.List<BreakType> ();

		this.settings = new GLib.Settings ("org.gnome.break-timer");
		this.settings.bind ("enabled", this, "master-enabled", SettingsBindFlags.DEFAULT);
		this.settings.bind ("selected-breaks", this, "selected-break-ids", SettingsBindFlags.DEFAULT);

		// We choose not too send a signal when master_enabled changes because
		// we might be starting the break helper at the same time, so the
		// value of is_working () could fluctuate unpleasantly.
		//this.notify["master-enabled"].connect ( () => { this.status_changed (); });
		this.notify["master-enabled"].connect ( () => {
			// Launch the break timer service if the break manager is enabled
			// TODO: this is redundant, because gnome-session autostarts the
			// service. However, it is unclear if we should rely on it.
			if (this.master_enabled) this.launch_break_timer_service ();
		});
	}

	public signal void break_status_available ();
	public signal void break_added (BreakType break_type);
	public signal void status_changed ();
	
	public void load_breaks () {
		this.add_break (new MicroBreakType ());
		this.add_break (new RestBreakType ());

		this.status_changed ();

		Bus.watch_name (BusType.SESSION, HELPER_BUS_NAME, BusNameWatcherFlags.NONE,
				this.break_helper_appeared, this.break_helper_disappeared);
	}

	public Gee.Set<string> all_break_ids () {
		return this.breaks.keys;
	}
	
	public unowned GLib.List<BreakType> all_breaks () {
		return this.breaks_ordered;
	}

	/**
	 * @returns true if the break helper is working correctly.
	 */
	public bool is_working () {
		return (this.master_enabled == false || this.breaks.size == 0 || this.break_helper != null);
	}
	
	public BreakType? get_break_type_for_name (string name) {
		return this.breaks.get (name);
	}

	private void add_break (BreakType break_type) {
		break_type.initialize ();
		this.breaks.set (break_type.id, break_type);
		this.breaks_ordered.append (break_type);
		break_type.status_changed.connect (this.break_status_changed);
		this.break_added (break_type);
	}

	private void break_status_changed (BreakType break_type, BreakStatus? break_status) {
		BreakType? new_foreground_break = this.foreground_break;

		if (break_status != null && break_status.is_focused && break_status.is_active) {
			new_foreground_break = break_type;
		} else if (this.foreground_break == break_type) {
			new_foreground_break = null;
		}

		if (this.foreground_break != new_foreground_break) {
			this.foreground_break = new_foreground_break;
		}

		this.status_changed ();
	}

	private void break_helper_appeared () {
		try {
			this.break_helper = Bus.get_proxy_sync (
				BusType.SESSION,
				HELPER_BUS_NAME,
				HELPER_OBJECT_PATH,
				DBusProxyFlags.DO_NOT_AUTO_START
			);
			this.break_status_available ();
		} catch (IOError error) {
			this.break_helper = null;
			GLib.warning ("Error connecting to break helper service: %s", error.message);
		}
	}

	private void break_helper_disappeared () {
		if (this.break_helper == null && this.master_enabled) {
			// Try to start break_helper automatically if it should be
			// running. Only do this once, if it was not running previously.
			this.launch_break_timer_service ();
		}

		this.break_helper = null;

		this.status_changed ();
	}

	private void launch_break_timer_service () {
		// TODO: Use dbus activation once we can depend on GLib >= 2.37
		AppInfo helper_app_info = new DesktopAppInfo (Config.HELPER_DESKTOP_ID);
		AppLaunchContext app_launch_context = new AppLaunchContext ();
		try {
			helper_app_info.launch (null, app_launch_context);
		} catch (Error error) {
			GLib.warning ("Error launching helper application: %s", error.message);
		}
	}
}

}
