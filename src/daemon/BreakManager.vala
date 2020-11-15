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

namespace BreakTimer.Daemon {

public class BreakManager : GLib.Object {
    private UIManager ui_manager;

    private Gee.Map<string, BreakType> breaks;
    private BreakManagerDBusObject dbus_object;

    private GLib.Settings settings;
    public bool master_enabled { get; set; }
    public string[] selected_break_ids { get; set; }

    public BreakManager (UIManager ui_manager) {
        this.ui_manager = ui_manager;

        this.breaks = new Gee.HashMap<string, BreakType> ();
        this.settings = new GLib.Settings ("org.gnome.BreakTimer");

        this.settings.bind ("enabled", this, "master-enabled", GLib.SettingsBindFlags.DEFAULT);
        this.settings.bind ("selected-breaks", this, "selected-break-ids", GLib.SettingsBindFlags.DEFAULT);
        this.notify["master-enabled"].connect (this.update_enabled_breaks);
        this.notify["selected-break-ids"].connect (this.update_enabled_breaks);

        this.dbus_object = new BreakManagerDBusObject (this);
        try {
            GLib.DBusConnection connection = GLib.Bus.get_sync (
                GLib.BusType.SESSION,
                null
            );
            connection.register_object (
                Config.DAEMON_OBJECT_PATH,
                this.dbus_object
            );
        } catch (GLib.IOError error) {
            GLib.error ("Error registering daemon on the session bus: %s", error.message);
        }
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

    public void load_breaks (ActivityMonitor activity_monitor) {
        this.add_break (new MicroBreakType (activity_monitor));
        this.add_break (new RestBreakType (activity_monitor));

        this.update_enabled_breaks ();
    }

    public Gee.Set<string> all_break_ids () {
        return this.breaks.keys;
    }

    public Gee.Collection<BreakType> all_breaks () {
        return this.breaks.values;
    }

    public BreakType? get_break_type_for_name (string name) {
        return this.breaks.get (name);
    }

    private void add_break (BreakType break_type) {
        this.breaks.set (break_type.id, break_type);
        break_type.initialize (this.ui_manager);
    }

    private void update_enabled_breaks () {
        foreach (BreakType break_type in this.all_breaks ()) {
            bool is_enabled = this.master_enabled && break_type.id in this.selected_break_ids;
            break_type.break_controller.set_enabled (is_enabled);
        }
    }
}

}
