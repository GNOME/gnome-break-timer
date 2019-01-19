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

public abstract class UIFragment : Object, IFocusable {
    /**
     * Provides a simple interface for UIManager to create notifications and
     * overlays.
     */

    protected UIManager ui_manager;

    protected Notify.Notification? notification;

    protected FocusPriority focus_priority = FocusPriority.LOW;

    public bool has_ui_focus () {
        return this.ui_manager.is_focusing (this);
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

    protected bool can_lock_screen () {
        return this.ui_manager.can_lock_screen ();
    }

    protected void lock_screen () {
        if (this.has_ui_focus ()) {
            this.ui_manager.lock_screen ();
        }
    }

    protected bool notifications_can_do (string action) {
        return this.ui_manager.notifications_can_do (action);
    }

    protected void show_notification (Notify.Notification notification) {
        if (this.has_ui_focus ()) {
            this.ui_manager.show_notification (notification);
            this.notification = notification;
        }
    }

    protected void show_lock_notification (Notify.Notification notification) {
        if (this.has_ui_focus ()) {
            this.ui_manager.show_lock_notification (notification);
            this.notification = notification;
        }
    }

    protected void hide_notification () {
        this.ui_manager.hide_notification (this.notification);
    }

    /* IFocusable interface */

    protected abstract void focus_started ();
    protected abstract void focus_stopped ();
}

}
