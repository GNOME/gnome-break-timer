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

public class BreakManager : Object {
	private weak Application application;
	private UIManager ui_manager;

	private Gee.Map<string, BreakType> breaks;
	private BreakHelperServer break_helper_server;

	private Settings settings;
	public bool master_enabled {get; set;}
	public string[] selected_break_ids {get; set;}
	
	public BreakManager(Application application, UIManager ui_manager) {
		this.application = application;
		this.ui_manager = ui_manager;

		this.breaks = new Gee.HashMap<string, BreakType>();
		this.settings = new Settings("org.gnome.break-timer");

		this.settings.bind("enabled", this, "master-enabled", SettingsBindFlags.DEFAULT);
		this.settings.bind("selected-breaks", this, "selected-break-ids", SettingsBindFlags.DEFAULT);
		this.notify["master-enabled"].connect(this.update_enabled_breaks);
		this.notify["selected-break-ids"].connect(this.update_enabled_breaks);

		this.break_helper_server = new BreakHelperServer(this);
		try {
			DBusConnection connection = Bus.get_sync(BusType.SESSION, null);
			connection.register_object(
				HELPER_OBJECT_PATH,
				this.break_helper_server
			);
		} catch (IOError error) {
			GLib.error("Error registering helper on the session bus: %s", error.message);
		}
	}
	
	public void load_breaks() {
		IActivityMonitorBackend? activity_monitor_backend;
		try {
			activity_monitor_backend = new X11ActivityMonitorBackend();
		} catch {
			GLib.warning("Failed to initialize activity monitor backend");
			activity_monitor_backend = null;
		}
		
		if (activity_monitor_backend != null) {
			var activity_monitor = new ActivityMonitor(activity_monitor_backend);
			this.add_break(new MicroBreakType(activity_monitor));
			this.add_break(new RestBreakType(activity_monitor));
		}

		this.update_enabled_breaks();
	}

	public Gee.Set<string> all_break_ids() {
		return this.breaks.keys;
	}
	
	public Gee.Collection<BreakType> all_breaks() {
		return this.breaks.values;
	}
	
	public BreakType? get_break_type_for_name(string name) {
		return this.breaks.get(name);
	}

	private void add_break(BreakType break_type) {
		this.breaks.set(break_type.id, break_type);
		break_type.initialize(this.ui_manager);
	}

	private void update_enabled_breaks() {
		foreach (BreakType break_type in this.all_breaks()) {
			bool is_enabled = this.master_enabled && break_type.id in this.selected_break_ids;
			break_type.break_controller.set_enabled(is_enabled);
		}
	}
}

[DBus (name = "org.gnome.BreakTimer")]
private class BreakHelperServer : Object, IBreakHelper {
	private weak BreakManager break_manager;
	
	public BreakHelperServer(BreakManager break_manager) {
		this.break_manager = break_manager;
	}

	public string? get_current_active_break() {
		/* Ask  for focused break */
		foreach (BreakType break_type in this.break_manager.all_breaks()) {
			bool is_active = break_type.break_view.has_ui_focus() &&
				break_type.break_controller.is_active();
			if (is_active) return break_type.id;
		}
		return null;
	}
	
	public bool is_active() {
		bool active = false;
		foreach (BreakType break_type in this.break_manager.all_breaks()) {
			active = active || break_type.break_controller.is_active();
		}
		return active;
	}

	public string[] get_break_ids() {
		return this.break_manager.all_break_ids().to_array();
	}
	
	public string[] get_status_messages() {
		var messages = new Gee.ArrayList<string>();
		foreach (BreakType break_type in break_manager.all_breaks()) {
			string status_message = break_type.break_view.get_status_message();
			messages.add("%s:\t%s".printf(break_type.id, status_message));
		}
		return messages.to_array();
	}
	
	public void activate_break(string break_name) {
		BreakType? break_type = this.break_manager.get_break_type_for_name(break_name);
		if (break_type != null) break_type.break_controller.activate();
	}
}

