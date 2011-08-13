/*
Brain Break
...Or Yet Another RSI Prevention Tool. This time prettier and happier.
Copyright (c) 2011, Dylan McCall and Brain Break contributors.
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
requiring that they change its aggressiveness themselves, (for example
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
	
	public BrainBreak () {
		Object (application_id: app_id, flags: ApplicationFlags.FLAGS_NONE);
		GLib.Environment.set_application_name (app_name);
	}
	
	public override void activate () {
	}
	
	public override void startup () {
		this.hold(); /* we're doing stuff, even if no windows are open */
		
		Notify.init (app_id);
		Magic.begin();
		
		rest = new RestScheduler();
		pause = new PauseScheduler();
	}
}

public int main (string[] args) {
	BrainBreak application = new BrainBreak();
	return application.run(args);
}

