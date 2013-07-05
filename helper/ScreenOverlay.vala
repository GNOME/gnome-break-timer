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

public interface IScreenOverlayContent : Gtk.Widget {
	public abstract void added_to_overlay();
	public abstract void removed_from_overlay();
	public abstract void before_fade_in();
	public abstract void before_fade_out();
}


public class ScreenOverlay : Gtk.Window {
	public enum Format {
		SILENT,
		MINI,
		FULL
	}

	private Format format;
	private Gtk.Grid wrapper_grid;
	private IScreenOverlayContent? custom_content;
	private uint fade_timeout;

	private delegate void FadeCompleteCb();
	
	public ScreenOverlay() {
		Object(type: Gtk.WindowType.POPUP);
		
		this.format = Format.FULL;

		this.wrapper_grid = new Gtk.Grid();
		this.add(this.wrapper_grid);
		this.wrapper_grid.show();
		this.wrapper_grid.set_halign(Gtk.Align.CENTER);
		this.wrapper_grid.set_valign(Gtk.Align.CENTER);
		
		Gdk.Screen screen = this.get_screen();
		screen.composited_changed.connect(this.on_screen_composited_changed);
		this.on_screen_composited_changed(screen);
		
		Gtk.StyleContext style = this.get_style_context();
		style.add_class("_screen-overlay");

		this.realize.connect(this.on_realize);
		this.realize();
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
		this.apply_format(this.format);
	}

	private void apply_format(Format format) {
		switch(format) {
		case Format.SILENT:
			this.fade_out();
			break;

		case Format.MINI:
			this.input_shape_combine_region((Cairo.Region)null);
			
			this.set_size_request(-1, -1);
			this.resize(1, 1);

			this.fade_in();

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

			this.fade_in();
			
			break;
		}
	}
	
	public void set_format(Format format) {
		this.format = format;
		if (this.get_realized()) this.apply_format(format);
	}

	private static double ease_swing(double p) {
		return 0.5 - Math.cos(p*Math.PI) / 2.0;
	}

	private void fade_opacity(double duration_ms, double to, FadeCompleteCb? complete_cb = null) {
		double from;
		if (this.get_visible()) {
			from = this.get_opacity();
		} else {
			from = 0.0;
			this.set_opacity(from);
			this.show();
		}

		double fade_direction = (double)(to - from);
		Timer fade_timer = new Timer();

		if (this.fade_timeout > 0) Source.remove(this.fade_timeout);
		this.fade_timeout = Timeout.add(20, () => {
			double elapsed_ms = fade_timer.elapsed() * 1000.0;
			double percent = elapsed_ms / duration_ms;
			percent = percent.clamp(0, 1);
			double opacity = from + (fade_direction * ease_swing(percent));
			this.set_opacity(opacity);

			bool do_continue = percent < 1.0;
			if (! do_continue) {
				if (complete_cb != null) complete_cb();
			}
			return do_continue;
		});
	}

	public void fade_in() {
		if (this.format != Format.SILENT) {
			if (this.custom_content != null) {
				this.custom_content.before_fade_in();
				this.fade_opacity(2000, 1);
			}
		}
	}

	public void fade_out() {
		if (this.get_visible()) {
			if (this.custom_content != null) {
				this.custom_content.before_fade_out();
			}
			this.fade_opacity(1500, 0, () => {
				this.hide();
			});
		}
	}

	private void fade_out_and_remove() {
		if (this.get_visible()) {
			if (this.custom_content != null) this.custom_content.before_fade_out();
			this.fade_opacity(1500, 0, () => {
				this.hide();
				this.set_content(null);
			});
		} else {
			this.set_content(null);
		}
	}

	public void shake() {
		int start_x;
		int start_y;
		this.get_position(out start_x, out start_y);
		
		int shake_count = 0;
		double velocity_x = 1.5;
		double velocity_y = 0;
		
		double move_x = start_x;
		double move_y = start_y;
		
		Timeout.add(15, () => {
			if (shake_count < 42) {
				if (move_x - start_x > 6 || move_x - start_x < -6) {
					velocity_x = -velocity_x;
				}
				move_x = move_x + velocity_x;
				move_y = move_y + velocity_y;
				this.move((int)move_x, (int)move_y);
				shake_count += 1;
				return true;
			} else {
				this.move(start_x, start_y);
				return false;
			}
		});
	}

	public void request_attention() {
		this.shake();
		Gdk.Window gdk_window = this.get_window();
		gdk_window.beep();
	}

	public void set_content(IScreenOverlayContent? widget) {
		if (this.custom_content != null) {
			this.custom_content.removed_from_overlay();
			this.wrapper_grid.remove(this.custom_content);
		}
		if (widget != null) {
			widget.added_to_overlay();
			this.wrapper_grid.add(widget);
		}
		this.custom_content = widget;
	}

	public void reveal_content(IScreenOverlayContent? widget) {
		this.set_content(widget);
		this.fade_in();
	}

	public void disappear_content(IScreenOverlayContent? widget) {
		if (this.custom_content == widget) {
			this.fade_out_and_remove();
		}
	}

	public bool is_showing_content(IScreenOverlayContent? widget) {
		if (widget == null) {
			return false;
		} else {
			return this.get_visible() && this.custom_content == widget;
		}
	}
}
