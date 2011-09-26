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

public class BreakOverlay : Gtk.Window {
	public BreakOverlay() {
		Object(type: Gtk.WindowType.POPUP);
		
		this.realize.connect(this.on_realize);
		
		Gdk.Screen screen = this.get_screen();
		if (screen.is_composited()) {
			Gdk.Visual rgba_visual = screen.get_rgba_visual();
			if (rgba_visual != null) this.set_visual(rgba_visual);
		}
		
		/* we don't want any input, ever */
		/* FIXME: surely we can just say what input we want instead of making a region? */
		this.input_shape_combine_region(new Cairo.Region());
	}
	
	private void on_realize() {
		Gdk.Screen screen = this.get_screen();
		int monitor = screen.get_monitor_at_window(this.get_window());
		Gdk.Rectangle geom;
		screen.get_monitor_geometry(monitor, out geom);
		
		this.set_default_size((int)(geom.width * 0.9), (int)(geom.height * 0.9));
		this.set_position(Gtk.WindowPosition.CENTER);
	}
	
	public void set_time_remaining(int seconds) {
	}
	
	/** Set a reassuring message to accompany the break timer */
	public void set_message(string message) {
	}
}

