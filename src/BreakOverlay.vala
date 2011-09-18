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
		
		this.set_default_size((int)(geom.width * 0.7), (int)(geom.height * 0.75));
		this.set_position(Gtk.WindowPosition.CENTER);
	}
	
	public void set_time_remaining(int seconds) {
	}
	
	/** Set a reassuring message to accompany the break timer */
	public void set_message(string message) {
	}
}

