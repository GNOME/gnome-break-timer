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

public class BreakOverlay : ScreenOverlay {
	private Gtk.Grid content_area;
	
	private BreakOverlaySource? current_source;
	
	public BreakOverlay() {
		base();
		
		this.content_area = new Gtk.Grid();
		this.content_area.set_halign(Gtk.Align.CENTER);
		this.content_area.set_valign(Gtk.Align.CENTER);
		this.add(this.content_area);
		this.content_area.show();
	}
	
	private void set_source(BreakOverlaySource? new_source) {
		if (this.current_source != null) {
			this.current_source.request_attention.disconnect(this.source_request_attention_cb);
			this.current_source.overlay_stopped();
		}
		
		foreach (Gtk.Widget child in this.content_area.get_children()) {
			this.content_area.remove(child);
		}
		
		if (new_source != null) {
			new_source.overlay_started();
			
			new_source.request_attention.connect(this.source_request_attention_cb);
			
			this.set_title(new_source.get_overlay_title());
			Gtk.Widget new_content = new_source.get_overlay_content();
			this.content_area.add(new_content);
			new_content.show();
		} else {
			this.set_title("");
		}
		
		this.current_source = new_source;
	}
	
	public void show_with_source(BreakOverlaySource? source) {
		this.set_source(source);
		
		if (! this.get_visible()) {
			/* Fade in 0.01 per frame over 2000 ms */
			double opacity = 0.0;
			this.set_opacity(opacity);
			this.show();
			Timeout.add(20, () => {
				opacity += 0.01;
				this.set_opacity(opacity);
				return opacity < 1.0;
			});
		}
	}
	
	public bool is_showing_source() {
		return this.current_source != null;
	}
	
	public void remove_source(BreakOverlaySource? source) {
		if (this.current_source == source) {
			this.hide();
			this.set_source(null);
		}
	}
	
	private void source_request_attention_cb() {
		this.shake();
		Gdk.Window gdk_window = this.get_window();
		gdk_window.beep();		
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
}

