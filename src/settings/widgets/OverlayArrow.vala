/* OverlayArrow.vala
 *
 * Copyright 2020 Dylan McCall <dylan@dylanmccall.ca>
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

namespace BreakTimer.Settings.Widgets {

/* FIXME: This widget is stealing clicks when it is used in an overlay */
public class OverlayArrow : Gtk.Widget {
    private Gtk.Widget from_widget;
    private Gtk.Widget to_widget;

    public OverlayArrow (Gtk.Widget from_widget, Gtk.Widget to_widget) {
        GLib.Object ();

        this.set_has_window (false);

        this.set_halign (Gtk.Align.FILL);
        this.set_valign (Gtk.Align.FILL);

        this.from_widget = from_widget;
        this.to_widget = to_widget;
    }

    public override bool draw (Cairo.Context cr) {
        int max_width = this.get_allocated_width ();
        int max_height = this.get_allocated_height ();

        int from_x, from_y;
        this.get_from_coordinates (out from_x, out from_y);
        from_x = from_x.clamp (0, max_width);
        from_y = from_y.clamp (0, max_height);

        int to_x, to_y;
        this.get_to_coordinates (out to_x, out to_y);
        to_x = to_x.clamp (0, max_width);
        to_y = to_y.clamp (0, max_height);

        Gtk.StateFlags state = this.get_state_flags ();
        Gtk.StyleContext style_context = this.get_style_context ();
        Gdk.RGBA color = style_context.get_color (state);
        Gdk.cairo_set_source_rgba (cr, color);
        cr.set_line_width (1.0);

        cr.move_to (from_x, from_y);
        double curve_x = to_x - from_x;
        double curve_y = (to_y+8) - from_y;
        cr.rel_curve_to (curve_x / 3.0, 0, curve_x, curve_y / 3.0, curve_x, curve_y);
        cr.stroke ();

        cr.move_to (to_x, to_y+8);
        cr.rel_line_to (-4, 0);
        cr.rel_line_to (4, -6);
        cr.rel_line_to (4, 6);
        cr.close_path ();
        cr.fill_preserve ();
        cr.stroke ();

        return true;
    }

    public override void size_allocate (Gtk.Allocation allocation) {
        base.size_allocate (allocation);
    }

    private void get_points_offset (out int offset_x, out int offset_y) {
        Gtk.Allocation to_allocation;
        this.to_widget.get_allocation (out to_allocation);
        this.from_widget.translate_coordinates (this.to_widget, to_allocation.width/2, to_allocation.width/2, out offset_x, out offset_y);
    }

    private void get_from_coordinates (out int from_x, out int from_y) {
        // Is to_widget to the right or to the left?
        Gtk.Allocation from_allocation;
        this.from_widget.get_allocation (out from_allocation);

        int offset_x, offset_y;
        this.get_points_offset (out offset_x, out offset_y);

        int from_local_x, from_local_y;
        if (offset_x > 0) {
            from_local_x = 0;
            from_local_y = from_allocation.height / 2;
        } else {
            from_local_x = from_allocation.width;
            from_local_y = from_allocation.height / 2;
        }
        this.from_widget.translate_coordinates (this, from_local_x, from_local_y, out from_x, out from_y);
    }

    private void get_to_coordinates (out int to_x, out int to_y) {
        // Is to_widget to the right or to the left?
        Gtk.Allocation to_allocation;
        this.to_widget.get_allocation (out to_allocation);

        int offset_x, offset_y;
        this.get_points_offset (out offset_x, out offset_y);

        int to_local_x, to_local_y;
        if (offset_y > 0) {
            to_local_x = to_allocation.width / 2;
            to_local_y = to_allocation.height;
        } else {
            to_local_x = to_allocation.width / 2;
            to_local_y = 0;
        }
        this.to_widget.translate_coordinates (this, to_local_x, to_local_y, out to_x, out to_y);
    }
}

}
