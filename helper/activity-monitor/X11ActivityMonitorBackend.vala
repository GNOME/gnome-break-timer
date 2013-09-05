/*
 * This file is part of GNOME Break Timer.
 * 
 * GNOME Break Timer is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * GNOME Break Timer is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with GNOME Break Timer.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace c_x11_activity_monitor_backend {
	[Import] private static extern void * create_context ();
	[Import] private static extern void start (void * context);
	[Import] private static extern void stop (void * context);
	[Import] private static extern uint32 get_last_event_time (void * context);
}

public class X11ActivityMonitorBackend : ActivityMonitorBackend {
	private Gdk.Window window;
	private uint32 start_time = 0;

	private unowned void * monitor_context;
	private Thread<void*> monitor_thread;
	
	public X11ActivityMonitorBackend () throws ThreadError {
		Gdk.WindowAttr attributes = Gdk.WindowAttr () {
			window_type = Gdk.WindowType.TOPLEVEL
		};
		this.window = new Gdk.Window (null, attributes, Gdk.WindowAttributesType.TYPE_HINT);
		this.start_time = Gdk.x11_get_server_time (this.window) - (10 * Util.MILLISECONDS_IN_SECONDS);

		this.monitor_context = c_x11_activity_monitor_backend.create_context ();
		this.monitor_thread = new Thread<void*> ("activity-monitor", this.thread_func);
	}

	~X11ActivityMonitorBackend () {
		c_x11_activity_monitor_backend.stop (this.monitor_context);
	}

	private void* thread_func () {
		c_x11_activity_monitor_backend.start (this.monitor_context);
		return null;
	}

	protected override int time_since_last_event () {
		uint32 now_x11 = Gdk.x11_get_server_time (this.window);
		uint32 event_time = c_x11_activity_monitor_backend.get_last_event_time (this.monitor_context);
		if (event_time == 0) event_time = this.start_time;
		return (int) ( (now_x11 - event_time) / Util.MILLISECONDS_IN_SECONDS);
	}
}