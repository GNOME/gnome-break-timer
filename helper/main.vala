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
	
		public string get_status_for_break(string break_name) {
			BreakType break_type = this.break_manager.get_break_type_for_name(break_name);
			return break_type.view.get_status_message();
		}
	
		public void trigger_break(string break_name) {
			BreakType break_type = this.break_manager.get_break_type_for_name(break_name);
			break_type.model.activate();
		}
	}
	
	static const string STYLE_DATA =
			"""
			@define-color bg_top rgba(60, 60, 60, 0.85);
			@define-color bg_middle rgba(12, 12, 12, 0.92);
			@define-color bg_bottom rgba(0, 0, 0, 0.96);

			GtkWindow.brainbreak-screen-overlay {
				background-color: @bg_inner;
				background-image:-gtk-gradient (linear,
				       center top,
				       center bottom,
				       color-stop (0, @bg_top),
				       color-stop (0.06, @bg_middle),
				       color-stop (0.9, @bg_middle),
				       color-stop (1, @bg_bottom));
				/*border-radius: 8;*/
				color: #ffffff;
			}

			GtkLabel.brainbreak-timer-label {
				font-weight:bold;
				font-size:25;
				text-shadow:1 1 5 rgba(0,0,0,0.5);
			}
			""";
	
	private BreakManager break_manager;
	private UIManager ui_manager;
	
	private BreakHelperServer break_helper_server;
	
	public Application() {
		Object(application_id: app_id, flags: ApplicationFlags.FLAGS_NONE);
		GLib.Environment.set_application_name(app_name);
		
		// Keep running for one minute after last break is disabled
		this.set_inactivity_timeout(60 * 1000);
	}
	
	public override void activate() {
		base.activate();
	}
	
	public override void startup() {
		base.startup();
		
		ActivityMonitor.setup();
		Notify.init(app_name);
		
		/* set up custom gtk style for application */
		Gdk.Screen screen = Gdk.Screen.get_default();
		Gtk.CssProvider style_provider = new Gtk.CssProvider();
		/* FIXME: of course, we should load data files in a smarter way */
		style_provider.load_from_data(STYLE_DATA, -1);
		Gtk.StyleContext.add_provider_for_screen(screen,
		                                         style_provider,
		                                         Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
		
		this.break_manager = new BreakManager();
		this.ui_manager = new UIManager(this, this.break_manager);
		
		/* FIXME: Move this back to break enable */
		this.hold();
		
		DBusConnection connection = Bus.get_sync(BusType.SESSION, null);
		this.break_helper_server = new BreakHelperServer(this.break_manager);
		connection.register_object ("/org/brainbreak/Helper", this.break_helper_server);
	}
}

public int main(string[] args) {
	Gtk.init(ref args);
	Application application = new Application();
	return application.run(args);
}

