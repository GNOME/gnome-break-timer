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

    private int delay_time_notified = 0;

    public MicroBreakView (MicroBreakController micro_break, UIManager ui_manager) {
        base (micro_break, ui_manager);
        this.focus_priority = FocusPriority.LOW;

        this.focused_and_activated.connect (this.focused_and_activated_cb);
        this.lost_ui_focus.connect (this.lost_ui_focus_cb);
        this.micro_break.finished.connect (this.finished_cb);
    }

    protected new void show_break_notification (Notify.Notification notification) {
        if (this.notifications_can_do ("actions")) {
            /* Label for a notification action that will skip the current microbreak */
            notification.add_action ("skip", _("Skip this one"), this.notification_action_skip_cb);
        }
        base.show_break_notification (notification);
    }

    private void show_start_notification () {
        var notification = this.build_common_notification (
            _("It’s time for a micro break"),
            _("Take a break from typing and look away from the screen")
        );
        notification.set_urgency (Notify.Urgency.NORMAL);
        notification.set_hint ("sound-name", "message");
        this.show_break_notification (notification);
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

        var notification = this.build_common_notification (
            _("Overdue micro break"),
            body_text
        );
        notification.set_urgency (Notify.Urgency.NORMAL);
        this.show_break_notification (notification);
    }

    private void show_finished_notification () {
        var notification = this.build_common_notification (
            _("Break is over"),
            _("Your micro break has ended")
        );
        notification.set_urgency (Notify.Urgency.NORMAL);
        this.show_lock_notification (notification);

        this.play_sound_from_id ("complete");
    }

    private void focused_and_activated_cb () {
        this.delay_time_notified = 0;

        this.show_start_notification ();

        this.micro_break.delayed.connect (this.delayed_cb);
    }

    private void lost_ui_focus_cb () {
        this.micro_break.delayed.disconnect (this.delayed_cb);
    }

    private void finished_cb (BreakController.FinishedReason reason, bool was_active) {
        if (reason == BreakController.FinishedReason.SATISFIED && was_active) {
            this.show_finished_notification ();
        } else {
            this.hide_notification (IMMEDIATE);
        }
    }

    private void delayed_cb (int lap_time, int total_time) {
        int time_since_notified = total_time - this.delay_time_notified;
        if (time_since_notified > this.micro_break.interval) {
            this.show_overdue_notification ();
            this.delay_time_notified = total_time;
        }
    }

    private void notification_action_skip_cb () {
        this.break_controller.skip (true);
    }
}

}
