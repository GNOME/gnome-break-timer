/* WelcomePanel.vala
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

using BreakTimer.Settings.Widgets;

namespace BreakTimer.Settings.Panels {

private class WelcomePanel : Gtk.Box {
    private BreakManager break_manager;
    private MainWindow main_window;

    private Adw.NavigationView navigation_view;

    private Adw.NavigationPage start_page;
    private Adw.NavigationPage breaks_page;
    private Adw.NavigationPage ready_page;

    public signal void tour_finished ();

    public WelcomePanel (BreakManager break_manager, Gtk.Builder builder, MainWindow main_window) {
        GLib.Object (orientation: Gtk.Orientation.VERTICAL, spacing: 0);

        this.break_manager = break_manager;
        this.main_window = main_window;

        this.navigation_view = (Adw.NavigationView) builder.get_object ("welcome_stack");

        this.start_page = (Adw.NavigationPage) builder.get_object ("welcome_start_page");
        this.breaks_page = (Adw.NavigationPage) builder.get_object ("welcome_breaks_page");
        this.ready_page = (Adw.NavigationPage) builder.get_object ("welcome_ready_page");

        var start_overlay = (Gtk.Overlay) builder.get_object ("welcome_start_overlay");
        var breaks_overlay = (Gtk.Overlay) builder.get_object ("welcome_breaks_overlay");

        var breaks_ok_button = (Gtk.Button) builder.get_object ("welcome_breaks_ok_button");
        var ready_ok_button = (Gtk.Button) builder.get_object ("welcome_ready_ok_button");

        breaks_ok_button.clicked.connect (
            () => this.navigation_view.push (this.ready_page)
        );

        ready_ok_button.clicked.connect (
            () => this.tour_finished ()
        );

        this.build_overlay_arrow (
            start_overlay,
            (Gtk.Widget) builder.get_object ("welcome_switch_label"),
            main_window.get_master_switch ()
        );

        this.build_overlay_arrow (
            breaks_overlay,
            (Gtk.Widget) builder.get_object ("welcome_settings_label"),
            main_window.get_settings_button ()
        );

        this.append (this.navigation_view);

        break_manager.notify["master-enabled"].connect (this.on_master_switch_toggled);
    }

    public bool is_active () {
        return this.navigation_view.get_visible_page() == this.start_page || this.navigation_view.get_visible_page() == this.breaks_page;
    }

    internal void settings_button_clicked () {
        if (this.navigation_view.get_visible_page() == this.breaks_page) {
            this.navigation_view.push(this.ready_page);
        }
    }

    private void on_master_switch_toggled () {
        if (!this.break_manager.master_enabled) {
            return;
        }

        if (this.navigation_view.get_visible_page() == this.start_page) {
            this.navigation_view.push(this.breaks_page);
        }
    }

    private void build_overlay_arrow (Gtk.Overlay overlay, Gtk.Widget arrow_source, Gtk.Widget arrow_target) {
        var arrow = new OverlayArrow (arrow_source, arrow_target, this.navigation_view);
        arrow.spacing = 10;
        overlay.add_overlay (arrow);
    }
}

}
