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

// TODO: This intentionally resembles BreakManager from the helper
// application. Ideally, it should be common code in the future.

public class BreakManager : Object {
	private Application application;

	private IBreakHelper break_helper;

	private Gee.Map<string, BreakType> breaks;
	private List<BreakType> breaks_ordered;

	private Settings settings;
	public bool master_enabled {get; set;}
	public string[] selected_break_ids {get; set;}
	public BreakType? foreground_break {get; private set;}

	public BreakManager(Application application) {
		this.application = application;
		this.breaks = new Gee.HashMap<string, BreakType>();
		this.breaks_ordered = new List<BreakType>();

		this.settings = new Settings("org.brainbreak.breaks");
		this.settings.bind("master-enabled", this, "master-enabled", SettingsBindFlags.DEFAULT);
		this.settings.bind("selected-breaks", this, "selected-break-ids", SettingsBindFlags.DEFAULT);
	}

	public signal void break_added(BreakType break_type);
	
	public void load_breaks() {
		this.add_break(new MicroBreakType());
		this.add_break(new RestBreakType());

		Bus.watch_name(BusType.SESSION, HELPER_BUS_NAME, BusNameWatcherFlags.NONE,
				this.break_helper_appeared, this.break_helper_disappeared);
	}

	public Gee.Set<string> all_break_ids() {
		return this.breaks.keys;
	}
	
	public unowned List<BreakType> all_breaks() {
		return this.breaks_ordered;
	}
	
	public BreakType? get_break_type_for_name(string name) {
		return this.breaks.get(name);
	}

	private void add_break(BreakType break_type) {
		break_type.initialize();
		this.breaks.set(break_type.id, break_type);
		this.breaks_ordered.append(break_type);
		break_type.status_changed.connect(this.break_status_changed);
		this.break_added(break_type);
	}

	private void break_status_changed(BreakType break_type, BreakStatus? break_status) {
		BreakType? new_foreground_break = this.foreground_break;

		if (break_status != null && break_status.is_focused && break_status.is_active) {
			new_foreground_break = break_type;
		} else if (this.foreground_break == break_type) {
			new_foreground_break = null;
		}

		if (this.foreground_break != new_foreground_break) {
			this.foreground_break = new_foreground_break;
		}
	}

	private void break_helper_appeared() {
		try {
			this.break_helper = Bus.get_proxy_sync(
				BusType.SESSION,
				HELPER_BUS_NAME,
				HELPER_OBJECT_PATH
			);
		} catch (IOError error) {
			this.break_helper = null;
			GLib.warning("Error connecting to break helper service: %s", error.message);
		}
	}

	private void break_helper_disappeared() {
		this.break_helper = null;
	}
}