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
	const string app_id = "org.brainbreak.Settings";
	const string app_name = _("Break Settings");
	
	static const string STYLE_DATA =
			"""
			GtkLabel._settings-title {
				font-weight:bold;
			}
			""";
	
	public Application() {
		Object(application_id: app_id, flags: ApplicationFlags.FLAGS_NONE);
		GLib.Environment.set_application_name(app_name);
	}
	
	public override void activate() {
		base.activate();
		foreach (Gtk.Window window in this.get_windows()) {
			window.present();
		}
	}
	
	public override void startup() {
		base.startup();
		
		/* set up custom gtk style for application */
		Gdk.Screen screen = Gdk.Screen.get_default();
		Gtk.CssProvider style_provider = new Gtk.CssProvider();
		
		try {
			style_provider.load_from_data(STYLE_DATA, -1);
		} catch (Error error) {
			stderr.printf("Error loading style data: %s\n", error.message);
		}
		
		Gtk.StyleContext.add_provider_for_screen(
				screen,
				style_provider,
				Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
		
		SettingsDialog dialog = new SettingsDialog();
		dialog.add_break_type(new MicroBreakType());
		dialog.add_break_type(new RestBreakType());
		
		this.add_window(dialog);
		dialog.show();
	}
}

public int main(string[] args) {
	Gtk.init(ref args);
	Application application = new Application();
	return application.run(args);
}

