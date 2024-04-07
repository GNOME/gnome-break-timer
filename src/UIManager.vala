/* UIManager.vala
 *
 * Copyright 2020-2021 Dylan McCall <dylan@dylanmccall.ca>
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

    private GLib.HashTable<string, uint> transient_notification_timeout_ids;

    private const uint TRANSIENT_NOTIFICATION_INTERVAL_SECONDS = 30;

    public UIManager (Gtk.Application application, ISessionStatus session_status) {
        this.application = application;
        this.session_status = session_status;

        this.transient_notification_timeout_ids = new GLib.HashTable<string, uint> (str_hash, str_equal);

        this.session_status.unlocked.connect (this.on_session_unlocked_cb);
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

    /**
     * Show a notification, ensuring that the application is only showing one
     * notification at any time.
     */
    public void show_notification (string id, GLib.Notification notification) {
        // this.application.withdraw_notification ("default-lock-only");
        this.application.send_notification (id, notification);
    }

    /**
     * Show a notification which will disappear after a short time. The XDG
     * Notification portal doesn't support transient notifications, so we need
     * to implement this ourselves by withdrawing a notification after a
     * timeout.
     * In the case that the screen is locked, we will instead wait until the
     * screen is unlocked before withdrawing the notification.
     */
    public void show_transient_notification (string id, GLib.Notification notification) {
        this.application.send_notification (id, notification);

        uint old_source_id = this.transient_notification_timeout_ids.get (id);

        if (old_source_id > 0) {
            this.transient_notification_timeout_ids.remove (id);
            GLib.Source.remove (old_source_id);
        }

        if (this.session_status.is_locked ()) {
            // If the session is locked, the notification will be withdrawn when
            // the session is unlocked, inside on_session_unlocked_cb.
            this.transient_notification_timeout_ids.set (id, 0);
        } else {
            // Otherwise, it will be withdrawn after a timeout.
            uint source_id = GLib.Timeout.add_seconds (
                TRANSIENT_NOTIFICATION_INTERVAL_SECONDS,
                () => {
                    this.application.withdraw_notification (id);
                    this.transient_notification_timeout_ids.remove (id);
                    return GLib.Source.REMOVE;
                }
            );
            this.transient_notification_timeout_ids.set (id, source_id);
        }


    }

    /**
     * Close a notification proactively, if it is still open.
     */
    public void hide_notification (string id) {
        this.application.withdraw_notification (id);
    }

    private void on_session_unlocked_cb () {
        // Remove all transient notifications on session unlock
        this.transient_notification_timeout_ids.foreach (
            (notification_id, source_id) => {
                this.application.withdraw_notification (notification_id);
                if (source_id > 0) {
                    this.transient_notification_timeout_ids.remove (notification_id);
                }
            }
        );
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
}

}
