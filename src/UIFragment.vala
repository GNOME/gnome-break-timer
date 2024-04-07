/* UIFragment.vala
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

using BreakTimer.Daemon.Util;

namespace BreakTimer.Daemon {

/**
 * Provides a simple interface for UIManager to create notifications and
 * overlays.
 */
public abstract class UIFragment : GLib.Object, IFocusable {
    protected UIManager ui_manager;

    protected virtual FocusPriority focus_priority {get; default = FocusPriority.LOW;}
    protected virtual string[] notification_ids {get; default = {};}

    public bool has_ui_focus () {
        return this.ui_manager.is_focusing (this);
    }

    public bool has_higher_focus_priority (UIFragment other) {
        return this.focus_priority > other.focus_priority;
    }

    protected void reset_ui () {
        this.hide_all_notifications ();
    }

    protected void request_ui_focus () {
        if (this.has_ui_focus ()) {
            // If we already have focus, UIManager will not call
            // focus_started again. We need to call it ourselves.
            this.focus_started ();
        } else {
            this.ui_manager.request_focus (this, this.focus_priority);
        }
    }

    protected void release_ui_focus () {
        this.ui_manager.release_focus (this);
    }

    protected void play_sound_from_id (string event_id) {
        if (this.has_ui_focus ()) {
            this.ui_manager.play_sound_from_id (event_id);
        }
    }

    protected void lock_screen () {
        if (this.has_ui_focus ()) {
            this.ui_manager.lock_screen ();
        }
    }

    private void hide_all_notifications () {
        foreach (string id in this.notification_ids) {
            this.hide_notification (id);
        }
    }

    protected void show_notification (string id, GLib.Notification notification) {
        if (this.has_ui_focus ()) {
            this.ui_manager.show_notification (id, notification);
        }
    }

    protected void show_transient_notification (string id, GLib.Notification notification) {
        if (this.has_ui_focus ()) {
            this.ui_manager.show_transient_notification (id, notification);
        }
    }

    protected void hide_notification (string id) {
        this.ui_manager.hide_notification (id);
    }

    /* IFocusable interface */

    protected abstract void focus_started ();
    protected abstract void focus_stopped ();
}

}
