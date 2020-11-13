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

public class RestBreakType : TimerBreakType {
    public RestBreakType () {
        GLib.Settings settings = new GLib.Settings ("org.gnome.BreakTimer.restbreak");
        base ("restbreak", settings);

        this.interval_options = { 1800, 2400, 3000, 3600 };
        this.duration_options = { 240, 300, 360, 480, 600 };
    }

    protected override BreakInfoPanel get_info_panel () {
        return new RestBreakInfoPanel (this);
    }

    protected override BreakStatusPanel get_status_panel () {
        return new RestBreakStatusPanel (this);
    }

    protected override BreakSettingsPanel get_settings_panel () {
        return new RestBreakSettingsPanel (this);
    }
}

}
