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

/**
 * Central place to manage UI throughout the application. We need this to
 * maintain a simple, modal structure. This uses SimpleFocusManager to make
 * sure only one break is affecting the UI at a time. This class also tries
 * to keep UI events nicely spaced so they don't turn into noise. Any object
 * which needs to provide a GUI implements UIFragment, which provides a simple
 * interface to create notifications and overlays.
 */
public class UIManager : SimpleFocusManager {
    public abstract class UIFragment : Object, IFocusable {
        protected UIManager ui_manager;

        protected IScreenOverlayContent? overlay_content;
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
            /* FIXME: Replace this with a modern equivalent? */
            /*
            if (this.has_ui_focus ()) {
                unowned Canberra.Context canberra = CanberraGtk.context_get ();
                canberra.play (0,
                    Canberra.PROP_EVENT_ID, event_id
                );
            }
            */
        }

        protected bool can_lock_screen () {
            return ! this.ui_manager.application.is_inhibited (Gtk.ApplicationInhibitFlags.IDLE);
        }

        protected void lock_screen () {
            if (this.has_ui_focus ()) {
                if (! this.ui_manager.session_status.is_locked ()) {
                    this.ui_manager.session_status.lock_screen ();
                }
            }
        }

        protected bool notifications_can_do (string capability) {
            // For whatever reason notify_capabilities.index () isn't matching
            // our capability strings, so we'll search the list ourselves
            foreach (string server_capability in this.ui_manager.notify_capabilities) {
                if (server_capability == capability) return true;
            }
            return false;
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

        protected void set_overlay (IScreenOverlayContent overlay_content) {
            if (this.ui_manager.screen_overlay == null) return;

            this.overlay_content = overlay_content;

            if (this.has_ui_focus ()) {
                this.ui_manager.screen_overlay.set_content (this.overlay_content);
            }
        }

        protected void reveal_overlay () {
            if (this.ui_manager.screen_overlay == null) return;

            if (this.has_ui_focus ()) {
                this.ui_manager.screen_overlay.reveal_content (this.overlay_content);
            }
        }

        protected void shake_overlay () {
            if (this.ui_manager.screen_overlay == null) return;

            if (this.overlay_is_visible ()) {
                this.ui_manager.screen_overlay.request_attention ();
            }
        }

        protected bool overlay_is_visible () {
            if (this.ui_manager.screen_overlay == null) {
                return false;
            } else {
                return this.ui_manager.screen_overlay.is_showing_content (this.overlay_content);
            }
        }

        protected void hide_overlay () {
            if (this.ui_manager.screen_overlay == null) return;

            this.ui_manager.screen_overlay.disappear_content (this.overlay_content);
        }

        /* IFocusable interface */

        protected abstract void focus_started ();
        protected abstract void focus_stopped ();
    }

    private weak Gtk.Application application;
    private ISessionStatus session_status;
    
    public bool quiet_mode { get; set; default=false; }
    public int64 quiet_mode_expire_time { get; set; }

    private PausableTimeout quiet_mode_timeout;

    protected ScreenOverlay? screen_overlay;
    protected Notify.Notification? notification;

    protected List<string> notify_capabilities;

    // The desktop-entry notification hint wants our desktop ID without the
    // ".desktop" part, so we need to trim it accordingly
    private static string DESKTOP_ENTRY_BASENAME = Config.HELPER_DESKTOP_ID.slice (
        0, Config.HELPER_DESKTOP_ID.last_index_of (".desktop")
    );
    
    public UIManager (Gtk.Application application, ISessionStatus session_status, bool with_overlay) {
        this.application = application;
        this.session_status = session_status;

        if (with_overlay) {
            this.screen_overlay = new ScreenOverlay ();
        }
        
        Settings settings = new Settings ("org.gnome.BreakTimer");
        settings.bind ("quiet-mode", this, "quiet-mode", SettingsBindFlags.DEFAULT);
        settings.bind ("quiet-mode-expire-time", this, "quiet-mode-expire-time", SettingsBindFlags.DEFAULT);

        this.quiet_mode_timeout = new PausableTimeout (this.quiet_mode_timeout_cb, 30);
        this.notify["quiet-mode"].connect ( (s, p) => {
            this.update_overlay_format ();
        });
        this.update_overlay_format ();

        this.session_status.unlocked.connect (this.hide_lock_notification_cb);
        this.notify_capabilities = Notify.get_server_caps ();
    }

    private void quiet_mode_timeout_cb (PausableTimeout timeout, int delta_millisecs) {
        int64 now = Util.get_real_time_seconds ();
        if (this.quiet_mode && now > this.quiet_mode_expire_time) {
            this.quiet_mode = false;
            this.quiet_mode_expire_time = 0;
            GLib.debug ("Automatically expiring quiet mode");
        }
    }

    private void update_overlay_format () {
        if (this.screen_overlay == null) return;

        if (this.quiet_mode) {
            this.screen_overlay.set_format (ScreenOverlay.Format.SILENT);
            this.quiet_mode_timeout.start ();
            this.quiet_mode_timeout.run_once ();
            GLib.debug ("Quiet mode enabled");
        } else {
            this.screen_overlay.set_format (ScreenOverlay.Format.FULL);
            this.quiet_mode_timeout.stop ();
            GLib.debug ("Quiet mode disabled");
        }
    }

    /**
     * Show a notification, ensuring that the application is only showing one
     * notification at any time.
     */
    protected void show_notification (Notify.Notification notification) {
        if (notification != this.notification) {
            this.hide_notification (this.notification);
        }
        notification.set_hint ("desktop-entry", DESKTOP_ENTRY_BASENAME);
        try {
            notification.show ();
        } catch (Error error) {
            GLib.warning ("Error showing notification: %s", error.message);
        }
        this.notification = notification;
    }

    private Notify.Notification? lock_notification;
    /**
     * Show a notification that will only appear in the lock screen. The
     * notification automatically hides when the screen is unlocked.
     */
    protected void show_lock_notification (Notify.Notification notification) {
        if (this.session_status.is_locked ()) {
            this.lock_notification = notification;
        } else {
            notification.set_hint ("transient", true);
        }
        this.show_notification (notification);
    }

    private void hide_lock_notification_cb () {
        this.hide_notification (this.lock_notification, true);
        this.lock_notification = null;
    }

    /**
     * Close a notification proactively, if it is still open.
     */
    protected void hide_notification (Notify.Notification? notification, bool immediate=true) {
        if (notification != null && this.notification == notification) {
            try {
                if (immediate) {
                    this.notification.close ();
                } else {
                    this.notification.set_hint ("transient", true);
                    this.notification.show ();
                }
            } catch (Error error) {
                // We ignore this error, because it's usually just noise
                // GLib.warning ("Error closing notification: %s", error.message);
            }
        }
        this.notification = null;
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
