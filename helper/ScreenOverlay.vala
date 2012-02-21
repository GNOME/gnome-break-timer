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

/* FIXME: Do another overlay widget and kill the set_format junk :) */

public class ScreenOverlay : Gtk.Window {
	public enum Format {
		MINI,
		FULL
	}
	private Format format;
	
	public ScreenOverlay() {
		Object(type: Gtk.WindowType.POPUP);
		
		/*
		this.set_decorated(false);
		this.stick();
		this.set_keep_above(true);
		this.set_skip_pager_hint(true);
		this.set_skip_taskbar_hint(true);
		this.set_accept_focus(false);
		*/
		
		this.realize.connect(this.on_realize);
		
		Gdk.Screen screen = this.get_screen();
		screen.composited_changed.connect(this.on_screen_composited_changed);
		this.on_screen_composited_changed(screen);
		
		this.set_format(Format.FULL);
		
		Gtk.StyleContext style = this.get_style_context();
		style.add_class("brainbreak-screen-overlay");
	}
	
	private void update_format() {
		switch(this.format) {
		case Format.MINI:
			this.input_shape_combine_region((Cairo.Region)null);
			
			this.set_size_request(-1, -1);
			this.resize(1, 1);
			
			break;
		case Format.FULL:
			/* empty input region to ignore any input */
			this.input_shape_combine_region(new Cairo.Region());
			
			Gdk.Screen screen = this.get_screen();
			int monitor = screen.get_monitor_at_window(this.get_window());
			Gdk.Rectangle geom;
			screen.get_monitor_geometry(monitor, out geom);
			
			string? session = Environment.get_variable("DESKTOP_SESSION");
			
			if (session == "gnome-shell") {
				/* make sure the overlay doesn't cause the top panel to hide */
				// FIXME: position _properly_ around panel, using _NET_WORKAREA or a maximized toplevel window
				this.set_size_request(geom.width, geom.height-1);
				this.move(0, 1);
			} else {
				this.set_size_request(geom.width, geom.height);
			}
			
			break;
		}
	}
	
	public void set_format(Format format) {
		this.format = format;
		
		if (this.get_realized()) this.update_format();
	}
	
	private void on_screen_composited_changed(Gdk.Screen screen) {
		Gdk.Visual? screen_visual = null;
		if (screen.is_composited()) {
			screen_visual = screen.get_rgba_visual();
		}
		if (screen_visual == null) {
			screen_visual = screen.get_system_visual();
		}
		this.set_visual(screen_visual);
	}
	
	private void on_realize() {
		this.update_format();
	}
}

