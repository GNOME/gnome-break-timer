/* MicroBreakStatusWidget.vala
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

namespace BreakTimer.Settings.MicroBreak {

class MicroBreakStatusWidget : TimerBreakStatusWidget {
    public MicroBreakStatusWidget (MicroBreakType break_type) {
        base (
            break_type,
            /* Label that explains a countdown timer, which shows a string such as "5 minutes" */
            _("Your next microbreak is in"),
            _("It's time for a microbreak")
        );
    }
}

}
