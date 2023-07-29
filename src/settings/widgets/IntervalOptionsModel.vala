/* TimerBreakSettingsWidget.vala
 *
 * Copyright 2023 Dylan McCall <dylan@dylanmccall.ca>
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

public class TimeOptionsModel : GLib.ListModel, GLib.Object {
    private BreakTimeOption[] options;

    public TimeOptionsModel (BreakTimeOption[] options) {
        GLib.Object ();

        this.options = options;
    }

    public GLib.Type get_item_type () {
        return typeof (BreakTimeOption);
    }

    public uint get_n_items () {
        return this.options.length;
    }

    public GLib.Object? get_item (uint position) {
        return this.options[position];
    }
}

}
