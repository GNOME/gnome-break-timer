/* BreakType.vala
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

namespace BreakTimer.Settings.Break {

public abstract class BreakType : GLib.Object, GLib.Initable {
    public string id { get; private set; }
    public BreakStatus? status {get; private set; }

    public BreakInfoWidget info_widget {get; private set; }
    public BreakStatusWidget status_widget {get; private set; }
    public BreakSettingsWidget settings_widget {get; private set; }

    public GLib.Settings settings;

    public signal void status_changed (BreakStatus? status);

    protected BreakType (string id, GLib.Settings settings) {
        this.id = id;
        this.settings = settings;
    }

    public virtual bool init (GLib.Cancellable? cancellable) throws GLib.Error {
        this.info_widget = this.create_info_widget ();
        this.status_widget = this.create_status_widget ();
        this.settings_widget = this.create_settings_widget ();
        return true;
    }

    protected void update_status (BreakStatus? status) {
        this.status = status;
        this.status_changed (status);
    }

    protected abstract BreakInfoWidget create_info_widget ();
    protected abstract BreakStatusWidget create_status_widget ();
    protected abstract BreakSettingsWidget create_settings_widget ();
}

}
