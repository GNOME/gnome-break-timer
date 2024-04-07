/* SessionStatus.vala
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

namespace BreakTimer.Daemon {

/**
 * Abstraction of GNOME Screensaver's dbus interface with gentle defaults in
 * case we are unable to connect.
 */
public class SessionStatus : GLib.Object, ISessionStatus, GLib.Initable {
    private GLib.DBusConnection dbus_connection;
    private IGnomeScreenSaver? screensaver;
    private bool screensaver_is_active = false;

    public bool init (GLib.Cancellable? cancellable) throws GLib.Error {
        this.dbus_connection = GLib.Bus.get_sync (GLib.BusType.SESSION, cancellable);

        GLib.Bus.watch_name_on_connection (
            this.dbus_connection,
            "org.gnome.ScreenSaver",
            GLib.BusNameWatcherFlags.NONE,
            this.screensaver_appeared,
            this.screensaver_disappeared
        );

        return true;
    }

    private void screensaver_appeared () {
        try {
            this.screensaver = this.dbus_connection.get_proxy_sync (
                "org.gnome.ScreenSaver",
                "/org/gnome/ScreenSaver"
            );
            this.screensaver.active_changed.connect (this.screensaver_active_changed_cb);
            this.screensaver_is_active = this.screensaver.get_active ();
        } catch (GLib.IOError error) {
            this.screensaver = null;
            GLib.warning ("Error connecting to screensaver service: %s", error.message);
        } catch (GLib.DBusError error) {
            GLib.warning ("Error getting screensaver active status: %s", error.message);
        }
    }

    private void screensaver_disappeared () {
        this.screensaver.active_changed.disconnect (this.screensaver_active_changed_cb);
        this.screensaver = null;
    }

    private void screensaver_active_changed_cb (bool active) {
        this.screensaver_is_active = active;
        if (active) {
            this.locked ();
        } else {
            this.unlocked ();
        }
    }

    public bool is_locked () {
        if (this.screensaver != null) {
            return this.screensaver_is_active;
        } else {
            return false;
        }
    }

    public void lock_screen () {
        if (this.screensaver != null) {
            try {
                this.screensaver.lock ();
            } catch (GLib.IOError error) {
                GLib.warning ("Error connecting to screensaver service: %s", error.message);
            } catch (GLib.DBusError error) {
                GLib.warning ("Error locking screen: %s", error.message);
            }
        }
    }

    public void blank_screen () {
        if (this.screensaver != null) {
            try {
                this.screensaver.set_active (true);
            } catch (GLib.IOError error) {
                GLib.warning ("Error connecting to screensaver service: %s", error.message);
            } catch (GLib.DBusError error) {
                GLib.warning ("Error blanking screeen: %s", error.message);
            }
        }
    }

    public void unblank_screen () {
        if (this.screensaver != null) {
            try {
                this.screensaver.set_active (false);
            } catch (GLib.IOError error) {
                GLib.warning ("Error connecting to screensaver service: %s", error.message);
            } catch (GLib.DBusError error) {
                GLib.warning ("Error unblanking screeen: %s", error.message);
            }
        }
    }
}

}
