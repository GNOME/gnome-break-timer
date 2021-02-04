/* CircleCounter.vala
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

using BreakTimer.Common;

namespace BreakTimer.Settings.Widgets {

/**
 * Displays a countdown using a circle, reminiscent of a countdown timer.
 * This widget can either count down or up, and it can switch between either
 * direction at any time.
 */
public class CircleCounter : Gtk.Widget {
    protected const double LINE_WIDTH = 5.0;
    protected const int DEFAULT_RADIUS = 48;

    /* 500 ms in microseconds */
    private const int64 MAX_ANIM_DURATION = 500 * TimeUnit.MICROSECONDS_IN_MILLISECONDS;

    /* 10 ms in microseconds */
    private const int64 MIN_ANIM_DURATION = 10 * TimeUnit.MICROSECONDS_IN_MILLISECONDS;

    /* 10 seconds per rotation in microseconds */
    private const int64 FULL_ANIM_SPEED = (int64) ((10 * TimeUnit.MICROSECONDS_IN_SECONDS) / (Math.PI * 2));

    private const double SNAP_INCREMENT = (Math.PI * 2) / 60.0;
    private const double ANGLE_OFFSET = 1.5 * Math.PI;

    public enum Direction {
        COUNT_DOWN,
        COUNT_UP
    }

    /**
     * The direction of the countdown.
     * COUNT_DOWN: a full circle that disappears as progress increases
     * COUNT_UP: a circle gradually appears as progress increases
     */
    public Direction direction {get; set;}

    /**
     * A value from 0.0 to 1.0, where 1.0 means the count is finished. The
     * circle will be filled by this amount according to the direction
     * property.
     */
    public double progress {set; get;}
    public double draw_angle {set; get;}

    private PropertyTransition draw_angle_transition;
    private bool first_frame = true;

    public CircleCounter () {
        GLib.Object ();

        this.draw_angle_transition = new PropertyTransition (
            this, "draw-angle", PropertyTransition.calculate_value_double
        );

        this.map.connect (this.on_map_cb);
        this.notify["direction"].connect (this.on_direction_notify_cb);
        this.notify["progress"].connect (this.on_progress_notify_cb);
        this.notify["draw-angle"].connect (this.on_draw_angle_notify_cb);
    }

    private void on_direction_notify_cb () {
        // Skip the next frame if we change direction. This is an ugly hack to
        // avoid cases where the circle skips from full (but with COUNT_UP) to
        // empty (but with COUNT_DOWN).
        this.first_frame = true;
    }

    private void on_progress_notify_cb () {
        double progress = this.progress.abs ().clamp (0.0, 1.0);
        double progress_angle = this.calculate_draw_angle (progress);

        if (this.first_frame) {
            this.draw_angle_transition.skip (progress_angle);
            this.first_frame = false;
            return;
        }

        // Animate at a consistent speed regardless of the distance covered.
        double change = (progress_angle - this.draw_angle).abs ();
        int64 duration = int64.min (
            (int64) (change * FULL_ANIM_SPEED),
            MAX_ANIM_DURATION
        );

        if (duration < MIN_ANIM_DURATION) {
            this.draw_angle_transition.skip (progress_angle);
        } else {
            this.draw_angle_transition.start (progress_angle, EASE_OUT_CUBIC, duration);
        }
    }

    private void on_draw_angle_notify_cb () {
        // TODO: Only redraw if the value has changed enough to be visible.
        //       This will need a value set from the draw function.
        this.queue_draw ();
    }

    private double calculate_draw_angle (double progress) {
        double result = progress * Math.PI * 2.0;
        int snap_count = (int) (result / SNAP_INCREMENT);
        return (double) snap_count * SNAP_INCREMENT;
    }

    private void on_map_cb () {
        this.first_frame = true;
    }

    public override void snapshot (Gtk.Snapshot snapshot) {
        Graphene.Rect bounds;
        this.compute_bounds (this, out bounds);

        Cairo.Context cr = snapshot.append_cairo (bounds);

        Gdk.RGBA foreground_color = this.get_color ();

        int center_x = (int) bounds.get_width () / 2;
        int center_y = (int) bounds.get_height () / 2;
        int radius = int.min (center_x, center_y);
        double arc_radius = radius - LINE_WIDTH / 2;

        cr.set_operator (Cairo.Operator.OVER);

        Gdk.cairo_set_source_rgba (cr, foreground_color);
        cr.arc (center_x, center_y, arc_radius, 0, Math.PI * 2.0);
        cr.set_line_width (LINE_WIDTH);
        cr.push_group ();
        cr.stroke ();
        cr.pop_group_to_source ();
        cr.paint_with_alpha (0.2);

        Gdk.cairo_set_source_rgba (cr, foreground_color);
        if (this.direction == Direction.COUNT_DOWN) {
            if (this.draw_angle > 0) {
                cr.arc (center_x, center_y, arc_radius, ANGLE_OFFSET, ANGLE_OFFSET - this.draw_angle);
            } else {
                // No progress: Draw a full circle (to be gradually emptied)
                cr.arc (center_x, center_y, arc_radius, ANGLE_OFFSET, ANGLE_OFFSET + Math.PI * 2.0);
            }
        } else {
            if (this.draw_angle > 0) {
                cr.arc_negative (center_x, center_y, arc_radius, ANGLE_OFFSET, ANGLE_OFFSET - this.draw_angle);
            }
            // No progress: Draw nothing (arc will gradually appear)
        }
        cr.set_line_width (LINE_WIDTH);
        cr.set_line_cap  (Cairo.LineCap.SQUARE);
        cr.push_group ();
        cr.stroke ();
        cr.pop_group_to_source ();
        cr.paint_with_alpha (0.7);
    }

    public override void measure (Gtk.Orientation orientation, int for_size, out int minimum, out int natural, out int minimum_baseline, out int natural_baseline) {
        var diameter = calculate_diameter ();

        // This widget has a square aspect ratio, so we aren't concerned about orientation
        minimum = diameter;
        natural = diameter;
        minimum_baseline = -1;
        natural_baseline = -1;
    }

    private int calculate_diameter () {
        return 2 * DEFAULT_RADIUS;
    }
}

}
