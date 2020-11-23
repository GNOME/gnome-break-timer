/* UIManager.vala
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
using BreakTimer.Daemon.Util;

namespace BreakTimer.Daemon {

/**
 * Central place to manage UI throughout the application. We need this to
 * maintain a simple, modal structure. This uses SimpleFocusManager to make
 * sure only one break is affecting the UI at a time. This class also tries to
 * keep UI events nicely spaced so they don't generate excessive noise.
 */
public class UIManager : SimpleFocusManager, GLib.Initable {
    private weak Gtk.Application application;
    private ISessionStatus session_status;

    private GSound.Context? gsound;

    private Notify.Notification? notification;
    private Notify.Notification? lock_notification;

    private GLib.List<string> notify_capabilities;

    public enum HideNotificationMethod {
        IMMEDIATE,
        DELAYED
    }

    public UIManager (Gtk.Application application, ISessionStatus session_status) {
        this.application = application;
        this.session_status = session_status;

        this.session_status.unlocked.connect (this.hide_lock_notification_cb);
        this.notify_capabilities = Notify.get_server_caps ();
    }

    public bool init (GLib.Cancellable? cancellable) throws GLib.Error {
        try {
            this.gsound = new GSound.Context ();
            this.gsound.init (cancellable);
        } catch (GLib.Error error) {
            GLib.warning ("Error initializing gsound: %s", error.message);
            this.gsound = null;
        }
        return true;
    }

    public bool notifications_can_do (string capability) {
        // For whatever reason notify_capabilities.index () isn't matching
        // our capability strings, so we'll search the list ourselves
        foreach (string server_capability in this.notify_capabilities) {
            if (server_capability == capability) return true;
        }
        return false;
    }

    public void show_notification (Notify.Notification notification) {
        /**
         * Show a notification, ensuring that the application is only showing
         * one notification at any time.
         */

        if (notification != this.notification) {
            this.hide_notification (this.notification, IMMEDIATE);
        }

        notification.set_hint ("desktop-entry", Config.DAEMON_APPLICATION_ID);

        try {
            notification.show ();
        } catch (GLib.Error error) {
            GLib.warning ("Error showing notification: %s", error.message);
        }

        this.notification = notification;
    }

    public void hide_notification (Notify.Notification? notification, HideNotificationMethod method=IMMEDIATE) {
        /**
         * Close a notification proactively, if it is still open.
         */

        if (notification != null && this.notification == notification) {
            try {
                if (method == IMMEDIATE) {
                    this.notification.close ();
                } else {
                    this.notification.set_hint ("transient", true);
                    this.notification.show ();
                }
            } catch (GLib.Error error) {
                GLib.debug ("Error closing notification: %s", error.message);
            }
        }
        this.notification = null;
    }

    public void show_lock_notification (Notify.Notification notification) {
        /**
         * Show a notification that will only appear in the lock screen. The
         * notification automatically hides when the screen is unlocked.
         */

        if (this.session_status.is_locked ()) {
            this.lock_notification = notification;
        } else {
            notification.set_hint ("transient", true);
        }

        this.show_notification (notification);
    }

    public void play_sound_from_id (string event_id) {
        if (this.gsound != null) {
            try {
                this.gsound.play_simple (null, "event.id", event_id);
            } catch (GLib.Error error) {
                GLib.warning ("Error playing sound: %s", error.message);
            }
        }
    }

    public bool can_lock_screen () {
        return ! this.application.is_inhibited (Gtk.ApplicationInhibitFlags.IDLE);
    }

    public void lock_screen () {
        if (! this.session_status.is_locked ()) {
            this.session_status.lock_screen ();
        }
    }

    public void add_break (BreakView break_view) {
        this.application.hold ();
    }

    public void remove_break (BreakView break_view) {
        this.release_focus (break_view);
        this.application.release ();
    }

    private void hide_lock_notification_cb () {
        this.hide_notification (this.lock_notification, IMMEDIATE);
        this.lock_notification = null;
    }
}

}
