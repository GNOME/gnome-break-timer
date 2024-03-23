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

using BreakTimer.Common;
using BreakTimer.Daemon.Activity;
using BreakTimer.Daemon.Break;

namespace BreakTimer.Daemon {

public class Application : Gtk.Application {
    const string app_name = _("GNOME Break Timer");
    const int DATA_VERSION = 0;

    // Keep running for one minute after the last break is disabled
    private const int ACTIVITY_TIMEOUT_MS = 60 * TimeUnit.MILLISECONDS_IN_SECONDS;

    // Consider saved state valid if it was created in the last 10 seconds
    private const int SAVE_STATE_EXPIRY_MS = 10 * TimeUnit.MILLISECONDS_IN_SECONDS;

    // Update saved state file every five minutes
    private const int SAVE_STATE_INTERVAL_SECONDS = 60 * 5;

    private BreakManager break_manager;
    private SessionStatus session_status;
    private ActivityMonitorBackend activity_monitor_backend;
    private ActivityMonitor activity_monitor;
    private UIManager ui_manager;

    private uint save_state_timeout_id;
    private string cache_path;
    private int64 state_saved_time_ms;
    private bool is_activated;

    public Application () {
        GLib.Object (
            application_id: Config.DAEMON_APPLICATION_ID,
            flags: ApplicationFlags.FLAGS_NONE,
            inactivity_timeout: ACTIVITY_TIMEOUT_MS,
            register_session: true
        );

        GLib.Environment.set_application_name (app_name);

        this.cache_path = GLib.Path.build_filename (
            GLib.Environment.get_user_cache_dir (),
            "gnome-break-timer"
        );
        this.state_saved_time_ms = 0;

        this.query_end.connect (this.on_query_end_cb);
    }

    public override void startup () {
        base.startup ();

        this.is_activated = false;

        GLib.SimpleAction dismiss_break_action = new GLib.SimpleAction (
            "dismiss-break", new GLib.VariantType("s")
        );
        this.add_action (dismiss_break_action);
        dismiss_break_action.activate.connect (this.on_dismiss_break_activate_cb);

        GLib.SimpleAction show_break_info_action = new GLib.SimpleAction ("show-break-info", null);
        this.add_action (show_break_info_action);
        show_break_info_action.activate.connect (this.on_show_break_info_activate_cb);

        this.session_status = new SessionStatus ();
        try {
            this.session_status.init (null);
        } catch (GLib.Error error) {
            GLib.error ("Error initializing session_status: %s", error.message);
        }

        this.activity_monitor_backend = new MutterActivityMonitorBackend ();
        try {
            this.activity_monitor_backend.init (null);
        } catch (GLib.Error error) {
            GLib.error ("Error initializing activity_monitor_backend: %s", error.message);
        }

        this.activity_monitor = new ActivityMonitor (session_status, activity_monitor_backend);
        try {
            this.activity_monitor.init (null);
        } catch (GLib.Error error) {
            GLib.error ("Error initializing activity_monitor: %s", error.message);
        }

        this.ui_manager = new UIManager (this, session_status);
        try {
            this.ui_manager.init (null);
        } catch (GLib.Error error) {
            GLib.error ("Error initializing ui_manager: %s", error.message);
        }

        this.break_manager = new BreakManager (ui_manager, activity_monitor);
        try {
            this.break_manager.init (null);
        } catch (GLib.Error error) {
            GLib.error ("Error initializing break_manager: %s", error.message);
        }

        this.restore_state ();
        this.start_save_state_timeout ();

        this.activity_monitor.start ();
    }

    /**
     * Open the settings app when activated, for example when the the user
     * chooses Break Timer from the Background Apps section in GNOME Shell.
     * Unfortunately, we are unable to tell the difference between that type of
     * activation, D-Bus activation during session start, and the GApplication
     * activate signal firing when the app starts normally. We will work around
     * that by always ignoring the first call to activate, and by not using
     * D-Bus activation in the daemon's autostart file.
     */
    public override void activate () {
        base.activate ();

        if (!this.is_activated) {
            this.is_activated = true;
            return;
        }

        if (this.break_manager.autostart_version > 1) {
            // Previous versions used D-Bus activation for the autostart
            // file, which would result in this running on session start.
            this.show_break_info ();
        }
    }

    private void start_save_state_timeout () {
        // TODO: As soon as state saving is supported in GLib, use that:
        //       <https://gitlab.gnome.org/GNOME/glib/-/merge_requests/683>
        assert (this.save_state_timeout_id == 0);

        this.save_state_timeout_id = GLib.Timeout.add_seconds (
            SAVE_STATE_INTERVAL_SECONDS, this.save_state_timeout_cb
        );
    }

    private bool save_state_timeout_cb () {
        this.save_state.begin ();
        return GLib.Source.CONTINUE;
    }

    private void on_dismiss_break_activate_cb (GLib.SimpleAction action, GLib.Variant? parameter) {
        BreakType? break_type = this.break_manager.get_break_type_for_name (
            parameter.get_string ()
        );
        if (break_type != null) {
            break_type.break_view.dismiss_break ();
        }
    }

    private void on_show_break_info_activate_cb (GLib.SimpleAction action, GLib.Variant? parameter) {
        GLib.Idle.add_full (
            GLib.Priority.HIGH_IDLE,
            () => {
                this.show_break_info ();
                return false;
            }
        );
    }

    private void show_break_info () {
        GLib.AppInfo settings_app_info = new GLib.DesktopAppInfo (Config.SETTINGS_APPLICATION_ID + ".desktop");
        GLib.AppLaunchContext app_launch_context = new GLib.AppLaunchContext ();
        try {
            settings_app_info.launch (null, app_launch_context);
        } catch (GLib.Error error) {
            GLib.warning ("Error launching settings application: %s", error.message);
        }
    }

    public void on_query_end_cb () {
        GLib.Idle.add_full (
            GLib.Priority.HIGH_IDLE,
            () => {
                this.save_state.begin ();
                return GLib.Source.REMOVE;
            }
        );
    }

    private GLib.File get_state_file () {
        GLib.File cache_dir = GLib.File.new_for_path (this.cache_path);
        try {
            if (! cache_dir.query_exists ()) {
                cache_dir.make_directory_with_parents ();
            }
        } catch (GLib.Error e) {
            GLib.warning ("Error creating cache directory: %s", e.message);
        }
        string state_file_name = "last-state-%d.json".printf (DATA_VERSION);
        return cache_dir.get_child (state_file_name);
    }

    private async void save_state () {
        int64 now = TimeUnit.get_monotonic_time_ms ();

        if (now - this.state_saved_time_ms < SAVE_STATE_EXPIRY_MS) {
            return;
        } else {
            this.state_saved_time_ms = now;
        }

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
            GLib.OutputStream state_stream = yield state_file.replace_async (null, false, GLib.FileCreateFlags.NONE);
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
