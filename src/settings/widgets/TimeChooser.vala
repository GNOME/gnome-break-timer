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

namespace BreakTimer.Settings.Widgets {

public class TimeChooser : Gtk.ComboBox {
    private Gtk.ListStore list_store;

    private Gtk.TreeIter? custom_item;

    private const int OPTION_OTHER = -1;

    public int time_seconds { get; set; }

    public signal void time_selected (int time);

    public TimeChooser (int[] options) {
        GLib.Object ();

        this.list_store = new Gtk.ListStore (3, typeof (string), typeof (string), typeof (int));

        this.set_model (this.list_store);
        this.set_id_column (1);

        Gtk.CellRendererText cell = new Gtk.CellRendererText ();
        this.pack_start (cell, true);
        this.set_attributes (cell, "text", null);

        foreach (int time in options) {
            string label = NaturalTime.instance.get_label_for_seconds (time);
            this.add_option (label, time);
        }
        this.custom_item = null;

        this.changed.connect (this.on_changed);

        this.notify["time-seconds"].connect ((s, p) => {
            this.set_time (this.time_seconds);
        });
    }

    public bool set_time (int seconds) {
        string id = seconds.to_string ();

        bool option_exists = this.set_active_id (id);

        if (!option_exists) {
            if (seconds > 0) {
                Gtk.TreeIter new_option = this.add_custom_option (seconds);
                this.set_active_iter (new_option);
                return true;
            } else {
                return false;
            }
        } else {
            return true;
        }
    }

    public int get_time () {
        return this.time_seconds;
    }

    private Gtk.TreeIter add_option (string label, int seconds) {
        string id = seconds.to_string ();

        Gtk.TreeIter iter;
        this.list_store.append (out iter);
        this.list_store.set (iter, 0, label, 1, id, 2, seconds, -1);

        return iter;
    }

    private Gtk.TreeIter add_custom_option (int seconds) {
        string label = NaturalTime.instance.get_label_for_seconds (seconds);
        string id = seconds.to_string ();

        if (this.custom_item == null) {
            this.list_store.append (out this.custom_item);
            this.list_store.set (this.custom_item, 0, label, 1, id, 2, seconds, -1);
            return this.custom_item;
        } else {
            this.list_store.set (this.custom_item, 0, label, 1, id, 2, seconds, -1);
            return this.custom_item;
        }
    }

    private void on_changed () {
        if (this.get_active () < 0) {
            return;
        }

        Gtk.TreeIter iter;
        this.get_active_iter (out iter);

        int val;
        this.list_store.get (iter, 2, out val);
        if (val == OPTION_OTHER) {
            this.start_custom_input ();
        } else if (val > 0) {
            this.time_seconds = val;
            this.time_selected (val);
        }
    }

    private void start_custom_input () {
        GLib.warning ("Custom time input is not implemented");
    }
}

}
