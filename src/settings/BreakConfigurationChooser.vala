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

namespace BreakTimer.Settings {

class BreakConfigurationChooser : Gtk.ComboBox {
    public class Configuration : GLib.Object {
        public Gtk.TreeIter iter;
        public string[] break_ids;
        public string label;

        public Configuration (string[] break_ids, string label) {
            this.break_ids = break_ids;
            this.label = label;
        }

        public bool matches_breaks (string[] test_break_ids) {
            if (test_break_ids.length == this.break_ids.length) {
                foreach (string test_break_id in test_break_ids) {
                    if (! (test_break_id in this.break_ids)) return false;
                }
                return true;
            } else {
                return false;
            }
        }
    }

    private Gtk.ListStore list_store;
    private List<Configuration> configurations;

    public string[] selected_break_ids { public get; public set; }

    public BreakConfigurationChooser () {
        GLib.Object ();

        this.configurations = new List<Configuration> ();

        this.list_store = new Gtk.ListStore (2, typeof (Configuration), typeof (string));
        this.set_model (this.list_store);

        var label_renderer = new Gtk.CellRendererText ();
        this.pack_start (label_renderer, true);
        this.add_attribute (label_renderer, "text", 1);

        this.notify["active"].connect (this.send_selected_break);
        this.notify["selected-break-ids"].connect (this.receive_selected_break);
    }

    public void add_configuration (string[] break_ids, string label) {
        var configuration = new Configuration (break_ids, label);
        this.configurations.append (configuration);
        Gtk.TreeIter iter;
        this.list_store.append (out iter);
        this.list_store.set (iter, 0, configuration, 1, configuration.label);
        configuration.iter = iter;
    }

    private void send_selected_break () {
        Gtk.TreeIter iter;
        if (this.get_active_iter (out iter)) {
            Value value;
            this.list_store.get_value (iter, 0, out value);
            Configuration configuration = (Configuration)value;
            this.selected_break_ids = configuration.break_ids;
        }
    }

    private void receive_selected_break () {
        var configuration = this.get_configuration_for_break_ids (this.selected_break_ids);
        if (configuration != null) {
            this.set_active_iter (configuration.iter);
        } else {
            this.set_active (-1);
        }
    }

    private Configuration? get_configuration_for_break_ids (string[] selected_breaks) {
        foreach (Configuration configuration in this.configurations) {
            if (configuration.matches_breaks (selected_breaks)) {
                return configuration;
            }
        }
        return null;
    }
}

}
