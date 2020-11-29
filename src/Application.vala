/* Application.vala
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

namespace BreakTimer {

public class Application : Gtk.Application {
    public const string APP_NAME = _("GNOME Break Timer");

    // Keep running for one minute after the last break is disabled
    private const int ACTIVITY_TIMEOUT_MS = 60 * TimeUnit.MILLISECONDS_IN_SECONDS;

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

    private Daemon.ApplicationContext daemon_context;
    private Settings.ApplicationContext settings_context;

    public Application () {
        GLib.Object (
            application_id: Config.APPLICATION_ID,
            flags: GLib.ApplicationFlags.FLAGS_NONE,
            inactivity_timeout: ACTIVITY_TIMEOUT_MS,
            register_session: true
        );
        GLib.Environment.set_application_name (APP_NAME);
        this.daemon_context = new Daemon.ApplicationContext (this);
        this.settings_context = new Settings.ApplicationContext (this);
    }

    public override void activate () {
        base.activate ();

        this.daemon_context.activate ();
        this.settings_context.activate ();
    }

    public override void startup () {
        base.startup ();

        /* set up custom gtk style for application */
        Gdk.Screen screen = Gdk.Screen.get_default ();
        Gtk.CssProvider style_provider = new Gtk.CssProvider ();

        try {
            style_provider.load_from_data (STYLE_DATA, -1);
        } catch (GLib.Error error) {
            GLib.warning ("Error loading style data: %s", error.message);
        }

        Gtk.StyleContext.add_provider_for_screen (
            screen,
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

        this.daemon_context.startup ();
        this.settings_context.startup ();
    }

    public override void shutdown () {
        this.daemon_context.shutdown ();
        this.settings_context.shutdown ();
    }

    private void on_about_activate_cb () {
        this.show_about_dialog ();
    }

    private void show_about_dialog () {
        Gtk.AboutDialog dialog = new Gtk.AboutDialog ();
        dialog.set_destroy_with_parent (true);
        dialog.set_transient_for (this.get_active_window ());
        dialog.set_modal (true);

        dialog.authors = {
            "Dylan McCall <dylan@dylanmccall.ca>",
            "Jasper St. Pierre <jstpierre@mecheye.net>"
        };
        dialog.artists = {
            "Allan Day <aday@gnome.org>"
        };
        dialog.program_name = _("Break Timer");
        dialog.logo_icon_name = Config.APPLICATION_ID;
        dialog.version = Config.PROJECT_VERSION;
        dialog.comments = _("Computer break reminders for GNOME");
        dialog.website = Config.APPLICATION_URL;
        dialog.website_label = _("Break Timer Website");
        dialog.copyright = _("Copyright © 2011-2020 Break Timer Authors");
        dialog.license_type = Gtk.License.GPL_3_0;
        dialog.translator_credits = _("translator-credits");

        dialog.present ();
    }
}

}
