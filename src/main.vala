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

using GLib;
using Gdk;
using Notify;

public class BrainBreak : Gtk.Application {
	const string app_id = "com.dylanmccall.BrainBreak";
	const string app_name = "Brain Break"; /* TODO: translate */
	
	private enum UserMode {
		ACTIVE,
		PAUSE,
		REST
	}
	private static UserMode user_mode;
	
	private static RestScheduler rest;
	private static PauseScheduler pause;
	
	private static PauseView pause_view;
	
	public BrainBreak() {
		Object(application_id: app_id, flags: ApplicationFlags.FLAGS_NONE);
		GLib.Environment.set_application_name(app_name);
	}
	
	public override void activate() {
	}
	
	public override void startup() {
		this.hold(); /* we're doing stuff, even if no windows are open */
		
		Magic.begin();
		
		/* set up custom gtk style for application */
		Gdk.Screen screen = Gdk.Screen.get_default();
		Gtk.CssProvider style_provider = new Gtk.CssProvider();
		/* FIXME: of course, we should load data files in a smarter way */
		style_provider.load_from_path("data/style.css");
		Gtk.StyleContext.add_provider_for_screen(screen,
		                                         style_provider,
		                                         Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
		
		
		Notify.init(app_name);
		
		//Gtk.Settings settings = Gtk.Settings.get_default();
		//settings.gtk_application_prefer_dark_theme = true;
		
		this.rest = new RestScheduler();
		this.pause = new PauseScheduler();
		this.pause_view = new PauseView(pause);
	}
}

public int main(string[] args) {
	Gtk.init(ref args);
	BrainBreak application = new BrainBreak();
	return application.run(args);
}

