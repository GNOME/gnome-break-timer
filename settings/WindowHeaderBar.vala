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

#if HAS_GTK_3_10
using Gtk;
#else
using Gd;
#endif

/**
 * A Gtk.HeaderBar that expects to be set as the titlebar for a Gtk.Window.
 * If it is in titlebar mode, it adds a conventional close button and adjusts
 * its own titles accordingly.
 */
public class WindowHeaderBar : HeaderBar { // Gtk.HeaderBar or Gd.HeaderBar
	private weak Gtk.Window owner_window;
	private Gtk.Button close_button;
	private Gtk.Separator close_separator;

	private bool is_titlebar;

	public WindowHeaderBar(Gtk.Window window) {
		this.owner_window = window;

		this.close_separator = new Gtk.Separator (Gtk.Orientation.VERTICAL);
		this.close_separator.valign = Gtk.Align.FILL;

		this.close_button = new Gtk.Button();
		this.close_button.set_image(
			new Gtk.Image.from_icon_name("window-close-symbolic", Gtk.IconSize.MENU)
		);
		this.close_button.get_style_context().add_class("image-button");
		this.close_button.relief = Gtk.ReliefStyle.NONE;
		this.close_button.valign = Gtk.Align.CENTER;
		this.close_button.clicked.connect(this.on_close_button_clicked_cb);

		this.realize.connect(() => {
			this.pack_end(this.close_separator);
			this.pack_end(this.close_button);
		});
	}

	public new void set_title(string? title) {
		if (this.is_titlebar && title == null) {
			title = this.owner_window.title;
		}
		base.set_title(title);
	}

	public void set_is_titlebar(bool is_titlebar) {
		this.is_titlebar = is_titlebar;
		this.close_separator.set_visible(is_titlebar);
		this.close_button.set_visible(is_titlebar);
		this.set_title(this.title);
	}

	private void on_close_button_clicked_cb() {
		var event = new Gdk.Event (Gdk.EventType.DESTROY);
		event.any.window = this.owner_window.get_window();
		event.any.send_event = 1;
		Gtk.main_do_event (event);
	}
}
