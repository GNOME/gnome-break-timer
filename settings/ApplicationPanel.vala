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

public class ApplicationPanel : Gtk.Grid {
	protected Settings settings;
	
	private Gtk.Container details_grid;
	
	public bool master_enabled {get; set; default=true;}
	
	bool break_helper_exists;
	private Gtk.InfoBar? app_not_running_info_bar;
	
	public ApplicationPanel() {
		Object();
		
		this.settings = new Settings("org.brainbreak.breaks");
		
		this.app_not_running_info_bar = new AppNotRunningInfoBar();
		this.app_not_running_info_bar.set_hexpand(true);
		this.add(app_not_running_info_bar);
		
		this.show();
		
		Bus.watch_name(BusType.SESSION, HELPER_BUS_NAME, BusNameWatcherFlags.NONE,
				this.break_helper_appeared, this.break_helper_disappeared);
		
		this.settings.bind("master-enabled", this, "master-enabled", SettingsBindFlags.DEFAULT);
		this.notify["master-enabled"].connect(this.master_enabled_change_cb);
	}
	
	private void break_helper_appeared() {
		break_helper_exists = true;
		this.app_not_running_info_bar.hide();
	}
	
	private void break_helper_disappeared() {
		break_helper_exists = false;
		if (this.master_enabled) {
			this.app_not_running_info_bar.show();
		}
	}
	
	private void master_enabled_change_cb() {
		if (this.master_enabled && !break_helper_exists) {
			this.app_not_running_info_bar.show();
		} else {
			this.app_not_running_info_bar.hide();
		}
	}
	
	public Gtk.Widget get_status_widget() {
		return this;
	}
}

private class AppNotRunningInfoBar : Gtk.InfoBar {
	private static const int RESPONSE_LAUNCH_HELPER = 2;
	
	private Gtk.Label status_label;
	
	public AppNotRunningInfoBar() {
		Object();
		
		this.set_message_type(Gtk.MessageType.INFO);
		
		Gtk.Container content = (Gtk.Container)this.get_content_area();
		this.status_label = new Gtk.Label(null);
		status_label.set_text("Break helper is not running");
		
		content.add(status_label);
		
		this.add_button("Start break helper", RESPONSE_LAUNCH_HELPER);
		
		this.response.connect((response_id) => {
			if (response_id == RESPONSE_LAUNCH_HELPER) this.launch_helper();
		});
		
		this.show_all();
	}
	
	private void launch_helper() {
		AppInfo helper_app_info = new DesktopAppInfo("brainbreak.desktop");
		AppLaunchContext app_launch_context = new AppLaunchContext();
		
		try {
			helper_app_info.launch(null, app_launch_context);
		} catch (Error error) {
			stderr.printf("Error launching brainbreak helper: %s\n", error.message);
		}
	}
}

