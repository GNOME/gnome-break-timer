/*
Brain Break
...Or Yet Another RSI Prevention Tool. This time prettier and happier.
Copyright(c) 2011, Dylan McCall and Brain Break contributors.
<dylanmccall@gmail.com>

-----

This tool is designed to satisfy those who are not suffering from RSI,
but are concerned about the mental and physical issues associated with
heavy computer use. As a result, it is not particular about whether the
user is using a keyboard or a mouse or simply looking at the screen; the
goal here is to encourage people to space computer use around other
things.

Brain Break should stay out of the way and be as non-destructive as
possible, accommodating users regardless of their current tasks without
requiring that they change its aggressiveness themselves,(for example
between Quiet, Postponed and Active mode in Workrave). It should avoid
threatening users with things such as permanent statistics, but provide
them with incentives to be healthy that fit into the moment at hand.
The expected non-destructiveness is easily attainable with libnotify,
especially combined with the excellently transient notifications in
Ubuntu 9.04 and above.
*/

/* nice resource... <http://www.rsiguard.com/> */

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

