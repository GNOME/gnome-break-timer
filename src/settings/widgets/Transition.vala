/* Transition.vala
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

// TODO: I'm a little surprised I had to write this and I may be missing
//       something important that already exists.

/**
 * Transition utility designed for Gtk.Widget's tick callback mechanism. Create
 * an instance of this class with a particular output property for intermediate
 * states, as well as a function to compute the value of that property given a
 * start and end value and a easing ratio between the two.
 */
public class PropertyTransition : GLib.Object {
    public delegate GLib.Value CalculateValue (GLib.Value start_value, GLib.Value end_value, double ease);

    public enum EasingFunction {
        LINEAR,
        EASE_OUT_CUBIC;

        public double calculate (double time) {
            switch (this) {
                case LINEAR:
                    return this.linear (time);
                case EASE_OUT_CUBIC:
                    return this.ease_out_cubic (time);
                default:
                    GLib.assert_not_reached ();
            }
        }

        private double linear (double time) {
            return time;
        }

        /*
         * From clutter-easing.c, based on Robert Penner's easing equations, MIT
         * license.
         */
        private double ease_out_cubic (double time) {
            double ease = time - 1;
            return ease * ease * ease + 1;
        }
    }

    private Gtk.Widget widget;
    private string property_name;
    private unowned CalculateValue calculate_value;

    private GLib.Type property_type;

    private EasingFunction easing_function;
    private GLib.Value start_value;
    private GLib.Value target_value;
    private int64 start_frame_time;
    private int64 end_frame_time;

    private uint tick_callback_id;

    public PropertyTransition (Gtk.Widget widget, string property_name, CalculateValue calculate_value) {
        this.widget = widget;
        this.property_name = property_name;
        this.calculate_value = calculate_value;

        GLib.ParamSpec? property_paramspec = widget.get_class ().find_property (property_name);
        GLib.assert_nonnull (property_paramspec);
        this.property_type = property_paramspec.value_type;

        this.tick_callback_id = 0;
    }

    public bool start (GLib.Value target_value, EasingFunction easing_function, int64 duration_microseconds) {
        GLib.warn_if_fail (target_value.type () == this.get_target_property ().type ());

        Gdk.FrameClock? frame_clock = this.widget.get_frame_clock ();

        if (frame_clock == null) {
            return this.skip (target_value);
        }

        this.target_value = target_value;

        this.easing_function = easing_function;
        this.start_frame_time = frame_clock.get_frame_time ();
        this.end_frame_time = this.start_frame_time + duration_microseconds;
        this.start_value = this.get_target_property ();

        if (this.tick_callback_id == 0) {
            this.tick_callback_id = this.widget.add_tick_callback (this.tick_callback);
        }

        return true;
    }

    public bool skip (GLib.Value target_value) {
        this.set_target_property (target_value);
        return true;
    }

    private GLib.Value get_target_property () {
        GLib.Value result = GLib.Value (this.property_type);
        this.widget.get_property (this.property_name, ref result);
        return result;
    }

    private void set_target_property (GLib.Value target_value) {
        this.widget.set_property (this.property_name, target_value);
    }

    private bool tick_callback (Gtk.Widget widget, Gdk.FrameClock frame_clock) {
        int64 now = frame_clock.get_frame_time ();
        bool is_complete = this.set_frame (now);
        if (is_complete) {
            this.tick_callback_id = 0;
            return GLib.Source.REMOVE;
        } else {
            return GLib.Source.CONTINUE;
        }
    }

    private bool set_frame (int64 frame_time) {
        bool is_complete = frame_time >= this.end_frame_time;

        if (is_complete) {
            frame_time = this.end_frame_time;
        }

        int64 time_delta = frame_time - this.start_frame_time;
        int64 time_total = this.end_frame_time - this.start_frame_time;
        double ease = this.easing_function.calculate ((double) time_delta / time_total);

        this.set_target_property (
            this.calculate_value (this.start_value, this.target_value, ease)
        );

        return is_complete;
    }

    public static GLib.Value calculate_value_double (GLib.Value start_value, GLib.Value end_value, double ease) {
        return start_value.get_double () + ease * (end_value.get_double () - start_value.get_double ());
    }
}

}
