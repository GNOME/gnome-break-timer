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

namespace BreakTimer.Daemon.Break {

public abstract class BreakType : GLib.Object, GLib.Initable {
    public string id {get; private set; }
    public BreakController break_controller { get; private set; }
    public BreakView break_view { get; private set; }

    protected BreakType (string id, BreakController break_controller, BreakView break_view) {
        this.id = id;
        this.break_controller = break_controller;
        this.break_view = break_view;
    }

    public virtual bool init (GLib.Cancellable? cancellable) throws GLib.Error {
        return true;
    }
}

}
