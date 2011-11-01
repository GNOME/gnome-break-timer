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
	
	private Gtk.InfoBar app_not_running_info_bar;
	
	public ApplicationPanel() {
		Object();
		
		this.settings = new Settings("org.brainbreak.breaks");
		
		this.app_not_running_info_bar = new AppNotRunningInfoBar();
		
		Gtk.InfoBar[] info_bars = { this.app_not_running_info_bar };
		// request space to fit any info bars that might appear
		int minimum_width = -1;
		foreach (Gtk.InfoBar info_bar in info_bars) {
			Gtk.Requisition this_minimum;
			info_bar.get_preferred_size(out this_minimum, null);
			if (this_minimum.width > minimum_width) minimum_width = this_minimum.width;
		}
		this.set_size_request(minimum_width, -1);
		
		this.add(this.app_not_running_info_bar);
		
		this.show();
		
		this.settings.bind("master-enabled", this, "master-enabled", SettingsBindFlags.DEFAULT);
		this.notify["master-enabled"].connect((s, p) => {
			this.update_status();
		});
	}
	
	private void update_status() {
		if (this.master_enabled) {
			this.app_not_running_info_bar.show();
		} else {
			// application doesn't need to be running
			this.app_not_running_info_bar.hide();
		}
	}
	
	public Gtk.Widget get_status_widget() {
		return this;
	}
}

private class AppNotRunningInfoBar : Gtk.InfoBar {
	private Gtk.Label status_label;
	
	public AppNotRunningInfoBar () {
		Object();
		
		this.set_message_type(Gtk.MessageType.INFO);
		
		Gtk.Container content = (Gtk.Container)this.get_content_area();
		this.status_label = new Gtk.Label(null);
		content.add(status_label);
		
		Bus.watch_name(BusType.SESSION, "org.brainbreak.Helper", BusNameWatcherFlags.NONE,
				this.break_helper_appeared, this.break_helper_disappeared);
		
		this.add_button("Start break helper", Gtk.ResponseType.OK);
			
		this.show_all();
	}
	
	private void break_helper_appeared(DBusConnection connection, string name, string name_owner) {
		status_label.set_text("Break helper is running");
	}
	
	private void break_helper_disappeared(DBusConnection connection, string name) {
		status_label.set_text("Break helper is not running");
	}
}

