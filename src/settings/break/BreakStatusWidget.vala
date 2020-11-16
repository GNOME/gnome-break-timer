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

namespace BreakTimer.Settings.Break {

public abstract class BreakStatusWidget : Gtk.Grid {
    public BreakType break_type { public get; private set; }
    public bool is_enabled { get; set; default=false; }

    protected BreakStatusWidget (BreakType break_type) {
        GLib.Object ();

        this.break_type = break_type;

        this.get_style_context ().add_class ("_break-status");
    }
}

}