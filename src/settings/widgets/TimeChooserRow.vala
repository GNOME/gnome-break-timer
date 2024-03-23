/* TimeChooser.vala
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

using BreakTimer.Common;
using BreakTimer.Settings.TimerBreak;

namespace BreakTimer.Settings.Widgets {

public class TimeChooserRow : Adw.ComboRow {
    private GLib.ListStore list_store;
    private uint custom_option_position = Gtk.INVALID_LIST_POSITION;

    public int time_seconds { get; set; }

    public TimeChooserRow (BreakTimeOption[] default_options) {
        GLib.Object ();

        this.list_store = new GLib.ListStore (typeof (BreakTimeOption));
        foreach (BreakTimeOption option in default_options) {
            this.list_store.append (option);
        }
        this.set_model (this.list_store);

        this.set_expression (
            new Gtk.PropertyExpression (typeof (BreakTimeOption), null, "label")
        );

        this.notify["selected-item"].connect (this.on_selected_item_changed);
        this.notify["time-seconds"].connect (this.on_time_seconds_changed);
    }

    private void on_selected_item_changed () {
        BreakTimeOption? option = (BreakTimeOption) this.get_selected_item ();
        if (option != null) {
            this.time_seconds = option.time_seconds;
        }
    }

    private void on_time_seconds_changed () {
        uint find_position;
        if (this.find_position_for_time_seconds (this.time_seconds, out find_position)) {
            this.set_selected (find_position);
        } else if (this.set_custom_option (this.time_seconds, out find_position)) {
            this.set_selected (find_position);
        }
    }

    private bool set_custom_option (int time_seconds, out uint out_position) {
        BreakTimeOption custom_option = new BreakTimeOption(this.time_seconds);
        if (this.custom_option_position < this.list_store.n_items) {
            this.list_store.remove (this.custom_option_position);
        } else {
            this.custom_option_position = this.list_store.n_items;
        }
        this.list_store.insert (this.custom_option_position, custom_option);
        out_position = this.custom_option_position;
        return true;
    }

    private bool find_position_for_time_seconds (int time_seconds, out uint out_position) {
        for (uint i = 0; i < this.list_store.n_items; i++) {
            BreakTimeOption? option = (BreakTimeOption?) this.list_store.get_object (i);
            if (option == null) {
                continue;
            } else if (option.time_seconds == time_seconds) {
                out_position = i;
                return true;
            }
        }
        out_position = Gtk.INVALID_LIST_POSITION;
        return false;
    }
}

}
