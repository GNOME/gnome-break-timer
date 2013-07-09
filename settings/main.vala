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
	private const string app_id = "org.brainbreak.Settings";
	private static const string STYLE_DATA =
		"""
		GtkLabel._settings-title {
			font-weight:bold;
		}

		._break-status {
			font-size: 12;
		}

		._break-status-icon {
			opacity: 0.2;
		}
		""";

	public BreakType[] breaks {public get; private set;}

	private MainWindow main_window;

	public Application() {
		Object(application_id: app_id, flags: ApplicationFlags.FLAGS_NONE);
	}
	
	public override void activate() {
		base.activate();
		
		this.main_window.present();
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
		
		this.breaks = {
			new MicroBreakType(),
			new RestBreakType()
		};

		this.main_window = new MainWindow(this);

		SimpleAction about_action = new SimpleAction("about", null);
		this.add_action(about_action);
		about_action.activate.connect(this.on_about_activate_cb);

		SimpleAction quit_action = new SimpleAction("quit", null);
		this.add_action(quit_action);
		quit_action.activate.connect(this.quit);

		Menu app_menu = new Menu();
		app_menu.append(_("About"), "app.about");
		app_menu.append(_("Quit"), "app.quit");
		this.set_app_menu(app_menu);
	}

	private void on_about_activate_cb() {
		this.main_window.show_about_dialog();
	}
}

public int main(string[] args) {
	Gtk.init(ref args);
	Application application = new Application();
	return application.run(args);
}

