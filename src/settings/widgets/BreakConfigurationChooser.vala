/* BreakConfigurationChooser.vala
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

class BreakConfigurationChooser : Adw.ComboRow {
    public class Configuration : GLib.Object {
        public string[] break_ids { get; private set; }
        public string label { get; private set; }

        public Configuration (string[] break_ids, string label) {
            this.break_ids = break_ids;
            this.label = label;
        }

        public bool matches_breaks (string[] test_break_ids) {
            if (test_break_ids.length == this.break_ids.length) {
                foreach (string test_break_id in test_break_ids) {
                    if (! (test_break_id in this.break_ids)) return false;
                }
                return true;
            } else {
                return false;
            }
        }
    }

    private GLib.ListStore list_store;

    public string[] selected_break_ids { public get; public set; }

    public BreakConfigurationChooser () {
        GLib.Object (use_subtitle: true);

        this.title = _("Choose your break schedule");

        this.list_store = new GLib.ListStore (typeof (Configuration));
        this.set_model (this.list_store);
        this.set_expression (
            new Gtk.PropertyExpression (typeof (Configuration), null, "label")
        );

        this.notify["selected-item"].connect (this.on_selected_item_changed);
        this.notify["selected-break-ids"].connect (this.on_selected_break_ids_changed);
    }

    public void add_configuration (string[] break_ids, string label) {
        var configuration = new Configuration (break_ids, label);
        this.list_store.append (configuration);
    }

    private void on_selected_item_changed () {
        Configuration? configuration = (Configuration) this.get_selected_item ();
        if (configuration != null) {
            this.selected_break_ids = configuration.break_ids;
        }
    }

    private void on_selected_break_ids_changed () {
        uint find_position;
        if (this.find_position_for_selected_breaks (this.selected_break_ids, out find_position)) {
            this.set_selected (find_position);
        }
    }

    private bool find_position_for_selected_breaks (string[] selected_breaks, out uint out_position) {
        for (uint i = 0; i < this.list_store.n_items; i++) {
            Configuration? configuration = (Configuration?) this.list_store.get_object (i);
            if (configuration == null) {
                continue;
            } else if (configuration.matches_breaks (selected_breaks)) {
                out_position = i;
                return true;
            }
        }
        out_position = Gtk.INVALID_LIST_POSITION;
        return false;
    }
}

}
