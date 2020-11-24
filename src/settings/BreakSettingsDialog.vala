/* BreakSettingsDialog.vala
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

using BreakTimer.Settings.Break;
using BreakTimer.Settings.Widgets;

namespace BreakTimer.Settings {

public class BreakSettingsDialog : Gtk.Dialog {
    private BreakManager break_manager;

    private BreakConfigurationChooser configuration_chooser;
    private Gtk.Grid breaks_grid;

    private const int ABOUT_BUTTON_RESPONSE = 5;

    public BreakSettingsDialog (BreakManager break_manager) {
        GLib.Object (use_header_bar: 1);

        this.break_manager = break_manager;

        GLib.Settings settings = new GLib.Settings ("org.gnome.BreakTimer");

        this.set_title (_("Choose Your Break Schedule"));
        this.set_deletable (true);
        this.set_resizable (false);

        this.delete_event.connect (this.hide_on_delete);

        this.response.connect (this.response_cb);

        Gtk.Container content_area = (Gtk.Container)this.get_content_area ();

        Gtk.Grid content = new Gtk.Grid ();
        content_area.add (content);
        content.set_orientation (Gtk.Orientation.VERTICAL);
        content.set_margin_top (10);
        content.set_margin_start (10);
        content.set_margin_bottom (10);
        content.set_margin_end (10);

        this.configuration_chooser = new BreakConfigurationChooser ();
        content.add (this.configuration_chooser);
        this.configuration_chooser.add_configuration (
            { "microbreak", "restbreak" },
            _("A mix of short breaks and long breaks")
        );
        this.configuration_chooser.add_configuration (
            { "restbreak" },
            _("Occasional long breaks")
        );
        this.configuration_chooser.add_configuration (
            { "microbreak" },
            _("Frequent short breaks")
        );
        settings.bind ("selected-breaks", this.configuration_chooser, "selected-break-ids", SettingsBindFlags.DEFAULT);

        this.breaks_grid = new FixedSizeGrid ();
        content.add (this.breaks_grid);
        this.breaks_grid.set_orientation (Gtk.Orientation.VERTICAL);

        content.show_all ();

        this.configuration_chooser.notify["selected-break-ids"].connect (this.update_break_configuration);
    }

    public bool init (GLib.Cancellable? cancellable) throws GLib.Error {
        foreach (BreakType break_type in this.break_manager.all_breaks ()) {
            var settings_widget = break_type.settings_widget;
            this.breaks_grid.add (settings_widget);
            settings_widget.realize ();
            settings_widget.set_valign (Gtk.Align.CENTER);
            settings_widget.set_vexpand (true);
            settings_widget.set_margin_top (10);
            settings_widget.set_margin_bottom (10);
            this.update_break_configuration ();
        }

        return true;
    }

    private void update_break_configuration () {
        foreach (BreakType break_type in this.break_manager.all_breaks ()) {
            if (break_type.id in this.configuration_chooser.selected_break_ids) {
                break_type.settings_widget.show ();
            } else {
                break_type.settings_widget.hide ();
            }
        }
    }


    private void response_cb (int response_id) {
        if (response_id == Gtk.ResponseType.CLOSE) {
            this.hide ();
        }
    }
}

}
