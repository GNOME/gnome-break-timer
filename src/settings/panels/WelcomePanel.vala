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

/* TODO: It would be nice to move some of this code to a UI file built with
 *       Glade. Especially anything involving long strings. */
private class WelcomePanel : Gtk.Box {
    private BreakManager break_manager;
    private MainWindow main_window;

    private enum Step {
        WELCOME,
        BREAKS,
        READY
    }
    private Step current_step;

    private Gtk.Stack stack;

    private Gtk.Box start_page;
    private Gtk.Box breaks_page;
    private Gtk.Box ready_page;

    public signal void tour_finished ();

    public WelcomePanel (BreakManager break_manager, Gtk.Builder builder, MainWindow main_window) {
        GLib.Object (orientation: Gtk.Orientation.VERTICAL, spacing: 0);

        this.break_manager = break_manager;
        this.main_window = main_window;

        this.stack = new Gtk.Stack ();
        this.append (this.stack);
        this.stack.show ();

        if (this.break_manager.master_enabled) {
            this.current_step = Step.READY;
        } else {
            this.current_step = Step.WELCOME;
        }

        this.stack.set_transition_type (Gtk.StackTransitionType.SLIDE_LEFT);
        this.stack.set_transition_duration (250);

        this.start_page = this.build_page_with_arrow (
            builder, "welcome_start", "switch_on_label", main_window.get_master_switch ());
        this.stack.add_child (this.start_page);

        this.breaks_page = this.build_page_with_arrow (
            builder, "welcome_breaks", "settings_label", main_window.get_settings_button ());
        this.stack.add_child (this.breaks_page);

        this.ready_page = this.build_page_with_arrow (
            builder, "welcome_ready", "keeps_running_label", main_window.get_close_button ());
        this.stack.add_child (this.ready_page);

        var breaks_ok_button = new Gtk.Button.with_label (_("OK, got it!"));
        breaks_ok_button.get_style_context ().add_class ("suggested-action");
        breaks_ok_button.set_halign (Gtk.Align.CENTER);
        this.breaks_page.append (breaks_ok_button);
        breaks_ok_button.clicked.connect (this.on_breaks_confirmed);

        var ready_ok_button = new Gtk.Button.with_label (_("Ready to go"));
        ready_ok_button.get_style_context ().add_class ("suggested-action");
        ready_ok_button.set_halign (Gtk.Align.CENTER);
        this.ready_page.append (ready_ok_button);
        ready_ok_button.clicked.connect (this.on_ready_confirmed);

        break_manager.notify["master-enabled"].connect (this.on_master_switch_toggled);
    }

    public bool is_active () {
        return this.current_step < Step.READY;
    }

    internal void settings_button_clicked () {
        if (this.current_step == Step.BREAKS) {
            this.on_breaks_confirmed ();
        }
    }

    private void on_master_switch_toggled () {
        if (this.break_manager.master_enabled) {
            this.advance_current_step (Step.BREAKS);
        } else {
            // TODO: Should we jump back to the first step, or keep going?
        }
    }

    private Gtk.Box build_page_with_arrow (Gtk.Builder builder, string page_name, string? arrow_source_name, Gtk.Widget? arrow_target) {
        Gtk.Box page_wrapper = new Gtk.Box (Gtk.Orientation.VERTICAL, 16);
        page_wrapper.set_margin_bottom (30);

        Gtk.Overlay page_overlay = new Gtk.Overlay ();
        page_wrapper.append (page_overlay);

        page_overlay.set_child (builder.get_object (page_name) as Gtk.Widget);
        Gtk.Widget arrow_source = builder.get_object (arrow_source_name) as Gtk.Widget;
        if (arrow_source != null && arrow_target != null) {
            var arrow = new OverlayArrow (arrow_source, arrow_target);
            page_overlay.add_overlay (arrow);
        }

        return page_wrapper;
    }

    private void on_breaks_confirmed () {
        this.advance_current_step (Step.READY);
    }

    private void on_ready_confirmed () {
        this.tour_finished ();
    }

    private void advance_current_step (Step next_step) {
        if (next_step > this.current_step) this.current_step = next_step;

        if (this.current_step == Step.WELCOME) {
            this.stack.set_visible_child (this.start_page);
        } else if (this.current_step == Step.BREAKS) {
            this.stack.set_visible_child (this.breaks_page);
        } else {
            this.stack.set_visible_child (this.ready_page);
        }
    }
}

}
