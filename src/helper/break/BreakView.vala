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

public abstract class BreakView : UIFragment {
    protected weak BreakController break_controller;

    private int64 last_break_notification_time = 0;

    protected BreakView (BreakController break_controller, UIManager ui_manager) {
        this.ui_manager = ui_manager;
        this.break_controller = break_controller;

        break_controller.enabled.connect ( () => { this.ui_manager.add_break (this); });
        break_controller.disabled.connect ( () => { this.ui_manager.remove_break (this); });

        break_controller.warned.connect ( () => { this.request_ui_focus (); });
        break_controller.unwarned.connect ( () => { this.release_ui_focus (); });
        break_controller.activated.connect ( () => { this.request_ui_focus (); });
        break_controller.finished.connect_after ( () => { this.release_ui_focus (); });
    }

    /** The break is active and has been given UI focus. This is the point where we start caring about it. */
    public signal void focused_and_activated ();
    /** The break has lost UI focus. We don't need to display anything at this point. */
    public signal void lost_ui_focus ();

    public abstract string get_status_message ();

    /**
     * Each BreakView should use a single resident notification, which we
     * update as the break's status changes. Removing the notification, at any
     * point, should skip the break. This function is guaranteed to return a
     * notification matching that description. Initially, it will create a
     * new notification, and once that notification is shown it will continue
     * to return a reference to that same notification until it is removed by
     * the application.
     * @see show_break_notification
     * @see hide_notification
     */
    protected Notify.Notification build_common_notification (string summary, string? body, string? icon) {
        Notify.Notification notification;
        if (this.notification != null) {
            notification = this.notification;
            notification.clear_actions ();
            notification.clear_hints ();
            notification.update (summary, body, icon);
        } else {
            notification = new Notify.Notification (summary, body, icon);
            notification.closed.connect (this.notification_closed_cb);
        }
        notification.set_hint ("resident", true);
        return notification;
    }

    protected void show_break_notification (Notify.Notification notification) {
        if (this.notifications_can_do ("actions")) {
            /* Label for a notification action that shows information about the current break */
            notification.add_action ("info", _("What should I do?"), this.notification_action_info_cb);
        }
        this.show_notification (notification);
        this.last_break_notification_time = Util.get_real_time_seconds ();
    }

    protected int seconds_since_last_break_notification () {
        int64 now = Util.get_real_time_seconds ();
        if (this.last_break_notification_time > 0) {
            return (int) (now - this.last_break_notification_time);
        } else {
            return 0;
        }
    }

    protected void show_break_info () {
        AppInfo settings_app_info = new DesktopAppInfo (Config.SETTINGS_APPLICATION_ID);
        AppLaunchContext app_launch_context = new AppLaunchContext ();
        try {
            settings_app_info.launch (null, app_launch_context);
        } catch (Error error) {
            stderr.printf ("Error launching settings application: %s\n", error.message);
        }
    }

    protected virtual void dismiss_break () {
        this.break_controller.skip ();
    }

    private void notification_action_info_cb () {
        this.show_break_info ();
    }

    private void notification_closed_cb () {
        // If the notification is dismissed in a particularly forceful way, we assume the
        // user is cutting the break short. When we're using persistent notifications,
        // this requires the user to explicitly remove the notification with its context
        // menu in the message tray.
        if (this.notification.get_closed_reason () == 2 && this.notifications_can_do ("persistence")) {
            // Notification closed reason code 2: dismissed by the user
            this.dismiss_break ();
        }
    }

    /* UIFragment interface */

    protected override void focus_started () {
        if (this.break_controller.is_active ()) {
            this.focused_and_activated ();
        }
        // else the break may have been given focus early. (See the BreakController.warned signal).
    }

    protected override void focus_stopped () {
        this.lost_ui_focus ();
        // We don't hide the current notification, because we might have a
        // "Finished" notification that outlasts the UIFragment
    }
}

}
