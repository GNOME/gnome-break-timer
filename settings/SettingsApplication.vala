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

using Gtk;
using GLib;

namespace BreakTimer.Settings {

public class SettingsApplication : Gtk.Application {
    const string app_id = Config.SETTINGS_DESKTOP_ID;
    
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

        ._circle-counter {
            /* borrowed from gnome-clocks/data/css/gnome-clocks.css */
            color: mix(@theme_fg_color, @theme_bg_color, 0.5);
            background-color: mix(@theme_fg_color, @theme_bg_color, 0.85);
        }
        """;

    private BreakManager break_manager;
    private MainWindow main_window;

    public SettingsApplication () {
        Object (application_id: app_id, flags: ApplicationFlags.FLAGS_NONE);
    }
    
    public override void activate () {
        base.activate ();
        
        if (this.break_manager.is_working ()) {
            this.main_window.present ();
        } else {
            // Something may be wrong, but it could just be a delay before the
            // break helper starts. We'll wait before showing the main window.
            this.delayed_start ();
        }
    }
    
    public override void startup () {
        base.startup ();

        /* set up custom gtk style for application */
        Gdk.Screen screen = Gdk.Screen.get_default ();
        Gtk.CssProvider style_provider = new Gtk.CssProvider ();
        
        try {
            style_provider.load_from_data (STYLE_DATA, -1);
        } catch (Error error) {
            stderr.printf ("Error loading style data: %s\n", error.message);
        }
        
        Gtk.StyleContext.add_provider_for_screen (
                screen,
                style_provider,
                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        SimpleAction about_action = new SimpleAction ("about", null);
        this.add_action (about_action);
        about_action.activate.connect (this.on_about_activate_cb);

        SimpleAction quit_action = new SimpleAction ("quit", null);
        this.add_action (quit_action);
        quit_action.activate.connect (this.quit);

        GLib.Menu app_menu = new GLib.Menu ();
        app_menu.append ( _("About"), "app.about");
        app_menu.append ( _("Quit"), "app.quit");
        this.set_app_menu (app_menu);
        
        this.break_manager = new BreakManager (this);
        this.main_window = new MainWindow (this, this.break_manager);
        this.break_manager.load_breaks ();
    }

    private void delayed_start () {
        // Delay up to 500ms waiting for break_manager to initialize
        this.break_manager.break_status_available.connect (this.delayed_start_cb);
        Timeout.add (500, () => { delayed_start_cb (); return false; });
    }

    private void delayed_start_cb () {
        this.break_manager.break_status_available.disconnect (this.delayed_start_cb);
        if (! this.main_window.is_visible ()) {
            this.main_window.present ();
        }
    }

    private void on_about_activate_cb () {
        this.main_window.show_about_dialog ();
    }
}

}
