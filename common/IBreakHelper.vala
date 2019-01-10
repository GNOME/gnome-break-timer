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

namespace BreakTimer {

[DBus (name = "org.gnome.BreakTimer")]
public interface IBreakHelper : Object {
    /** Returns the ID of the break that is currently focused and activated, if any. */
    public abstract string? get_current_active_break () throws DBusError, IOError;

    /** Returns a list of breaks that are currently known to the break helper. */
    public abstract string[] get_break_ids () throws DBusError, IOError;

    /** Returns a list of helpful status messages for each break, for debugging. */
    public abstract string[] get_status_messages () throws DBusError, IOError;

    /** Activate the specified break immediately, regardless of the usual activation conditions. */
    public abstract void activate_break (string break_id) throws DBusError, IOError;

    // TODO: It might make sense to communicate when the active break changes,
    // using a signal. The only reason we don't at the moment is it adds
    // complexity in the break helper, and the settings app already polls the
    // dbus service regularly for updates.
}

[DBus (name = "org.gnome.BreakTimer.TimerBreak")]
public interface IBreakHelper_TimerBreak : Object {
    /** Get the break's current status, such as time remaining, or time until the break starts */
    public abstract TimerBreakStatus get_status () throws DBusError, IOError;

    /** Activate the break */
    public abstract void activate () throws DBusError, IOError;
}

public struct BreakStatus {
    bool is_enabled;
    bool is_focused;
    bool is_active;
}

public struct TimerBreakStatus {
    bool is_enabled;
    bool is_focused;
    bool is_active;
    int starts_in;
    int time_remaining;
    int current_duration;
}

}
