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

namespace c_x11_activity_monitor_backend {
	[Import] private static extern void * create_context();
	[Import] private static extern void start(void * context);
	[Import] private static extern void stop(void * context);
	[Import] private static extern uint32 get_last_event_time(void * context);
}

public class X11ActivityMonitorBackend : Object, IActivityMonitorBackend {
	private const int MILLISECONDS_IN_SECONDS = 1000;
	
	private Gdk.Window window;
	
	private unowned void * monitor_context;
	private unowned Thread<void*> monitor_thread;
	
	public X11ActivityMonitorBackend() throws ThreadError {
		Gdk.WindowAttr attributes = Gdk.WindowAttr() {
			window_type = Gdk.WindowType.TOPLEVEL
		};
		this.window = new Gdk.Window(null, attributes, Gdk.WindowAttributesType.TYPE_HINT);
		
		this.monitor_context = c_x11_activity_monitor_backend.create_context();
		
		this.monitor_thread = Thread.create<void*>(this.thread_func, false);
	}
	
	~X11ActivityMonitorBackend() {
		c_x11_activity_monitor_backend.stop(this.monitor_context);
		this.monitor_thread.yield();
	}
	
	private void* thread_func() {
		c_x11_activity_monitor_backend.start(this.monitor_context);
		return null;
	}
	
	public int get_idle_seconds() {
		uint32 server_time = Gdk.x11_get_server_time(this.window);
		uint32 last_event = c_x11_activity_monitor_backend.get_last_event_time(this.monitor_context);
		
		int idle = (int) ((server_time - last_event) / MILLISECONDS_IN_SECONDS);
		return idle;
	}
}

