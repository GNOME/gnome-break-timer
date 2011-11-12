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
	
	private UIManager ui_manager;
	private FocusManager focus_manager;
	private SList<Break> breaks;
	
	public Application() {
		Object(application_id: app_id, flags: ApplicationFlags.FLAGS_NONE);
		GLib.Environment.set_application_name(app_name);
	}
	
	public override void activate() {
	}
	
	public override void startup() {
		Magic.begin();
		Notify.init(app_name);
		
		/* set up custom gtk style for application */
		Gdk.Screen screen = Gdk.Screen.get_default();
		Gtk.CssProvider style_provider = new Gtk.CssProvider();
		/* FIXME: of course, we should load data files in a smarter way */
		style_provider.load_from_path("data/style.css");
		Gtk.StyleContext.add_provider_for_screen(screen,
		                                         style_provider,
		                                         Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
		
		this.focus_manager = new FocusManager();
		this.ui_manager = new UIManager();
		
		this.add_break(new RestBreak(this.focus_manager));
		this.add_break(new MicroBreak(this.focus_manager));
	}
	
	private void add_break(Break brk) {
		this.breaks.append(brk);
		this.ui_manager.add_break(brk);
		
		brk.started.connect(() => {
			this.hold();
		});
		brk.stopped.connect(() => {
			this.release();
		});
		
		// FIXME: Breaks are currently enabled in their own settings.
		// Instead, enabled breaks should be stored in a list somewhere.
		brk.settings.bind("enabled", brk, "enabled", SettingsBindFlags.GET);
		
	}
}

public int main(string[] args) {
	Gtk.init(ref args);
	Application application = new Application();
	return application.run(args);
}

