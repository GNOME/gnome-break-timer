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

using BreakTimer.Daemon.Activity;
using BreakTimer.Daemon.Break;
using BreakTimer.Daemon.MicroBreak;
using BreakTimer.Daemon.RestBreak;

namespace BreakTimer.Daemon {

public class BreakManager : GLib.Object, GLib.Initable {
    private GLib.Settings settings;
    private GLib.HashTable<string, BreakType> breaks;
    public bool master_enabled { get; set; }
    public string[] selected_break_ids { get; set; }

    public BreakManager (UIManager ui_manager, ActivityMonitor activity_monitor) {
        this.settings = new GLib.Settings ("org.gnome.BreakTimer");

        this.breaks = new GLib.HashTable<string, BreakType> (str_hash, str_equal);
        this.breaks.set("microbreak", new MicroBreakType (activity_monitor, ui_manager));
        this.breaks.set("restbreak", new RestBreakType (activity_monitor, ui_manager));

        this.settings.bind ("enabled", this, "master-enabled", GLib.SettingsBindFlags.DEFAULT);
        this.settings.bind ("selected-breaks", this, "selected-break-ids", GLib.SettingsBindFlags.DEFAULT);

        this.notify["master-enabled"].connect (this.update_enabled_breaks);
        this.notify["selected-break-ids"].connect (this.update_enabled_breaks);
        this.update_enabled_breaks ();
    }

    public bool init (GLib.Cancellable? cancellable) throws GLib.Error {
        GLib.DBusConnection connection;

        try {
            connection = GLib.Bus.get_sync (
                GLib.BusType.SESSION,
                null
            );
        } catch (GLib.IOError error) {
            GLib.warning ("Error connecting to the session bus: %s", error.message);
            throw error;
        }

        try {
            connection.register_object (
                Config.DAEMON_OBJECT_PATH,
                new BreakManagerDBusObject (this)
            );
        } catch (GLib.IOError error) {
            GLib.warning ("Error registering daemon on the session bus: %s", error.message);
            throw error;
        }

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

    private void update_enabled_breaks () {
        foreach (BreakType break_type in this.all_breaks ()) {
            bool is_enabled = this.master_enabled && break_type.id in this.selected_break_ids;
            break_type.break_controller.set_enabled (is_enabled);
        }
    }
}

}
