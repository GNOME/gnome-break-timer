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

public class Application : Gtk.Application {
	const string app_id = "org.brainbreak.Helper";
	const string app_name = _("Brain Break");
	
	[DBus (name = "org.brainbreak.Helper")]
	private class BreakHelperServer : Object {
		// FIXME: this used to implement BreakHelperRemote, but currently
		// it does not due to a problem detected by Debian's build log filter.
		private BreakManager break_manager;
		
		public BreakHelperServer(BreakManager break_manager) {
			this.break_manager = break_manager;
		}
		
		public bool is_active() {
			bool active = false;
			foreach (BreakType break_type in this.break_manager.all_breaks()) {
				active = active || break_type.break_controller.is_active();
			}
			return active;
		}
		
		public string get_status_for_break(string break_name) {
			BreakType? break_type = this.break_manager.get_break_type_for_name(break_name);
			string status_message = "";
			if (break_type != null) status_message = break_type.break_view.get_status_message();
			return status_message;
		}
		
		public void trigger_break(string break_name) {
			BreakType? break_type = this.break_manager.get_break_type_for_name(break_name);
			if (break_type != null) break_type.break_controller.activate();
		}
	}
	
	/* FIXME: font-size should have units, but we can only do that with GTK 3.8 and later */
	static const string STYLE_DATA =
			"""
			@define-color bg_top rgba(218, 236, 237, 0.80);
			@define-color bg_middle rgba(226, 237, 236, 0.87);
			@define-color bg_bottom rgba(179, 209, 183, 0.89);

			GtkWindow._screen-overlay {
				background-color: @bg_inner;
				background-image:-gtk-gradient (linear,
				       center top,
				       center bottom,
				       color-stop (0, @bg_top),
				       color-stop (0.08, @bg_middle),
				       color-stop (0.92, @bg_middle),
				       color-stop (1, @bg_bottom));
				font-size: 18;
				color: #999;
			}

			GtkLabel._timer-label {
				font-weight: bold;
				font-size: 36;
				color: #333;
				text-shadow: 1px 1px 5px rgba(0, 0, 0, 0.5);
			}
			""";
	
	private BreakManager break_manager;
	private UIManager ui_manager;
	
	private BreakHelperServer break_helper_server;
	
	public Application() {
		Object(application_id: app_id, flags: ApplicationFlags.FLAGS_NONE);
		GLib.Environment.set_application_name(app_name);
		
		// Keep running for one minute after the last break is disabled
		this.set_inactivity_timeout(60 * 1000);
	}
	
	public override void activate() {
		base.activate();
	}
	
	public override void startup() {
		base.startup();
		
		Notify.init(app_name);
		
		/* set up custom gtk style for application */
		Gdk.Screen screen = Gdk.Screen.get_default();
		Gtk.CssProvider style_provider = new Gtk.CssProvider();
		
		try {
			style_provider.load_from_data(STYLE_DATA, -1);
		} catch (Error error) {
			GLib.warning("Error loading style data: %s", error.message);
		}
		
		Gtk.StyleContext.add_provider_for_screen(
			screen,
			style_provider,
			Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
		);
		
		this.ui_manager = new UIManager(this, false);
		this.break_manager = new BreakManager(this.ui_manager);
		this.break_manager.load_breaks();
		
		this.break_helper_server = new BreakHelperServer(this.break_manager);
		
		try {
			DBusConnection connection = Bus.get_sync(BusType.SESSION, null);
			connection.register_object ("/org/brainbreak/Helper", this.break_helper_server);
		} catch (IOError error) {
			GLib.error("Error registering helper on the session bus: %s", error.message);
		}
	}
}

public int main(string[] args) {
	Gtk.init(ref args);
	Application application = new Application();
	return application.run(args);
}

