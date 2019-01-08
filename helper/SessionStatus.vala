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

namespace BreakTimer.Helper {

[DBus (name = "org.gnome.ScreenSaver")]
public interface IScreenSaver : Object {
    public signal void active_changed (bool active);

    public abstract bool get_active () throws IOError;
    public abstract uint32 get_active_time () throws IOError;
    public abstract void lock () throws IOError;
    public abstract void set_active (bool active) throws IOError;
}

/**
 * Abstraction of GNOME Screensaver's dbus interface with gentle defaults in
 * case we are unable to connect.
 */
public class SessionStatus : ISessionStatus, Object {
	private Gtk.Application application;
	private IScreenSaver? screensaver;
	private bool screensaver_is_active = false;

	public SessionStatus (Gtk.Application application) {
		this.application = application;

		Bus.watch_name (BusType.SESSION, "org.gnome.ScreenSaver", BusNameWatcherFlags.NONE,
				this.screensaver_appeared, this.screensaver_disappeared);
	}

	private void screensaver_appeared () {
		try {
			this.screensaver = Bus.get_proxy_sync (
				BusType.SESSION,
				"org.gnome.ScreenSaver",
				"/org/gnome/ScreenSaver"
			);
			this.screensaver.active_changed.connect (this.screensaver_active_changed_cb);
			this.screensaver_is_active = this.screensaver.get_active ();
		} catch (IOError error) {
			this.screensaver = null;
			GLib.warning ("Error connecting to screensaver service: %s", error.message);
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
			} catch (IOError error) {
				GLib.warning ("Error locking screen: %s", error.message);
			}
		}
	}

	public void blank_screen () {
		if (this.screensaver != null) {
			try {
				this.screensaver.set_active (true);
			} catch (IOError error) {
				GLib.warning ("Error blanking screeen: %s", error.message);
			}
		}
	}

	public void unblank_screen () {
		if (this.screensaver != null) {
			try {
				this.screensaver.set_active (false);
			} catch (IOError error) {
				GLib.warning ("Error unblanking screeen: %s", error.message);
			}
		}
	}
}

}
