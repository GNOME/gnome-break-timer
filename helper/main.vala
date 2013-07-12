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
	const string app_id = HELPER_BUS_NAME+".Application";
	const string app_name = _("Brain Break");
	
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
		this.break_manager = new BreakManager(this, this.ui_manager);
		this.break_manager.load_breaks();

		var connection = this.get_dbus_connection();
		if (connection != null) {
			Bus.own_name_on_connection(connection, HELPER_BUS_NAME, BusNameOwnerFlags.REPLACE, null, null);
		}
	}
}

public int main(string[] args) {
	Gtk.init(ref args);
	Application application = new Application();
	return application.run(args);
}
