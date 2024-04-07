/* TimerBreakType.vala
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
using BreakTimer.Daemon.Break;

namespace BreakTimer.Daemon.TimerBreak {

public class BreakTimeOption : GLib.Object {
    public int time_seconds {get; protected set; }
    public bool is_custom { get; protected set; default = false; }
    public string label { get; protected set; }

    public BreakTimeOption (int time_seconds) {
        this.time_seconds = time_seconds;
        this.label = NaturalTime.instance.get_label_for_seconds (this.time_seconds);
    }

    public bool equals (BreakTimeOption other) {
        return this.time_seconds == other.time_seconds;
    }
}

public abstract class TimerBreakType : BreakType {
    private GLib.DBusConnection dbus_connection;

    public BreakTimeOption[] interval_options;
    public BreakTimeOption[] duration_options;

    public int interval { get; protected set; }
    public int duration { get; protected set; }

    public signal void timer_status_changed (TimerBreakStatus? status);

    protected TimerBreakType (string id, GLib.Settings settings, BreakController break_controller, BreakView break_view) {
        base (id, settings, break_controller, break_view);
    }

    public override bool init (GLib.Cancellable? cancellable) throws GLib.Error {
        this.dbus_connection = GLib.Bus.get_sync (GLib.BusType.SESSION, cancellable);

        this.dbus_connection.register_object (
            Config.DAEMON_OBJECT_PATH + "/" + this.id,
            new TimerBreakDBusObject (
                (TimerBreakController) this.break_controller,
                (TimerBreakView) this.break_view
            )
        );

        return base.init (cancellable);
    }
}

}
