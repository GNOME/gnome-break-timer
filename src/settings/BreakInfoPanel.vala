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

public abstract class BreakInfoPanel : Gtk.Grid {
    public BreakType break_type { public get; private set; }
    public string title { public get; private set; }

    private Gtk.Label heading_label;
    private Gtk.Label description_label;
    private Gtk.Label detail_label;

    protected BreakInfoPanel (BreakType break_type, string title) {
        Object ();
        this.break_type = break_type;
        this.title = title;

        this.set_orientation (Gtk.Orientation.VERTICAL);
        this.set_hexpand (true);
        this.set_row_spacing (24);
        this.get_style_context ().add_class ("_break-info");

        this.heading_label = new Gtk.Label (null);
        this.add (this.heading_label);
        this.heading_label.get_style_context ().add_class ("_break-info-heading");

        this.description_label = new Gtk.Label (null);
        this.add (this.description_label);
        this.description_label.set_line_wrap (true);
        this.description_label.set_justify (Gtk.Justification.CENTER);
        this.description_label.set_max_width_chars (60);

        this.detail_label = new Gtk.Label (null);
        this.add (this.detail_label);

        this.show_all ();
    }

    protected void set_heading (string heading) {
        this.heading_label.set_label (heading);
    }

    protected void set_description (string description) {
        this.description_label.set_label (description);
    }

    protected void set_detail (string detail) {
        this.detail_label.set_label (detail);
    }
}

}
