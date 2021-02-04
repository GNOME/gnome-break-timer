/* BreakSettingsWidget.vala
 *
 * Copyright 2020-2021 Dylan McCall <dylan@dylanmccall.ca>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace BreakTimer.Settings.Break {

public abstract class BreakSettingsWidget : Gtk.Box {
    private Gtk.Box header;
    private Gtk.Box details;

    protected BreakSettingsWidget (BreakType break_type, string title, string? description) {
        GLib.Object ();

        this.set_orientation (Gtk.Orientation.VERTICAL);
        this.set_spacing (10);

        this.header = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        this.append (this.header);

        var title_grid = new Gtk.Box (Gtk.Orientation.VERTICAL, 4);
        this.set_header (title_grid);

        var title_label = new Gtk.Label (title);
        title_grid.append (title_label);
        title_label.get_style_context ().add_class ("_settings-title");
        title_label.set_halign (Gtk.Align.CENTER);
        title_label.set_hexpand (true);
        // title_label.set_justify (Gtk.Justification.CENTER);

        // var description_label = new Gtk.Label ("<small>%s</small>".printf (description));
        // title_grid.add (description_label);
        // description_label.get_style_context ().add_class ("_settings-description");
        // description_label.set_use_markup (true);
        // description_label.set_halign (Gtk.Align.FILL);
        // description_label.set_hexpand (true);
        // description_label.set_justify (Gtk.Justification.CENTER);

        this.details = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        this.append (this.details);
        this.details.set_margin_start (12);
        this.details.set_halign (Gtk.Align.FILL);
        this.details.set_hexpand (true);

        this.show ();
    }

    protected void set_header (Gtk.Widget content) {
        this.header.append (content);
    }

    protected void set_header_action (Gtk.Widget content) {
        this.header.append (content);
        content.set_halign (Gtk.Align.END);
        content.set_valign (Gtk.Align.CENTER);
    }

    protected void set_details (Gtk.Widget content) {
        this.details.append (content);
    }
}

}
