/*
 * This file is part of Brain Break.
 * 
 * Brain Break is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * Brain Break is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with Brain Break.  If not, see <http://www.gnu.org/licenses/>.
 */

[DBus (name = "org.gnome.ScreenSaver")]
interface IScreenSaver : Object {
    public signal void active_changed (bool active);

    public abstract void lock() throws IOError;
    public abstract bool get_active() throws IOError;
    public abstract void set_active(bool active) throws IOError;
    public abstract int get_active_time() throws IOError;
}

/**
 * Abstraction of GNOME Screensaver's dbus interface with gentle defaults in
 * case we are unable to connect.
 */
public class SessionStatus : Object {
	private IScreenSaver? screensaver;
	private bool screensaver_is_active = false;

	public signal void locked();
	public signal void unlocked();

	private SessionStatus() {
		Bus.watch_name(BusType.SESSION, "org.gnome.Shell", BusNameWatcherFlags.NONE,
				this.shell_appeared, this.shell_disappeared);
	}

	private static SessionStatus _instance;
	public static SessionStatus instance {
		get {
			if (_instance == null) {
				_instance = new SessionStatus();
			}
			return _instance;
		}
	}

	private void shell_appeared() {
		try {
			this.screensaver = Bus.get_proxy_sync(BusType.SESSION, "org.gnome.Shell", "/org/gnome/ScreenSaver");
			this.screensaver.active_changed.connect(this.screensaver_active_changed_cb);
			this.screensaver_is_active = this.screensaver.get_active();

		} catch (IOError error) {
			this.screensaver = null;
			GLib.warning("Error connecting to gnome-screensaver: %s", error.message);
		}
	}
	
	private void shell_disappeared() {
		this.screensaver.active_changed.disconnect(this.screensaver_active_changed_cb);
		this.screensaver = null;
	}

	private void screensaver_active_changed_cb(bool active) {
		this.screensaver_is_active = active;
		if (active) {
			this.locked();
		} else {
			this.unlocked();
		}
	}

	public bool is_locked() {
		if (this.screensaver != null) {
			return this.screensaver_is_active;
		} else {
			return false;
		}
	}

	public void lock_screen() {
		if (this.screensaver != null) {
			try {
				this.screensaver.lock();
			} catch (IOError error) {
				GLib.warning("Error locking screen: %s", error.message);
			}
		}
	}
}
