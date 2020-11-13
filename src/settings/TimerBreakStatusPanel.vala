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

public abstract class TimerBreakStatusPanel : BreakStatusPanel {
    private string upcoming_text;
    private string ongoing_text;

    private CircleCounter circle_counter;
    private Gtk.Label status_label;
    private Gtk.Label time_label;

    protected TimerBreakStatusPanel (TimerBreakType break_type, string upcoming_text, string ongoing_text) {
        base (break_type);
        this.upcoming_text = upcoming_text;
        this.ongoing_text = ongoing_text;

        this.set_column_spacing (12);

        // FIXME: This is an application icon. It doesn't make sense here.
        this.circle_counter = new CircleCounter ();
        this.attach (this.circle_counter, 0, 0, 1, 1);

        var labels_grid = new Gtk.Grid ();
        this.attach (labels_grid, 1, 0, 1, 1);
        labels_grid.set_orientation (Gtk.Orientation.VERTICAL);
        labels_grid.set_row_spacing (18);
        labels_grid.set_valign (Gtk.Align.CENTER);

        this.status_label = new Gtk.Label (null);
        labels_grid.add (this.status_label);
        this.status_label.set_width_chars (25);
        this.status_label.get_style_context ().add_class ("_break-status-heading");

        this.time_label = new Gtk.Label (null);
        labels_grid.add (this.time_label);
        this.time_label.set_width_chars (25);
        this.time_label.get_style_context ().add_class ("_break-status-body");

        this.show_all ();

        break_type.timer_status_changed.connect (this.timer_status_changed_cb);
    }

    private void timer_status_changed_cb (TimerBreakStatus? status) {
        if (status == null) return;

        TimerBreakType timer_break = (TimerBreakType) this.break_type;

        if (status.is_active) {
            this.status_label.set_label (this.ongoing_text);
            string time_text = NaturalTime.instance.get_countdown_for_seconds_with_start (
                status.time_remaining, status.current_duration);
            this.time_label.set_label (time_text);
            this.circle_counter.direction = CircleCounter.Direction.COUNT_DOWN;
            this.circle_counter.progress = (status.current_duration - status.time_remaining) / (double)status.current_duration;
        } else {
            this.status_label.set_label (this.upcoming_text);
            string time_text = NaturalTime.instance.get_countdown_for_seconds (status.starts_in);
            this.time_label.set_label (time_text);
            this.circle_counter.direction = CircleCounter.Direction.COUNT_UP;
            this.circle_counter.progress = (timer_break.interval - status.starts_in) / (double)timer_break.interval;
        }
    }
}

}
