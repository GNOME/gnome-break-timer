/* StatusPanel.vala
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

using BreakTimer.Settings.Break;

namespace BreakTimer.Settings.Panels {

private class StatusPanel : Gtk.Box, GLib.Initable {
    private BreakManager break_manager;

    private Gtk.Stack stack;
    private Gtk.Box breaks_list;
    private Gtk.Widget no_breaks_message;
    private Gtk.Widget error_message;

    public StatusPanel (BreakManager break_manager, Gtk.Builder builder) {
        GLib.Object (orientation: Gtk.Orientation.VERTICAL, spacing: 0);

        this.break_manager = break_manager;

        this.set_margin_top (20);
        this.set_margin_end (20);
        this.set_margin_bottom (20);
        this.set_margin_start (20);
        this.set_hexpand (true);
        this.set_vexpand (true);

        this.stack = new Gtk.Stack ();
        this.append (this.stack);

        this.breaks_list = this.build_breaks_list (break_manager);
        this.stack.add_child (this.breaks_list);

        this.no_breaks_message = builder.get_object ("status_stopped") as Gtk.Widget;
        this.stack.add_child (this.no_breaks_message);

        this.error_message = builder.get_object ("status_error") as Gtk.Widget;
        this.stack.add_child (this.error_message);

        break_manager.status_changed.connect (this.status_changed_cb);
    }

    public bool init (GLib.Cancellable? cancellable) throws GLib.Error {
        foreach (BreakType break_type in this.break_manager.all_breaks ()) {
            var status_widget = break_type.status_widget;
            this.breaks_list.append (status_widget);
            status_widget.set_margin_top (18);
            status_widget.set_margin_end (20);
            status_widget.set_margin_bottom (18);
            status_widget.set_margin_start (20);
        }

        return true;
    }

    private Gtk.Box build_breaks_list (BreakManager break_manager) {
        var breaks_list = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        breaks_list.set_halign (Gtk.Align.CENTER);
        breaks_list.set_valign (Gtk.Align.CENTER);

        return breaks_list;
    }

    private void status_changed_cb () {
        bool any_breaks_enabled = false;

        unowned List<BreakType> all_breaks = this.break_manager.all_breaks ();
        foreach (BreakType break_type in all_breaks) {
            var status = break_type.status;
            if (status != null) {
                if (status.is_enabled) {
                    break_type.status_widget.show ();
                    any_breaks_enabled = true;
                } else {
                    break_type.status_widget.hide ();
                }
            }
        }

        if (any_breaks_enabled) {
            this.stack.set_visible_child (this.breaks_list);
        } else if (this.break_manager.is_working ()) {
            this.stack.set_visible_child (this.no_breaks_message);
        } else {
            this.stack.set_visible_child (this.error_message);
        }
    }
}

}
