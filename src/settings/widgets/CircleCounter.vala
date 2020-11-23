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

namespace BreakTimer.Settings.Widgets {

/**
 * Displays a countdown using a circle, reminiscent of a countdown timer.
 * This widget can either count down or up, and it can switch between either
 * direction at any time.
 */
public class CircleCounter : Gtk.Widget {
    protected const double LINE_WIDTH = 5.0;
    protected const int DEFAULT_RADIUS = 48;

    /* 10 seconds in microseconds */
    private const int64 FULL_ANIM_TIME = (int64) (10000000 / (Math.PI * 2));

    /* 10 ms in microseconds */
    private const int64 MIN_ANIM_DURATION = 10000;

    /* 500 ms in microseconds */
    private const int64 MAX_ANIM_DURATION = 500000;

    private const double SNAP_INCREMENT = (Math.PI * 2) / 60.0;
    private const double BASE_ANGLE = 1.5 * Math.PI;

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

    private bool first_frame = true;

    private PropertyTransition progress_transition;

    public CircleCounter () {
        GLib.Object ();

        this.set_has_window (false);

        this.get_style_context ().add_class ("_circle-counter");

        this.progress_transition = new PropertyTransition (
            this, "draw-angle", PropertyTransition.calculate_value_double
        );

        this.map.connect (this.on_map_cb);
        this.draw.connect (this.on_draw_cb);
        this.notify["progress"].connect (this.on_progress_notify_cb);
        this.notify["draw-angle"].connect (this.on_draw_angle_notify_cb);
    }

    private void on_progress_notify_cb () {
        double progress_angle = this.get_progress_angle ();

        if (this.first_frame) {
            this.progress_transition.skip (progress_angle);
            this.first_frame = false;
            return;
        }

        // Animate at a consistent speed regardless of the distance covered.
        double change = (progress_angle - this.draw_angle).abs ();
        int64 duration = int64.min(
            (int64) (change * FULL_ANIM_TIME),
            MAX_ANIM_DURATION
        );

        if (duration < MIN_ANIM_DURATION) {
            this.progress_transition.skip (progress_angle);
        } else {
            this.progress_transition.start (progress_angle, EASE_OUT_CUBIC, duration);
        }
    }

    private void on_draw_angle_notify_cb () {
        // TODO: Only redraw if the value has changed enough to be visible.
        //       This will need a value set from the draw function.
        GLib.info ("Draw angle %s", this.draw_angle.to_string ());
        this.queue_draw ();
    }

    private double get_progress_angle () {
        double result = (this.progress * Math.PI * 2.0) % (Math.PI * 2.0);
        int snap_count = (int) (result / SNAP_INCREMENT);
        return (double) snap_count * SNAP_INCREMENT;
    }

    private void on_map_cb () {
        this.first_frame = true;
    }

    private bool on_draw_cb (Cairo.Context cr) {
        Gtk.StyleContext style_context = this.get_style_context ();
        Gtk.StateFlags state = this.get_state_flags ();
        Gtk.Allocation allocation;
        this.get_allocation (out allocation);

        int center_x = allocation.width / 2;
        int center_y = allocation.height / 2;
        int radius = int.min(center_x, center_y);
        double arc_radius = radius - LINE_WIDTH / 2;

        Gdk.RGBA foreground_color = style_context.get_color (state);

        cr.set_operator (Cairo.Operator.MULTIPLY);

        Gdk.cairo_set_source_rgba (cr, foreground_color);
        cr.arc (center_x, center_y, arc_radius, 0, Math.PI * 2.0);
        cr.set_line_width (LINE_WIDTH);
        cr.push_group ();
        cr.stroke ();
        cr.pop_group_to_source ();
        cr.paint_with_alpha (0.3);

        if (this.direction == Direction.COUNT_DOWN) {
            if (this.draw_angle > 0) {
                cr.arc (center_x, center_y, arc_radius, BASE_ANGLE, BASE_ANGLE - this.draw_angle);
            } else {
                // No progress: Draw a full circle (to be gradually emptied)
                cr.arc (center_x, center_y, arc_radius, BASE_ANGLE, BASE_ANGLE + Math.PI * 2.0);
            }
        } else {
            if (this.draw_angle > 0) {
                cr.arc_negative (center_x, center_y, arc_radius, BASE_ANGLE, BASE_ANGLE - this.draw_angle);
            }
            // No progress: Draw nothing (arc will gradually appear)
        }

        Gdk.cairo_set_source_rgba (cr, foreground_color);
        cr.set_line_width (LINE_WIDTH);
        cr.set_line_cap  (Cairo.LineCap.SQUARE);
        cr.stroke ();

        return true;
    }

    public override void get_preferred_width (out int minimum_width, out int natural_width) {
        var diameter = calculate_diameter ();
        minimum_width = diameter;
        natural_width = diameter;
    }

    public override void get_preferred_height (out int minimum_height, out int natural_height) {
        var diameter = calculate_diameter ();
        minimum_height = diameter;
        natural_height = diameter;
    }

    public override void size_allocate (Gtk.Allocation allocation) {
        base.size_allocate (allocation);
    }

    private int calculate_diameter () {
        return 2 * DEFAULT_RADIUS;
    }
}

}
