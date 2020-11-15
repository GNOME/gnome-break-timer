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

namespace BreakTimer.Settings {

public abstract class BreakType : GLib.Object {
    public string id { get; private set; }
    public BreakStatus? status;

    public BreakInfoPanel info_panel;
    public BreakStatusPanel status_panel;
    public BreakSettingsPanel settings_panel;

    public GLib.Settings settings;

    protected BreakType (string id, GLib.Settings settings) {
        this.id = id;
        this.settings = settings;
    }

    public signal void status_changed (BreakStatus? status);

    public virtual void initialize () {
        this.info_panel = this.get_info_panel ();
        this.status_panel = this.get_status_panel ();
        this.settings_panel = this.get_settings_panel ();
    }

    protected void update_status (BreakStatus? status) {
        this.status = status;
        this.status_changed (status);
    }

    protected abstract BreakInfoPanel get_info_panel ();
    protected abstract BreakStatusPanel get_status_panel ();
    protected abstract BreakSettingsPanel get_settings_panel ();
}

}
