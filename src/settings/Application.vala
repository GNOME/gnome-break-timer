/* Application.vala
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

namespace BreakTimer.Settings {

public class Application : Adw.Application {
    private const string STYLE_DATA =
        """
        ._settings-title {
            font-weight:bold;
        }

        ._break-info {
        }

        ._break-info-heading {
            font-size: xx-large;
        }

        ._break-status-heading {
            font-size: larger;
        }

        ._break-status-body {
        }

        ._break-status-hint {
            font-size: small;
        }

        ._break-status-icon {
            opacity: 0.2;
        }
        """;

    private BreakManager break_manager;
    private MainWindow main_window;
    private bool initial_focus = true;

    public Application () {
        GLib.Object (
            application_id: Config.SETTINGS_APPLICATION_ID,
            flags: GLib.ApplicationFlags.FLAGS_NONE
        );
    }

    public override void activate () {
        base.activate ();

        if (this.break_manager.is_working ()) {
            this.main_window.present ();
        } else {
            // Something may be wrong, but it could just be a delay before the
            // break daemon starts. We'll wait before showing the main window.
            this.delayed_start ();
        }
    }

    public override void startup () {
        base.startup ();

        /* set up custom gtk style for application */
        Gtk.CssProvider style_provider = new Gtk.CssProvider ();

        // FIXME
        // try {
        //     style_provider.load_from_data (STYLE_DATA, -1);
        // } catch (GLib.Error error) {
        //     GLib.warning ("Error loading style data: %s", error.message);
        // }

        Gtk.StyleContext.add_provider_for_display (
            Gdk.Display.get_default (),
            style_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        );

        GLib.SimpleAction about_action = new GLib.SimpleAction ("about", null);
        this.add_action (about_action);
        about_action.activate.connect (this.on_about_activate_cb);

        GLib.SimpleAction quit_action = new GLib.SimpleAction ("quit", null);
        this.add_action (quit_action);
        quit_action.activate.connect (this.quit);

        this.set_accels_for_action ("app.quit", {"<Primary>q"});

        this.break_manager = new BreakManager ();
        try {
            this.break_manager.init (null);
        } catch (GLib.Error error) {
            GLib.error ("Error initializing break_manager: %s", error.message);
        }

        this.main_window = new MainWindow (this, this.break_manager);
        try {
            this.main_window.init (null);
        } catch (GLib.Error error) {
            GLib.error ("Error initializing main_window: %s", error.message);
        }

        if (Config.BUILD_PROFILE == "development") {
            this.main_window.add_css_class ("devel");
        }

        this.main_window.get_surface ().event.connect (this.on_main_window_event);
    }

    private bool on_main_window_event (Gdk.Event event) {
        if (event.get_event_type () != Gdk.EventType.FOCUS_CHANGE) {
            return false;
        }

        Gdk.FocusEvent focus_event = (Gdk.FocusEvent) event;
        bool focused = focus_event.get_in ();

        if (focused && this.initial_focus && this.break_manager.master_enabled) {
            // We should always refresh permissions at startup if enabled. Wait
            // for a moment after the main window is focused before doing this,
            // because it may trigger a system dialog.
            this.initial_focus = false;
            GLib.Timeout.add (500, () => {
                this.break_manager.refresh_permissions ();
                return GLib.Source.REMOVE;
            });
        } else if (focused && this.break_manager.permissions_error != NONE) {
            // Refresh permissions on focus if there was an error, and, for
            // example, we are returning from GNOME Settings
            this.break_manager.refresh_permissions ();
        }

        return false;
    }

    private void delayed_start () {
        // Wait 500ms for break_manager to appear
        this.break_manager.break_status_available.connect (this.delayed_start_cb);
        GLib.Timeout.add (500, () => {
            delayed_start_cb ();
            return GLib.Source.REMOVE;
        });
    }

    private void delayed_start_cb () {
        this.break_manager.break_status_available.disconnect (this.delayed_start_cb);
        if (! this.main_window.is_visible ()) {
            this.main_window.present ();
        }
    }

    private void on_about_activate_cb () {
        this.show_about_dialog ();
    }

    private void show_about_dialog () {
        Adw.AboutWindow dialog = new Adw.AboutWindow ();
        dialog.set_destroy_with_parent (true);
        dialog.set_transient_for (this.get_active_window ());
        dialog.set_modal (true);

        dialog.application_name = _("Break Timer");
        dialog.application_icon = Config.APPLICATION_ID;
        dialog.version = Config.PROJECT_VERSION;
        dialog.issue_url = Config.APPLICATION_ISSUES_URL;
        dialog.website = Config.APPLICATION_URL;
        dialog.copyright = _("Copyright © 2011-2023 Break Timer Authors");
        dialog.license_type = Gtk.License.GPL_3_0;
        dialog.developers = {
            "Dylan McCall <dylan@dylanmccall.ca>",
            "Jasper St. Pierre <jstpierre@mecheye.net>"
        };
        dialog.designers = {
            "Allan Day <aday@gnome.org>"
        };
        dialog.translator_credits = _("translator-credits");

        dialog.present ();
    }
}

}
