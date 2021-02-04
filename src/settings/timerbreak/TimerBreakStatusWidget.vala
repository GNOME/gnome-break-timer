/* TimerBreakStatusWidget.vala
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
using BreakTimer.Settings.Break;
using BreakTimer.Settings.Widgets;

namespace BreakTimer.Settings.TimerBreak {

public abstract class TimerBreakStatusWidget : BreakStatusWidget {
    private string upcoming_text;
    private string ongoing_text;

    private CircleCounter circle_counter;
    private Gtk.Label status_label;
    private Gtk.Label time_label;

    protected TimerBreakStatusWidget (TimerBreakType break_type, string upcoming_text, string ongoing_text) {
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
        labels_grid.attach (this.status_label, 0, 0, 1, 1);
        this.status_label.set_width_chars (25);
        this.status_label.add_css_class ("heading");

        this.time_label = new Gtk.Label (null);
        labels_grid.attach_next_to (this.time_label, this.status_label, Gtk.PositionType.RIGHT, 1, 1);
        this.time_label.set_width_chars (25);

        this.show ();

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
            this.circle_counter.progress = (status.current_duration - status.time_remaining) / (double) status.current_duration;
        } else {
            this.status_label.set_label (this.upcoming_text);
            string time_text = NaturalTime.instance.get_countdown_for_seconds (status.starts_in);
            this.time_label.set_label (time_text);
            this.circle_counter.direction = CircleCounter.Direction.COUNT_UP;
            this.circle_counter.progress = (timer_break.interval - status.starts_in) / (double) timer_break.interval;
        }
    }
}

}
