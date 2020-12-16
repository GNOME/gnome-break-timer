/* RestBreakType.vala
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

using BreakTimer.Daemon.Activity;
using BreakTimer.Daemon.Break;
using BreakTimer.Daemon.TimerBreak;

namespace BreakTimer.Daemon.RestBreak {

public class RestBreakType : TimerBreakType {
    public RestBreakType (ActivityMonitor activity_monitor, UIManager ui_manager) {
        var break_controller = new RestBreakController (activity_monitor);
        var break_view = new RestBreakView (break_controller, ui_manager);

        var settings = new GLib.Settings (Config.APPLICATION_ID + ".restbreak");
        settings.bind ("interval-seconds", break_controller, "interval", GLib.SettingsBindFlags.GET);
        settings.bind ("duration-seconds", break_controller, "duration", GLib.SettingsBindFlags.GET);
        settings.bind ("lock-screen", break_controller, "lock-screen-enabled", GLib.SettingsBindFlags.GET);

        base ("restbreak", break_controller, break_view);
    }
}

}
