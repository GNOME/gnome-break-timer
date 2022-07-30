/* BreakSettingsDialog.vala
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
using BreakTimer.Settings.Widgets;

namespace BreakTimer.Settings {

public class BreakSettingsDialog : Adw.PreferencesWindow {
    private BreakManager break_manager;

    private Adw.PreferencesPage main_preferences_page;

    private BreakConfigurationChooser configuration_chooser;

    public BreakSettingsDialog (BreakManager break_manager) {
        GLib.Object (
            search_enabled: false
        );

        this.break_manager = break_manager;

        GLib.Settings settings = new GLib.Settings (Config.APPLICATION_ID);

        this.main_preferences_page = new Adw.PreferencesPage ();
        this.add (this.main_preferences_page);

        var global_preferences_group = new Adw.PreferencesGroup ();
        this.main_preferences_page.add (global_preferences_group);

        this.configuration_chooser = new BreakConfigurationChooser ();
        global_preferences_group.add (this.configuration_chooser);

        foreach (BreakType break_type in this.break_manager.all_breaks ()) {
            this.main_preferences_page.add (break_type.settings_widget);
        }

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

        this.configuration_chooser.notify["selected-break-ids"].connect (this.update_break_configuration);
    }

    public bool init (GLib.Cancellable? cancellable) throws GLib.Error {
        this.update_break_configuration ();

        return true;
    }

    private void update_break_configuration () {
        // TODO: Create a stack with a child for each configuration. Switch
        //       between these instead of showing / hiding widgets.

        foreach (BreakType break_type in this.break_manager.all_breaks ()) {
            break_type.settings_widget.set_visible (break_type.id in this.configuration_chooser.selected_break_ids);
        }
    }
}

}
