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

/* TODO: It would be nice to move some of this code to a UI file built with
 *       Glade. Especially anything involving long strings. */
private class WelcomePanel : Gtk.Stack {
    private BreakManager break_manager;
    private MainWindow main_window;

    private enum Step {
        WELCOME,
        BREAKS,
        READY
    }
    private Step current_step;

    private Gtk.Container start_page;
    private Gtk.Container breaks_page;
    private Gtk.Container ready_page;

    public WelcomePanel (BreakManager break_manager, Gtk.Builder builder, MainWindow main_window) {
        GLib.Object ();

        this.break_manager = break_manager;
        this.main_window = main_window;

        if (this.break_manager.master_enabled) {
            this.current_step = Step.READY;
        } else {
            this.current_step = Step.WELCOME;
        }

        this.set_transition_type (Gtk.StackTransitionType.SLIDE_LEFT);
        this.set_transition_duration (250);

        this.start_page = this.build_page_with_arrow (
            builder, "welcome_start", "switch_on_label", main_window.get_master_switch ());
        this.add (this.start_page);

        this.breaks_page = this.build_page_with_arrow (
            builder, "welcome_breaks", "settings_label", main_window.get_settings_button ());
        this.add (this.breaks_page);

        this.ready_page = this.build_page_with_arrow (
            builder, "welcome_ready", "keeps_running_label", main_window.get_close_button ());
        this.add (this.ready_page);

        var breaks_ok_button = new Gtk.Button.with_label (_("OK, got it!"));
        breaks_ok_button.get_style_context ().add_class ("suggested-action");
        breaks_ok_button.set_halign (Gtk.Align.CENTER);
        this.breaks_page.add (breaks_ok_button);
        breaks_ok_button.clicked.connect (this.on_breaks_confirmed);

        var ready_ok_button = new Gtk.Button.with_label (_("Ready to go"));
        ready_ok_button.get_style_context ().add_class ("suggested-action");
        ready_ok_button.set_halign (Gtk.Align.CENTER);
        this.ready_page.add (ready_ok_button);
        ready_ok_button.clicked.connect (this.on_ready_confirmed);

        break_manager.notify["master-enabled"].connect (this.on_master_switch_toggled);
    }

    public signal void tour_finished ();

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

    private Gtk.Container build_page_with_arrow (Gtk.Builder builder, string page_name, string? arrow_source_name, Gtk.Widget? arrow_target) {
        Gtk.Grid page_wrapper = new Gtk.Grid ();
        page_wrapper.set_orientation (Gtk.Orientation.VERTICAL);
        page_wrapper.set_row_spacing (16);
        page_wrapper.set_margin_bottom (30);

        Gtk.Overlay page_overlay = new Gtk.Overlay ();
        page_wrapper.add (page_overlay);

        page_overlay.add (builder.get_object (page_name) as Gtk.Widget);
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
            this.set_visible_child (this.start_page);
        } else if (this.current_step == Step.BREAKS) {
            this.set_visible_child (this.breaks_page);
        } else {
            this.set_visible_child (this.ready_page);
        }
    }
}

}
