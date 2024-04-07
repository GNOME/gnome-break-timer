/* BreakView.vala
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

namespace BreakTimer.Daemon.Break {

public abstract class BreakView : UIFragment {
    protected weak BreakController break_controller;

    /** The break is active and has been given UI focus. This is the point where we start caring about it. */
    public signal void focused_and_activated ();
    /** The break has lost UI focus. We don't need to display anything at this point. */
    public signal void lost_ui_focus ();

    protected BreakView (BreakController break_controller, UIManager ui_manager) {
        this.ui_manager = ui_manager;
        this.break_controller = break_controller;

        break_controller.enabled.connect (() => {
            this.reset_ui ();
            this.ui_manager.add_break (this);
        });
        break_controller.disabled.connect (() => {
            this.reset_ui ();
            this.ui_manager.remove_break (this);
        });

        break_controller.warned.connect (() => {
            this.request_ui_focus ();
        });
        break_controller.unwarned.connect (() => {
            this.release_ui_focus ();
        });
        break_controller.activated.connect (() => {
            this.request_ui_focus ();
        });
        break_controller.finished.connect_after (() => {
            this.release_ui_focus ();
        });
    }

    public abstract string? get_status_message ();

    /**
     * Dismiss the break according to some user input. The BreakController
     * may choose to skip the break, or delay it by some length of time.
     */
    public virtual void dismiss_break () {
        this.break_controller.skip ();
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
