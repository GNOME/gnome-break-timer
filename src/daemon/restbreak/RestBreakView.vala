/* RestBreakView.vala
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
using BreakTimer.Daemon.TimerBreak;
using BreakTimer.Daemon.Util;

namespace BreakTimer.Daemon.RestBreak {

/* TODO: Use a single persistent notification throughout a given break */

public class RestBreakView : TimerBreakView {
    protected RestBreakController rest_break {
        get {
            return (RestBreakController) this.break_controller;
        }
    }

    protected override FocusPriority focus_priority {get; default = FocusPriority.HIGH;}
    protected override string[] notification_ids {get; default = {"restbreak.active", "restbreak.finished"};}

    private int64 original_start_time = 0;
    private bool was_skipped = false;
    private bool human_is_resting = false;

    private int64 last_break_notification_time = 0;

    public RestBreakView (RestBreakController rest_break, UIManager ui_manager) {
        base (rest_break, ui_manager);

        this.focused_and_activated.connect (this.focused_and_activated_cb);
        this.lost_ui_focus.connect (this.lost_ui_focus_cb);
        this.rest_break.finished.connect (this.finished_cb);
    }

    public override string? get_status_message () {
        int starts_in_value = this.rest_break.starts_in ();
        string starts_in_text = NaturalTime.instance.get_countdown_for_seconds (starts_in_value);

        if (this.rest_break.state == WAITING) {
            return ngettext (
                /* %s will be replaced with a string that describes a time interval, such as "2 minutes", "40 seconds" or "1 hour" */
                "Break starts in %s",
                "Break starts in %s",
                starts_in_value
            ).printf (starts_in_text);
        } else if (this.rest_break.state == ACTIVE) {
            return _("Time for a break");
        } else {
            return null;
        }
    }

    public override void dismiss_break () {
        // Instead of skipping the break, we postpone for a little while.
        // Enough time to think about what you've done. You monster.
        this.rest_break.postpone (this.rest_break.interval / 4);
    }

    private void show_start_notification () {
        // FIXME: Should say how long the break is?
        string body_text = _("It’s time to take a break. Get away from the computer for a little while!");

        var notification = new GLib.Notification (_("Time for a break"));
        notification.set_body (body_text);
        notification.set_priority (GLib.NotificationPriority.HIGH);
        this.add_notification_actions (notification);

        this.last_break_notification_time = TimeUnit.get_real_time_seconds ();

        this.hide_notification ("restbreak.finished");
        this.show_notification ("restbreak.active", notification);
    }

    private void show_interrupted_notification () {
        int countdown_value;
        int time_remaining = this.rest_break.get_time_remaining ();
        int start_time = this.rest_break.get_current_duration ();
        string countdown_text = NaturalTime.instance.get_countdown_for_seconds_with_start (
            time_remaining, start_time, out countdown_value);

        string body_text = ngettext (
            /* %s will be replaced with a string that describes a time interval, such as "2 minutes", "40 seconds" or "1 hour" */
            "There is %s remaining in your break",
            "There are %s remaining in your break",
            countdown_value
        ).printf (countdown_text);

        var notification = new GLib.Notification (_("Break interrupted"));
        notification.set_body (body_text);
        notification.set_priority (GLib.NotificationPriority.HIGH);
        this.add_notification_actions (notification);

        this.last_break_notification_time = TimeUnit.get_real_time_seconds ();

        this.hide_notification ("restbreak.finished");
        this.show_notification ("restbreak.active", notification);
    }

    private void show_overdue_notification () {
        int delay_value;
        int64 now = TimeUnit.get_real_time_seconds ();
        int time_since_start = (int) (now - this.original_start_time);
        string delay_text = NaturalTime.instance.get_simplest_label_for_seconds (
            time_since_start, out delay_value);

        string body_text = ngettext (
            /* %s will be replaced with a string that describes a time interval, such as "2 minutes", "40 seconds" or "1 hour" */
            "You were due to take a break %s ago",
            "You were due to take a break %s ago",
            delay_value
        ).printf (delay_text);

        var notification = new GLib.Notification (_("Overdue break"));
        notification.set_body (body_text);
        notification.set_priority (GLib.NotificationPriority.HIGH);
        this.add_notification_actions (notification);

        this.last_break_notification_time = TimeUnit.get_real_time_seconds ();

        this.hide_notification ("restbreak.finished");
        this.show_notification ("restbreak.active", notification);
    }

    private void show_finished_notification () {
        string body_text = _("Your break time has ended");

        var notification = new GLib.Notification (_("Break is over"));
        notification.set_body (body_text);
        notification.set_priority (GLib.NotificationPriority.NORMAL);
        notification.set_default_action ("app.show-break-info");

        this.hide_notification ("restbreak.active");
        this.show_transient_notification ("restbreak.finished", notification);
        this.play_sound_from_id ("complete");
    }

    private void add_notification_actions (GLib.Notification notification) {
        /* Label for a notification action that will delay the current break for a few minutes */
        notification.add_button (_("Remind me later"), "app.dismiss-break::restbreak");
        /* Label for a notification action that shows information about the current break */
        notification.add_button (_("What should I do?"), "app.show-break-info");
        notification.set_default_action ("app.show-break-info");
    }

    private int seconds_since_last_break_notification () {
        int64 now = TimeUnit.get_real_time_seconds ();
        if (this.last_break_notification_time > 0) {
            return (int) (now - this.last_break_notification_time);
        } else {
            return 0;
        }
    }

    private void focused_and_activated_cb () {
        this.human_is_resting = false;

        if (! this.was_skipped) {
            this.original_start_time = TimeUnit.get_real_time_seconds ();
            this.show_start_notification ();
        } else {
            this.show_overdue_notification ();
        }

        this.rest_break.counting.connect (this.counting_cb);
        this.rest_break.delayed.connect (this.delayed_cb);
        this.rest_break.current_duration_changed.connect (this.current_duration_changed_cb);
    }

    private void lost_ui_focus_cb () {
        this.rest_break.counting.disconnect (this.counting_cb);
        this.rest_break.delayed.disconnect (this.delayed_cb);
        this.rest_break.current_duration_changed.disconnect (this.current_duration_changed_cb);
        this.hide_notification ("restbreak.active");
    }

    private void finished_cb (BreakController.FinishedReason reason, bool was_active) {
        this.was_skipped = (reason == BreakController.FinishedReason.SKIPPED);

        if (was_active && reason == BreakController.FinishedReason.SATISFIED) {
            this.show_finished_notification ();
        } else {
            this.hide_notification ("restbreak.active");
        }
    }

    private void counting_cb (int lap_time, int total_time) {
        this.human_is_resting = lap_time > 20;

        if (this.human_is_resting && this.rest_break.lock_screen_enabled) {
            this.lock_screen ();
        }
    }

    private void delayed_cb (int lap_time, int total_time) {
        if (this.human_is_resting) {
            // Show a "Break interrupted" notification if the break has
            // been counting down happily until now
            this.show_interrupted_notification ();
        } else if (this.seconds_since_last_break_notification () > 60) {
            // Show an "Overdue break" notification every minute if the
            // break is being delayed.
            this.show_overdue_notification ();
        }

        this.human_is_resting = false;
    }

    private void current_duration_changed_cb () {
        // TODO: Do something annoying?
    }
}

}
