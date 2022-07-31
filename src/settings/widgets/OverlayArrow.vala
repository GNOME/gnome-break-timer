/* OverlayArrow.vala
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

namespace BreakTimer.Settings.Widgets {

public class OverlayArrow : Gtk.DrawingArea {
    public int spacing {get; set;}

    private Gtk.Widget from_widget;
    private Gtk.Widget to_widget;
    private Gtk.Widget align_widget;

    [Flags]
    private enum ArrowDirection {
        NONE,
        UP,
        RIGHT,
        DOWN,
        LEFT
    }

    /**
     * Creates an OverlayArrow, which draws an arrow from one widget to another.
     * from_widget: a widget to start the arrow from
     * to_widget: a widget to end the arrow at
     * align_widget: a widget to measure coordinates for the target widget, if
     *               in case from_widget slides into view from elsewhere.
     */
    public OverlayArrow (Gtk.Widget from_widget, Gtk.Widget to_widget, Gtk.Widget align_widget) {
        GLib.Object (sensitive: false);

        this.set_halign (Gtk.Align.FILL);
        this.set_valign (Gtk.Align.FILL);

        this.from_widget = from_widget;
        this.to_widget = to_widget;
        this.align_widget = align_widget;

        this.set_draw_func (this.on_draw_cb);
    }

    private void on_draw_cb (Gtk.DrawingArea widget, Cairo.Context cr, int width, int height) {
        Graphene.Point from_point;
        Graphene.Point to_point;

        this.compute_arrow_points (out from_point, out to_point);

        Gdk.RGBA color = this.get_color ();
        Gdk.cairo_set_source_rgba (cr, color);
        cr.set_line_width (1.5);

        cr.move_to (from_point.x, from_point.y);
        double curve_x = to_point.x - from_point.x;
        double curve_y = (to_point.y + 8) - from_point.y;
        cr.rel_curve_to (curve_x / 3.0, 0, curve_x, curve_y / 3.0, curve_x, curve_y);
        cr.stroke ();

        cr.move_to (to_point.x, to_point.y + 8);
        cr.rel_line_to (-4, 0);
        cr.rel_line_to (4, -6);
        cr.rel_line_to (4, 6);
        cr.close_path ();
        cr.fill_preserve ();
        cr.stroke ();
    }

    private void compute_arrow_points (out Graphene.Point out_from_point, out Graphene.Point out_to_point) {
        Graphene.Point from_point_global;
        Graphene.Point to_point_global;

        this.compute_from_to_coordinates (out from_point_global, out to_point_global);

        this.clamp_point (from_point_global, out out_from_point);
        this.clamp_point (to_point_global, out out_to_point);
    }

    private void compute_from_to_coordinates (out Graphene.Point from_point_global, out Graphene.Point to_point_global) {
        ArrowDirection direction = this.get_arrow_direction ();

        if (LEFT | UP in direction) {
            this.compute_widget_point (this.from_widget, this, 0.0f, 0.5f, out from_point_global);
            this.compute_widget_point (this.to_widget, this.align_widget, 0.5f, 0.0f, out to_point_global);
            from_point_global.x -= this.spacing;
            to_point_global.y -= this.spacing;
        } else if (RIGHT | UP in direction) {
            this.compute_widget_point (this.from_widget, this, 1.0f, 0.5f, out from_point_global);
            this.compute_widget_point (this.to_widget, this.align_widget, 0.5f, 0.0f, out to_point_global);
            from_point_global.x += this.spacing;
            to_point_global.y -= this.spacing;
        } else if (RIGHT | DOWN in direction) {
            this.compute_widget_point (this.from_widget, this, 1.0f, 0.5f, out from_point_global);
            this.compute_widget_point (this.to_widget, this.align_widget, 0.5f, 1.0f, out to_point_global);
            from_point_global.y += this.spacing;
            to_point_global.x += this.spacing;
        } else {
            this.compute_widget_point (this.from_widget, this, 0.0f, 0.5f, out from_point_global);
            this.compute_widget_point (this.to_widget, this.align_widget, 0.5f, 1.0f, out to_point_global);
            from_point_global.y -= this.spacing;
            to_point_global.x += this.spacing;
        }
    }

    private bool compute_widget_point (Gtk.Widget widget, Gtk.Widget align_widget, float d_x, float d_y, out Graphene.Point out_point_global) {
        Graphene.Point point_local = {
            x: widget.get_width () * d_x,
            y: widget.get_height () * d_y
        };
        return widget.compute_point (align_widget, point_local, out out_point_global);
    }

    private void clamp_point (Graphene.Point point, out Graphene.Point out_point) {
        int max_width = this.get_width ();
        int max_height = this.get_height ();
        out_point = {
            x: point.x.clamp (0, max_width),
            y: point.y.clamp (0, max_height)
        };
    }

    private ArrowDirection get_arrow_direction () {
        ArrowDirection direction;

        Graphene.Point from_center_global;
        Graphene.Point to_center_global;

        this.compute_widget_point (this.from_widget, this, 0.5f, 0.5f, out from_center_global);
        this.compute_widget_point (this.to_widget, this.align_widget, 0.5f, 0.5f, out to_center_global);

        float d_x = to_center_global.x - from_center_global.x;
        float d_y = to_center_global.y - from_center_global.y;

        if (d_x > 0) {
            direction |= RIGHT;
        } else if (d_x < 0) {
            direction |= LEFT;
        } else {
            direction |= NONE;
        }

        if (d_y > 0) {
            direction |= DOWN;
        } else if (d_y < 0) {
            direction |= UP;
        } else {
            direction |= NONE;
        }

        return direction;
    }
}

}
