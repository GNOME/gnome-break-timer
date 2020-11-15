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

private class StatusPanel : Gtk.Stack {
    private BreakManager break_manager;

    private Gtk.Grid breaks_list;
    private Gtk.Widget no_breaks_message;
    private Gtk.Widget error_message;

    public StatusPanel (BreakManager break_manager, Gtk.Builder builder) {
        GLib.Object ();

        this.break_manager = break_manager;

        this.set_margin_top (20);
        this.set_margin_end (20);
        this.set_margin_bottom (20);
        this.set_margin_start (20);
        this.set_hexpand (true);
        this.set_vexpand (true);

        this.breaks_list = this.build_breaks_list (break_manager);
        this.add (this.breaks_list);

        this.no_breaks_message = builder.get_object ("status_stopped") as Gtk.Widget;
        this.add (this.no_breaks_message);

        this.error_message = builder.get_object ("status_error") as Gtk.Widget;
        this.add (this.error_message);

        break_manager.break_added.connect (this.break_added_cb);
        break_manager.status_changed.connect (this.status_changed_cb);
    }

    private Gtk.Grid build_breaks_list (BreakManager break_manager) {
        var breaks_list = new Gtk.Grid ();
        breaks_list.set_orientation (Gtk.Orientation.VERTICAL);
        breaks_list.set_halign (Gtk.Align.CENTER);
        breaks_list.set_valign (Gtk.Align.CENTER);

        return breaks_list;
    }

    private void break_added_cb (BreakType break_type) {
        var status_panel = break_type.status_panel;
        this.breaks_list.add (status_panel);
        status_panel.set_margin_top (18);
        status_panel.set_margin_end (20);
        status_panel.set_margin_bottom (18);
        status_panel.set_margin_start (20);
    }

    private void status_changed_cb () {
        bool any_breaks_enabled = false;

        unowned List<BreakType> all_breaks = this.break_manager.all_breaks ();
        foreach (BreakType break_type in all_breaks) {
            var status = break_type.status;
            if (status != null) {
                if (status.is_enabled) {
                    break_type.status_panel.show ();
                    any_breaks_enabled = true;
                } else {
                    break_type.status_panel.hide ();
                }
            }
        }

        if (any_breaks_enabled) {
            this.set_visible_child (this.breaks_list);
        } else if (this.break_manager.is_working ()) {
            this.set_visible_child (this.no_breaks_message);
        } else {
            this.set_visible_child (this.error_message);
        }
    }
}

}
