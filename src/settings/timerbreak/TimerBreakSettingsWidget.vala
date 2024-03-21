/* TimerBreakSettingsWidget.vala
 *
 * Copyright 2020-2021 Dylan McCall <dylan@dylanmccall.ca>
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
using BreakTimer.Settings.Widgets;

namespace BreakTimer.Settings.TimerBreak {

public abstract class TimerBreakSettingsWidget : BreakSettingsWidget {
    protected TimerBreakSettingsWidget (TimerBreakType break_type, string title, string? description) {
        base (title, description);

        var interval_row = new TimeChooserRow (break_type.interval_options);
        interval_row.set_title (_("Every"));
        break_type.settings.bind ("interval-seconds", interval_row, "time-seconds", SettingsBindFlags.DEFAULT);
        this.add (interval_row);

        var duration_row = new TimeChooserRow (break_type.duration_options);
        duration_row.set_title (_("For"));
        break_type.settings.bind ("duration-seconds", duration_row, "time-seconds", SettingsBindFlags.DEFAULT);
        this.add (duration_row);
    }
}

}
