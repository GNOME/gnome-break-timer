/* BreakManager.vala
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

// TODO: This intentionally resembles BreakManager from the daemon application.
// Ideally, it should be common code in the future.

using BreakTimer.Common;
using BreakTimer.Settings.Break;
using BreakTimer.Settings.MicroBreak;
using BreakTimer.Settings.RestBreak;

namespace BreakTimer.Settings {

public class BreakManager : GLib.Object {
    private IBreakTimer break_daemon;

    private GLib.List<BreakType> breaks;

    private GLib.Settings settings;
    public int autostart_version { get; set; }
    public bool master_enabled { get; set; }
    public string[] selected_break_ids { get; set; }
    public BreakType? foreground_break { get; private set; }

    public PermissionsError permissions_error { get; private set; }

    private GLib.DBusConnection dbus_connection;

    private IPortalBackground? background_portal = null;
    private IPortalRequest? background_request = null;
    private GLib.ObjectPath? background_request_path = null;

    public signal void break_status_available ();
    public signal void status_changed ();

    public static int CURRENT_AUTOSTART_VERSION = 2;

    [Flags]
    public enum PermissionsError {
        NONE = 0,
        AUTOSTART_NOT_ALLOWED,
        BACKGROUND_NOT_ALLOWED
    }

    public BreakManager () {
        this.settings = new GLib.Settings (Config.APPLICATION_ID);

        this.breaks = new GLib.List<BreakType> ();
        this.breaks.append (new MicroBreakType ());
        this.breaks.append (new RestBreakType ());

        this.permissions_error = PermissionsError.NONE;

        this.settings.bind ("autostart-version", this, "autostart-version", SettingsBindFlags.DEFAULT);
        this.settings.bind ("enabled", this, "master-enabled", SettingsBindFlags.DEFAULT);
        this.settings.bind ("selected-breaks", this, "selected-break-ids", SettingsBindFlags.DEFAULT);

        this.notify["master-enabled"].connect (this.on_master_enabled_changed);
    }

    public bool init (GLib.Cancellable? cancellable) throws GLib.Error {
        this.dbus_connection = GLib.Bus.get_sync (GLib.BusType.SESSION, cancellable);

        if (this.get_is_in_flatpak ()) {
            // TODO: Does this work outside of a flatpak? We could remove the
            // extra file we install in data/autostart, which would be nice.
            this.background_portal = this.dbus_connection.get_proxy_sync (
                "org.freedesktop.portal.Desktop",
                "/org/freedesktop/portal/desktop",
                GLib.DBusProxyFlags.NONE,
                cancellable
            );
        }

        GLib.Bus.watch_name_on_connection (
            this.dbus_connection,
            Config.DAEMON_APPLICATION_ID,
            GLib.BusNameWatcherFlags.NONE,
            this.break_daemon_appeared,
            this.break_daemon_disappeared
        );

        foreach (BreakType break_type in this.all_breaks ()) {
            break_type.status_changed.connect (this.break_status_changed);
            break_type.init (cancellable);
        }

        return true;
    }

    private void on_master_enabled_changed () {
        // Launch the break timer service if the break manager is enabled
        if (this.master_enabled) {
            this.launch_break_timer_service ();
        }

        this.request_background (this.master_enabled);
    }

    public void refresh_permissions () {
        if (this.master_enabled) {
            this.request_background (this.master_enabled);
        }
    }

    private bool request_background (bool autostart) {
        if (this.background_portal == null) {
            this.permissions_error = NONE;
            return false;
        }

        string sender_name = this.dbus_connection.unique_name.replace (".", "_");
        sender_name = sender_name[1:sender_name.length];
        string handle_token = "org_gnome_breaktimer%d".printf (
            GLib.Random.int_range (0, int.MAX)
        );

        var options = new HashTable<string, GLib.Variant> (str_hash, str_equal);
        var commandline = new GLib.Variant.strv ({"gnome-break-timer-daemon"});
        options.insert ("handle_token", handle_token);
        options.insert ("autostart", autostart);
        options.insert ("commandline", commandline);
        // We will not use the dbus-activatable option, because the daemon
        // application opens a settings window when it is activated for a second
        // time.
        options.insert ("dbus-activatable", false);

        GLib.ObjectPath request_path = null;
        GLib.ObjectPath expected_request_path = new GLib.ObjectPath (
            "/org/freedesktop/portal/desktop/request/%s/%s".printf (
                sender_name,
                handle_token
            )
        );

        this.watch_background_request (expected_request_path);

        try {
            // We don't have a nice way to generate a window handle, but the
            // background portal can probably do without.
            // TODO: Handle response, and display an error if the result
            //       includes `autostart == false || background == false`.
            request_path = this.background_portal.request_background ("", options);
        } catch (GLib.IOError error) {
            GLib.warning ("Error connecting to desktop portal: %s", error.message);
            return false;
        } catch (GLib.DBusError error) {
            GLib.warning ("Error enabling autostart: %s", error.message);
            return false;
        }

        this.watch_background_request (request_path);

        return true;
    }

    private bool watch_background_request (GLib.ObjectPath request_path) {
        if (request_path == this.background_request_path) {
            return true;
        }

        try {
            this.background_request = this.dbus_connection.get_proxy_sync (
                "org.freedesktop.portal.Desktop",
                request_path
            );
            this.background_request_path = request_path;
            this.background_request.response.connect (this.on_background_request_response);
        } catch (GLib.IOError error) {
            GLib.warning ("Error connecting to desktop portal: %s", error.message);
            return false;
        }

        return true;
    }

    private void on_background_request_response (uint32 response, GLib.HashTable<string, Variant> results) {
        bool background_allowed = (bool) results.get ("background");
        bool autostart_allowed = (bool) results.get ("autostart");

        PermissionsError new_permissions_error = NONE;

        if (this.master_enabled && ! autostart_allowed) {
            new_permissions_error |= AUTOSTART_NOT_ALLOWED;
        }

        if (this.master_enabled && ! background_allowed) {
            new_permissions_error |= BACKGROUND_NOT_ALLOWED;
        }

        this.permissions_error = new_permissions_error;

        if (autostart_allowed) {
            this.autostart_version = CURRENT_AUTOSTART_VERSION;
        } else {
            this.autostart_version = 0;
        }

        this.background_request = null;
    }

    private bool get_is_in_flatpak () {
        string flatpak_info_path = GLib.Path.build_filename (
            GLib.Environment.get_user_runtime_dir (),
            "flatpak-info"
        );
        return GLib.FileUtils.test (flatpak_info_path, GLib.FileTest.EXISTS);
    }

    public unowned GLib.List<BreakType> all_breaks () {
        return this.breaks;
    }

    /**
     * @returns true if the break daemon is working correctly.
     */
    public bool is_working () {
        return (this.master_enabled == false || this.break_daemon != null);
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
            this.break_daemon = this.dbus_connection.get_proxy_sync (
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
        GLib.AppInfo daemon_app_info = new GLib.DesktopAppInfo (Config.DAEMON_APPLICATION_ID + ".desktop");
        GLib.AppLaunchContext app_launch_context = new GLib.AppLaunchContext ();
        try {
            daemon_app_info.launch (null, app_launch_context);
        } catch (GLib.Error error) {
            GLib.warning ("Error launching daemon application: %s", error.message);
        }
    }
}

}
