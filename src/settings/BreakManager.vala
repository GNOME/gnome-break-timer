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

// TODO: This intentionally resembles BreakManager from the daemon
// application. Ideally, it should be common code in the future.

using BreakTimer.Common;

namespace BreakTimer.Settings {

public class BreakManager : GLib.Object {
    private Application application;

    private IBreakTimer break_daemon;

    private Gee.Map<string, BreakType> breaks;
    private GLib.List<BreakType> breaks_ordered;

    private GLib.Settings settings;
    public bool master_enabled { get; set; }
    public string[] selected_break_ids { get; set; }
    public BreakType? foreground_break { get; private set; }

    IBackgroundPortal? background_portal = null;

    public BreakManager (Application application) {
        this.application = application;
        this.breaks = new Gee.HashMap<string, BreakType> ();
        this.breaks_ordered = new GLib.List<BreakType> ();

        if (this.get_is_in_flatpak ()) {
            // TODO: Does this work outside of a flatpak? We could remove the
            // extra file we install in data/autostart, which would be nice.
            try {
                this.background_portal = GLib.Bus.get_proxy_sync (
                    GLib.BusType.SESSION,
                    "org.freedesktop.portal.Desktop",
                    "/org/freedesktop/portal/desktop"
                );
            } catch (GLib.IOError error) {
                GLib.warning ("Error connecting to xdg desktop portal: %s", error.message);
            }
        }

        this.settings = new GLib.Settings ("org.gnome.BreakTimer");
        this.settings.bind ("enabled", this, "master-enabled", SettingsBindFlags.DEFAULT);
        this.settings.bind ("selected-breaks", this, "selected-break-ids", SettingsBindFlags.DEFAULT);

        // We choose not to send a signal when master_enabled changes because
        // we might be starting the break daemon at the same time, so the
        // value of is_working () could fluctuate unpleasantly.
        //this.notify["master-enabled"].connect ( () => { this.status_changed (); });
        this.notify["master-enabled"].connect ( this.on_master_enabled_changed );
    }

    public signal void break_status_available ();
    public signal void break_added (BreakType break_type);
    public signal void status_changed ();

    private void on_master_enabled_changed () {
        // Launch the break timer service if the break manager is enabled
        if (this.master_enabled) {
            this.launch_break_timer_service ();
        }

        if (this.background_portal != null) {
            var options = new HashTable<string, GLib.Variant> (str_hash, str_equal);
            var commandline = new GLib.Variant.strv ({"gnome-break-timer-daemon"});
            options.insert ("autostart", this.master_enabled);
            options.insert ("commandline", commandline);
            // RequestBackground creates a desktop file with the same name as
            // the flatpak, which happens to be the dbus name of the daemon
            // (although it is not the dbus name of the settings application).
            options.insert ("dbus-activatable", true);

            try {
                // We don't have a nice way to generate a window handle, but the
                // background portal can probably do without.
                // TODO: Handle response, and display an error if the result
                //       includes `autostart == false || background == false`.
                this.background_portal.request_background("", options);
            } catch (GLib.IOError error) {
                GLib.warning ("Error connecting to xdg desktop portal: %s", error.message);
            } catch (GLib.DBusError error) {
                GLib.warning ("Error enabling autostart: %s", error.message);
            }
        }
    }

    private bool get_is_in_flatpak () {
        string flatpak_info_path = GLib.Path.build_filename (
            GLib.Environment.get_user_runtime_dir (),
            "flatpak-info"
        );
        return GLib.FileUtils.test (flatpak_info_path, GLib.FileTest.EXISTS);
    }

    public void load_breaks () {
        this.add_break (new MicroBreakType ());
        this.add_break (new RestBreakType ());

        this.status_changed ();

        GLib.Bus.watch_name (
            GLib.BusType.SESSION,
            Config.DAEMON_APPLICATION_ID,
            GLib.BusNameWatcherFlags.NONE,
            this.break_daemon_appeared,
            this.break_daemon_disappeared
        );
    }

    public Gee.Set<string> all_break_ids () {
        return this.breaks.keys;
    }

    public unowned GLib.List<BreakType> all_breaks () {
        return this.breaks_ordered;
    }

    /**
     * @returns true if the break daemon is working correctly.
     */
    public bool is_working () {
        return (this.master_enabled == false || this.breaks.size == 0 || this.break_daemon != null);
    }

    public BreakType? get_break_type_for_name (string name) {
        return this.breaks.get (name);
    }

    private void add_break (BreakType break_type) {
        break_type.initialize ();
        this.breaks.set (break_type.id, break_type);
        this.breaks_ordered.append (break_type);
        break_type.status_changed.connect (this.break_status_changed);
        this.break_added (break_type);
    }

    private void break_status_changed (BreakType break_type, BreakStatus? break_status) {
        BreakType? new_foreground_break = this.foreground_break;

        if (break_status != null && break_status.is_focused && break_status.is_active) {
            new_foreground_break = break_type;
        } else if (this.foreground_break == break_type) {
            new_foreground_break = null;
        }

        if (this.foreground_break != new_foreground_break) {
            this.foreground_break = new_foreground_break;
        }

        this.status_changed ();
    }

    private void break_daemon_appeared () {
        try {
            this.break_daemon = GLib.Bus.get_proxy_sync (
                GLib.BusType.SESSION,
                Config.DAEMON_APPLICATION_ID,
                Config.DAEMON_OBJECT_PATH,
                GLib.DBusProxyFlags.DO_NOT_AUTO_START
            );
            this.break_status_available ();
        } catch (GLib.IOError error) {
            this.break_daemon = null;
            GLib.warning ("Error connecting to break daemon service: %s", error.message);
        }
    }

    private void break_daemon_disappeared () {
        if (this.break_daemon == null && this.master_enabled) {
            // Try to start break_daemon automatically if it should be
            // running. Only do this once, if it was not running previously.
            this.launch_break_timer_service ();
        }

        this.break_daemon = null;

        this.status_changed ();
    }

    private void launch_break_timer_service () {
        GLib.AppInfo daemon_app_info = new GLib.DesktopAppInfo (Config.DAEMON_DESKTOP_FILE_ID);
        GLib.AppLaunchContext app_launch_context = new GLib.AppLaunchContext ();
        try {
            daemon_app_info.launch (null, app_launch_context);
        } catch (GLib.Error error) {
            GLib.warning ("Error launching daemon application: %s", error.message);
        }
    }
}

}
