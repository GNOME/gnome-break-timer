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

namespace BreakTimer.Helper {

public class HelperApplication : Gtk.Application {
    const string app_id = Config.HELPER_DESKTOP_ID;
    const string app_name = _("GNOME Break Timer");
    const int DATA_VERSION = 0;
    
    private static const string STYLE_DATA =
        """
        @define-color bg_top rgba(218, 236, 237, 0.80);
        @define-color bg_middle rgba(226, 237, 236, 0.87);
        @define-color bg_bottom rgba(179, 209, 183, 0.89);

        GtkWindow._screen-overlay {
            background-color: @bg_inner;
            background-image:-gtk-gradient (linear,
                   center top,
                   center bottom,
                   color-stop (0, @bg_top),
                   color-stop (0.08, @bg_middle),
                   color-stop (0.92, @bg_middle),
                   color-stop (1, @bg_bottom));
            font-size: 18px;
            color: #999;
        }

        GtkLabel._timer-label {
            font-weight: bold;
            font-size: 36px;
            color: #333;
            text-shadow: 1px 1px 5px rgba (0, 0, 0, 0.5);
        }
        """;

    private BreakManager break_manager;
    private ISessionStatus session_status;
    private ActivityMonitorBackend activity_monitor_backend;
    private ActivityMonitor activity_monitor;
    private UIManager ui_manager;

    private string cache_path;

    public HelperApplication () {
        Object (
            application_id: app_id,
            register_session: true,
            flags: ApplicationFlags.FLAGS_NONE
        );
        Environment.set_application_name (app_name);
        
        // Keep running for one minute after the last break is disabled
        this.set_inactivity_timeout (60 * 1000);

        string user_cache_path = Environment.get_user_cache_dir ();
        this.cache_path = Path.build_filename (user_cache_path, "gnome-break-timer");
    }

    public override void activate () {
        base.activate ();
    }

    public override void startup () {
        base.startup ();

        Notify.init (app_name);
        
        /* set up custom gtk style for application */
        Gdk.Screen screen = Gdk.Screen.get_default ();
        Gtk.CssProvider style_provider = new Gtk.CssProvider ();
        
        try {
            style_provider.load_from_data (STYLE_DATA, -1);
        } catch (Error error) {
            GLib.warning ("Error loading style data: %s", error.message);
        }
        
        Gtk.StyleContext.add_provider_for_screen (
            screen,
            style_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        );
        
        this.session_status = new SessionStatus (this);

        try {
            this.activity_monitor_backend = new MutterActivityMonitorBackend ();
        } catch {
            GLib.error ("Failed to initialize activity monitor backend");
        }
        this.activity_monitor = new ActivityMonitor (session_status, activity_monitor_backend);
        
        this.ui_manager = new UIManager (this, session_status, false);
        this.break_manager = new BreakManager (ui_manager);
        this.break_manager.load_breaks (activity_monitor);

        this.restore_state ();

        this.activity_monitor.start ();

        var connection = this.get_dbus_connection ();
        if (connection != null) {
            Bus.own_name_on_connection (connection, Config.HELPER_BUS_NAME, BusNameOwnerFlags.REPLACE, null, null);
        }
    }

    public override void shutdown () {
        base.shutdown ();

        this.save_state ();
    }

    private File get_state_file () {
        File cache_dir = File.new_for_path (this.cache_path);
        try {
            if (! cache_dir.query_exists ()) cache_dir.make_directory_with_parents ();
        } catch (Error e) {
            GLib.warning ("Error creating cache directory: %s", e.message);
        }
        string state_file_name = "last-state-%d".printf (DATA_VERSION);
        return cache_dir.get_child (state_file_name);
    }

    private void save_state () {
        File state_file = this.get_state_file ();

        Json.Generator generator = new Json.Generator ();
        Json.Node root = new Json.Node (Json.NodeType.OBJECT);
        Json.Object root_object = new Json.Object ();
        root.set_object (root_object);
        generator.set_root (root);

        root_object.set_object_member ("break_manager", this.break_manager.serialize ());
        root_object.set_object_member ("activity_monitor_backend", this.activity_monitor_backend.serialize ());
        root_object.set_object_member ("activity_monitor", this.activity_monitor.serialize ());

        try {
            OutputStream state_stream = state_file.replace (null, false, FileCreateFlags.NONE);
            generator.to_stream (state_stream);
        } catch (Error e) {
            GLib.warning ("Error writing to state file: %s", e.message);
        }
    }

    private void restore_state () {
        File state_file = this.get_state_file ();
        if (state_file.query_exists ()) {
            Json.Parser parser = new Json.Parser ();

            try {
                InputStream state_stream = state_file.read ();
                parser.load_from_stream (state_stream);
            } catch (Error e) {
                GLib.warning ("Error reading state file: %s", e.message);
            }

            Json.Node? root = parser.get_root ();
            if (root != null) {
                Json.Object root_object = root.get_object ();

                Json.Object break_manager_json = root_object.get_object_member ("break_manager");
                this.break_manager.deserialize (ref break_manager_json);

                Json.Object activity_monitor_backend_json = root_object.get_object_member ("activity_monitor_backend");
                this.activity_monitor_backend.deserialize (ref activity_monitor_backend_json);

                Json.Object activity_monitor_json = root_object.get_object_member ("activity_monitor");
                this.activity_monitor.deserialize (ref activity_monitor_json);

                this.activity_monitor.poll_activity ();
            }
        }
    }
}

}
