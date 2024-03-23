/* MicroBreakView.vala
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

namespace BreakTimer.Daemon.MicroBreak {

/* TODO: notification when user is away for rest duration */
/* TODO: replace pause break if appropriate */

public class MicroBreakView : TimerBreakView {
    protected MicroBreakController micro_break {
        get {
            return (MicroBreakController) this.break_controller;
        }
    }

    protected override FocusPriority focus_priority {get; default = FocusPriority.LOW;}
    protected override string[] notification_ids {get; default = {"microbreak.active", "microbreak.finished"};}

    private int delay_time_notified = 0;

    public MicroBreakView (MicroBreakController micro_break, UIManager ui_manager) {
        base (micro_break, ui_manager);

        this.focused_and_activated.connect (this.focused_and_activated_cb);
        this.lost_ui_focus.connect (this.lost_ui_focus_cb);
        this.micro_break.finished.connect (this.finished_cb);
    }

    public override string? get_status_message () {
        int starts_in_value = this.micro_break.starts_in ();
        string starts_in_text = NaturalTime.instance.get_countdown_for_seconds (starts_in_value);

        if (this.micro_break.state == WAITING) {
            return ngettext (
                /* %s will be replaced with a string that describes a time interval, such as "2 minutes", "40 seconds" or "1 hour" */
                "Microbreak starts in %s",
                "Microbreak starts in %s",
                starts_in_value
            ).printf (starts_in_text);
        } else if (this.micro_break.state == ACTIVE) {
            return _("Time for a microbreak");
        } else {
            return null;
        }
    }

    public override void dismiss_break () {
        this.micro_break.skip (true);
    }

    private void show_start_notification () {
        string body_text = _("Take a break from typing and look away from the screen");

        var notification = new GLib.Notification (_("It’s time for a micro break"));
        notification.set_body (body_text);
        notification.set_priority (GLib.NotificationPriority.HIGH);
        this.add_notification_actions (notification);

        this.hide_notification ("microbreak.finished");
        this.show_notification ("microbreak.active", notification);
    }

    private void show_overdue_notification () {
        int delay_value;
        int time_since_start = this.micro_break.get_seconds_since_start ();
        string delay_text = NaturalTime.instance.get_simplest_label_for_seconds (
            time_since_start, out delay_value);

        string body_text = ngettext (
            /* %s will be replaced with a string that describes a time interval, such as "2 minutes", "40 seconds" or "1 hour" */
            "You were due to take a micro break %s ago",
            "You were due to take a micro break %s ago",
            delay_value
        ).printf (delay_text);

        var notification = new GLib.Notification (_("Overdue micro break"));
        notification.set_body (body_text);
        notification.set_priority (GLib.NotificationPriority.HIGH);
        this.add_notification_actions (notification);

        this.hide_notification ("microbreak.finished");
        this.show_notification ("microbreak.active", notification);
    }

    private void show_finished_notification () {
        string body_text = _("Your micro break has ended");

        var notification = new GLib.Notification (_("Break is over"));
        notification.set_body (body_text);
        notification.set_priority (GLib.NotificationPriority.NORMAL);
        notification.set_default_action ("app.show-break-info");

        this.hide_notification ("microbreak.active");
        this.show_transient_notification ("microbreak.finished", notification);
        this.play_sound_from_id ("complete");
    }

    private void add_notification_actions (GLib.Notification notification) {
        /* Label for a notification action that skips the current break */
        notification.add_button (_("Skip this one"), "app.dismiss-break::microbreak");
        /* Label for a notification action that shows information about the current break */
        notification.add_button (_("What should I do?"), "app.show-break-info");
        notification.set_default_action ("app.show-break-info");
    }

    private void focused_and_activated_cb () {
        this.delay_time_notified = 0;

        this.show_start_notification ();

        this.micro_break.delayed.connect (this.delayed_cb);
    }

    private void lost_ui_focus_cb () {
        this.micro_break.delayed.disconnect (this.delayed_cb);
        this.hide_notification ("microbreak.active");
    }

    private void finished_cb (BreakController.FinishedReason reason, bool was_active) {
        if (reason == BreakController.FinishedReason.SATISFIED && was_active) {
            this.show_finished_notification ();
        } else {
            this.hide_notification ("microbreak.active");
        }
    }

    private void delayed_cb (int lap_time, int total_time) {
        int time_since_notified = total_time - this.delay_time_notified;
        if (time_since_notified > this.micro_break.interval) {
            this.show_overdue_notification ();
            this.delay_time_notified = total_time;
        }
    }
}

}
