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

using BreakTimer.Common;
using BreakTimer.Daemon.Activity;

namespace BreakTimer.Daemon {

public class Application : Gtk.Application {
    const string app_name = _("GNOME Break Timer");
    const int DATA_VERSION = 0;

    // Keep running for one minute after the last break is disabled
    private const int ACTIVITY_TIMEOUT_MS = 60000;

    private BreakManager break_manager;
    private ISessionStatus session_status;
    private ActivityMonitorBackend activity_monitor_backend;
    private ActivityMonitor activity_monitor;
    private UIManager ui_manager;

    private string cache_path;

    public Application () {
        GLib.Object (
            application_id: Config.DAEMON_APPLICATION_ID,
            flags: ApplicationFlags.FLAGS_NONE,
            inactivity_timeout: ACTIVITY_TIMEOUT_MS,
            register_session: true
        );

        GLib.Environment.set_application_name (app_name);

        string user_cache_path = GLib.Environment.get_user_cache_dir ();
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

        Gtk.StyleContext.add_provider_for_screen (
            screen,
            style_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        );

        this.session_status = new SessionStatus (this);

        this.activity_monitor_backend = new MutterActivityMonitorBackend ();
        this.activity_monitor = new ActivityMonitor (session_status, activity_monitor_backend);

        this.ui_manager = new UIManager (this, session_status);
        this.break_manager = new BreakManager (ui_manager);
        this.break_manager.load_breaks (activity_monitor);

        this.restore_state ();

        this.activity_monitor.start ();
    }

    public override void shutdown () {
        base.shutdown ();

        this.save_state ();
    }

    private GLib.File get_state_file () {
        GLib.File cache_dir = GLib.File.new_for_path (this.cache_path);
        try {
            if (! cache_dir.query_exists ()) cache_dir.make_directory_with_parents ();
        } catch (GLib.Error e) {
            GLib.warning ("Error creating cache directory: %s", e.message);
        }
        string state_file_name = "last-state-%d".printf (DATA_VERSION);
        return cache_dir.get_child (state_file_name);
    }

    private void save_state () {
        GLib.File state_file = this.get_state_file ();

        Json.Generator generator = new Json.Generator ();
        Json.Node root = new Json.Node (Json.NodeType.OBJECT);
        Json.Object root_object = new Json.Object ();
        root.set_object (root_object);
        generator.set_root (root);

        root_object.set_object_member ("break_manager", this.break_manager.serialize ());
        root_object.set_object_member ("activity_monitor_backend", this.activity_monitor_backend.serialize ());
        root_object.set_object_member ("activity_monitor", this.activity_monitor.serialize ());

        try {
            OutputStream state_stream = state_file.replace (null, false, GLib.FileCreateFlags.NONE);
            generator.to_stream (state_stream);
        } catch (GLib.Error e) {
            GLib.warning ("Error writing to state file: %s", e.message);
        }
    }

    private void restore_state () {
        GLib.File state_file = this.get_state_file ();
        if (state_file.query_exists ()) {
            Json.Parser parser = new Json.Parser ();

            try {
                InputStream state_stream = state_file.read ();
                parser.load_from_stream (state_stream);
            } catch (GLib.Error e) {
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