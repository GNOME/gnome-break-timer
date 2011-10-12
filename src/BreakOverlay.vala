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
	private Gtk.Label timer_label;
	private Gtk.Label message_label;
	
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
		
		/* add standard widgets to overlay */
		Gtk.Alignment alignment = new Gtk.Alignment(0.5f, 0.5f, 1.0f, 0.0f);
		alignment.set_padding(8, 8, 12, 12);
		Gtk.VBox container = new Gtk.VBox(false, 12);
		
		Gtk.Label timer_label = new Gtk.Label(null);
		Gtk.StyleContext timer_style = timer_label.get_style_context();
		timer_style.add_class("timer_label");
		
		Gtk.Label message_label = new Gtk.Label(null);
		
		container.pack_end(timer_label, true);
		container.pack_end(message_label, false);
		
		alignment.add(container);
		this.add(alignment);
		
		this.timer_label = timer_label;
		this.message_label = message_label;
	}
	
	private void on_realize() {
		Gdk.Screen screen = this.get_screen();
		int monitor = screen.get_monitor_at_window(this.get_window());
		Gdk.Rectangle geom;
		screen.get_monitor_geometry(monitor, out geom);
		
		this.set_default_size((int)(geom.width * 0.9), (int)(geom.height * 0.9));
		this.set_position(Gtk.WindowPosition.CENTER);
	}
	
	/** Set a reassuring message to accompany the break timer */
	public void set_message(string message) {
		this.message_label.set_text(message);
	}
	
	/** Set the time remaining */
	public void set_timer(string timer_text) {
		this.timer_label.set_text(timer_text);
	}
}

