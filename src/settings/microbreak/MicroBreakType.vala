/* MicroBreakType.vala
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

using BreakTimer.Settings.Break;
using BreakTimer.Settings.TimerBreak;

namespace BreakTimer.Settings.MicroBreak {

public class MicroBreakType : TimerBreakType {
    public MicroBreakType () {
        GLib.Settings settings = new GLib.Settings (Config.APPLICATION_ID + ".microbreak");
        base ("microbreak", settings);

        this.interval_options = {
            new BreakTimeOption(30),
            new BreakTimeOption(240),
            new BreakTimeOption(300),
            new BreakTimeOption(360),
            new BreakTimeOption(600),
            new BreakTimeOption(1200)
        };
        this.duration_options = {
            new BreakTimeOption(5),
            new BreakTimeOption(15),
            new BreakTimeOption(20),
            new BreakTimeOption(30),
            new BreakTimeOption(45),
            new BreakTimeOption(60)
        };
    }

    protected override BreakInfoWidget create_info_widget () {
        return new MicroBreakInfoWidget (this);
    }

    protected override BreakStatusWidget create_status_widget () {
        return new MicroBreakStatusWidget (this);
    }

    protected override BreakSettingsWidget create_settings_widget () {
        return new MicroBreakSettingsWidget (this);
    }
}

}
