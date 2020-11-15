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

namespace BreakTimer.Settings {

public abstract class BreakSettingsPanel : Gtk.Grid {
    private Gtk.Grid header;
    private Gtk.Grid details;

    protected BreakSettingsPanel (BreakType break_type, string title, string? description) {
        GLib.Object ();

        this.set_orientation (Gtk.Orientation.VERTICAL);
        this.set_row_spacing (10);

        this.header = new Gtk.Grid ();
        this.add (this.header);
        this.header.set_column_spacing (12);

        var title_grid = new Gtk.Grid ();
        this.set_header (title_grid);
        title_grid.set_orientation (Gtk.Orientation.VERTICAL);
        title_grid.set_row_spacing (4);

        var title_label = new Gtk.Label (title);
        title_grid.add (title_label);
        title_label.get_style_context ().add_class ("_settings-title");
        title_label.set_halign (Gtk.Align.FILL);
        title_label.set_hexpand (true);
        title_label.set_justify (Gtk.Justification.CENTER);

        // var description_label = new Gtk.Label ("<small>%s</small>".printf (description));
        // title_grid.add (description_label);
        // description_label.get_style_context ().add_class ("_settings-description");
        // description_label.set_use_markup (true);
        // description_label.set_halign (Gtk.Align.FILL);
        // description_label.set_hexpand (true);
        // description_label.set_justify (Gtk.Justification.CENTER);

        this.details = new Gtk.Grid ();
        this.add (this.details);
        this.details.set_margin_start (12);
        this.details.set_halign (Gtk.Align.CENTER);
        this.details.set_hexpand (true);

        this.show_all ();
    }

    protected void set_header (Gtk.Widget content) {
        this.header.attach (content, 0, 0, 1, 1);
    }

    protected void set_header_action (Gtk.Widget content) {
        this.header.attach (content, 1, 0, 1, 1);
        content.set_halign (Gtk.Align.END);
        content.set_valign (Gtk.Align.CENTER);
    }

    protected void set_details (Gtk.Widget content) {
        this.details.add (content);
    }
}

}
