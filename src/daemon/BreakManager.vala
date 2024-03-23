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

using BreakTimer.Common;
using BreakTimer.Daemon.Activity;
using BreakTimer.Daemon.Break;
using BreakTimer.Daemon.MicroBreak;
using BreakTimer.Daemon.RestBreak;
using BreakTimer.Daemon.Util;

namespace BreakTimer.Daemon {

public class BreakManager : GLib.Object, GLib.Initable {
    public int autostart_version { get; set; }
    public bool master_enabled { get; set; }
    public string[] selected_break_ids { get; set; }

    private GLib.DBusConnection dbus_connection;
    private GLib.Settings settings;
    private GLib.HashTable<string, BreakType> breaks;

    private IPortalBackground? background_portal = null;
    private uint background_status_update_timeout_id;
    private string background_status_message = "";

    private const uint BACKGROUND_STATUS_UPDATE_INTERVAL_SECONDS = 5;

    public BreakManager (UIManager ui_manager, ActivityMonitor activity_monitor) {
        this.settings = new GLib.Settings (Config.APPLICATION_ID);

        this.breaks = new GLib.HashTable<string, BreakType> (str_hash, str_equal);
        this.breaks.set ("microbreak", new MicroBreakType (activity_monitor, ui_manager));
        this.breaks.set ("restbreak", new RestBreakType (activity_monitor, ui_manager));

        this.settings.bind ("autostart-version", this, "autostart-version", SettingsBindFlags.DEFAULT);
        this.settings.bind ("enabled", this, "master-enabled", GLib.SettingsBindFlags.DEFAULT);
        this.settings.bind ("selected-breaks", this, "selected-break-ids", GLib.SettingsBindFlags.DEFAULT);

        this.notify["master-enabled"].connect (this.update_enabled_breaks);
        this.notify["selected-break-ids"].connect (this.update_enabled_breaks);
        this.update_enabled_breaks ();
    }

    ~BreakManager () {
        this.stop_background_status_update_timeout ();
    }

    public bool init (GLib.Cancellable? cancellable) throws GLib.Error {
        this.dbus_connection = GLib.Bus.get_sync (GLib.BusType.SESSION, cancellable);

        if (this.get_is_in_flatpak ()) {
            this.background_portal = this.dbus_connection.get_proxy_sync (
                "org.freedesktop.portal.Desktop",
                "/org/freedesktop/portal/desktop",
                GLib.DBusProxyFlags.NONE,
                cancellable
            );
            this.start_background_status_update_timeout ();
        }

        this.dbus_connection.register_object (
            Config.DAEMON_OBJECT_PATH,
            new BreakManagerDBusObject (this)
        );

        foreach (BreakType break_type in this.all_breaks ()) {
            break_type.init (cancellable);
        }

        return true;
    }

    public Json.Object serialize () {
        Json.Object json_root = new Json.Object ();
        foreach (BreakType break_type in this.all_breaks ()) {
            Json.Object break_json = break_type.break_controller.serialize ();
            json_root.set_object_member (break_type.id, break_json);
        }
        return json_root;
    }

    public void deserialize (ref Json.Object json_root) {
        foreach (BreakType break_type in this.all_breaks ()) {
            Json.Object break_json = json_root.get_object_member (break_type.id);
            if (break_json != null) {
                break_type.break_controller.deserialize (ref break_json);
            }
        }
    }

    public GLib.List<unowned string> all_break_ids () {
        return this.breaks.get_keys ();
    }

    public GLib.List<unowned BreakType> all_breaks () {
        return this.breaks.get_values ();
    }

    public BreakType? get_break_type_for_name (string name) {
        return this.breaks.lookup (name);
    }

    private bool get_is_in_flatpak () {
        string flatpak_info_path = GLib.Path.build_filename (
            GLib.Environment.get_user_runtime_dir (),
            "flatpak-info"
        );
        return GLib.FileUtils.test (flatpak_info_path, GLib.FileTest.EXISTS);
    }

    private void update_enabled_breaks () {
        foreach (BreakType break_type in this.all_breaks ()) {
            bool is_enabled = this.master_enabled && break_type.id in this.selected_break_ids;
            break_type.break_controller.set_enabled (is_enabled);
        }
    }

    private void start_background_status_update_timeout () {
        assert (this.background_status_update_timeout_id == 0);

        this.background_status_update_timeout_id = GLib.Timeout.add_seconds (
            BACKGROUND_STATUS_UPDATE_INTERVAL_SECONDS, this.background_status_update_cb
        );
    }

    private void stop_background_status_update_timeout () {
        if (this.background_status_update_timeout_id != 0) {
            GLib.Source.remove (this.background_status_update_timeout_id);
            this.background_status_update_timeout_id = 0;
        }
    }

    private BreakView? get_next_break_view () {
        // TODO: Ideally this should cleverly get the next break on the
        //       schedule. At the moment, that is trickier than it sounds. So
        //       for now, we will only show the next rest break, or the next
        //       micro break if rest breaks are disabled.
        BreakView? next_break_view = null;

        foreach (BreakType break_type in this.all_breaks ()) {
            if (!break_type.break_controller.is_enabled ()) {
                continue;
            }

            if (next_break_view == null) {
                next_break_view = break_type.break_view;
            } else if (break_type.break_view.has_higher_focus_priority(next_break_view)) {
                next_break_view = break_type.break_view;
            }
        }

        return next_break_view;
    }

    private string? get_next_break_message () {
        BreakView? next_break_view = this.get_next_break_view ();

        if (next_break_view == null) {
            return null;
        }

        return next_break_view.get_status_message ();
    }

    private bool background_status_update_cb () {
        var message = this.get_next_break_message () ?? "";

        if (!this.set_background_status_message (message)) {
            this.background_status_update_timeout_id = 0;
            return GLib.Source.REMOVE;
        }

        return GLib.Source.CONTINUE;
    }

    private bool set_background_status_message (string message) {
        if (this.background_portal == null) {
            return false;
        }

        if (this.background_status_message == message) {
            return true;
        }

        var options = new HashTable<string, GLib.Variant> (str_hash, str_equal);
        options.insert ("message", message);

        try {
            this.background_portal.set_status (options);
        } catch (GLib.IOError error) {
            GLib.warning ("Error connecting to desktop portal: %s", error.message);
            return false;
        } catch (GLib.DBusError error) {
            GLib.warning ("Error setting status message: %s", error.message);
            return false;
        }

        this.background_status_message = message;

        return true;
    }
}

}
