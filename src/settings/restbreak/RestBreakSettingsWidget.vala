/* RestBreakSettingsWidget.vala
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

using BreakTimer.Settings.TimerBreak;

namespace BreakTimer.Settings.RestBreak {

class RestBreakSettingsWidget : TimerBreakSettingsWidget {
    public RestBreakSettingsWidget (RestBreakType break_type) {
        base (
            break_type,
            _("Full break"),
            _("And take some longer breaks to stretch your legs")
        );

        var lock_screen_row = new Adw.SwitchRow ();
        lock_screen_row.set_title (_("Lock the screen during breaks"));
        break_type.settings.bind ("lock-screen", lock_screen_row, "active", SettingsBindFlags.DEFAULT);
        this.add (lock_screen_row);
    }

}

}
