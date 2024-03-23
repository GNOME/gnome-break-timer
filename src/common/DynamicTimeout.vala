/* PausableTimeout.vala
 *
 * Copyright 2024 Dylan McCall <dylan@dylanmccall.ca>
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

namespace BreakTimer.Common {

/**
 * Calls a function continuously with an interval that can be changed at any
 * time, either in seconds or in milliseconds.
 */
public class DynamicTimeout : GLib.Object {
    private GLib.SourceFunc timeout_cb;

    private uint interval;
    private bool interval_seconds;
    private int priority;

    private uint source_id;

    public DynamicTimeout (owned GLib.SourceFunc timeout_cb) {
        this.timeout_cb = (owned) timeout_cb;
        this.interval = 0;
        this.interval_seconds = false;
        this.priority = GLib.Priority.DEFAULT;
        this.source_id = 0;
    }

    public void set_interval (uint interval) {
        if (this.interval == interval && this.interval_seconds == false) {
            return;
        }
        this.interval = interval;
        this.interval_seconds = false;
        this.restart_if_running ();
    }

    public void set_interval_seconds (uint interval) {
        if (this.interval == interval && this.interval_seconds == true) {
            return;
        }
        this.interval = interval;
        this.interval_seconds = true;
        this.restart_if_running ();
    }

    public void set_priority (int priority) {
        if (this.priority == priority) {
            return;
        }
        this.priority = priority;
        this.restart_if_running ();
    }

    public void start () {
        this.stop ();
        if (this.interval_seconds) {
            this.source_id = GLib.Timeout.add_seconds (this.interval, this.timeout_wrapper, this.priority);
        } else {
            this.source_id = GLib.Timeout.add (this.interval, this.timeout_wrapper, this.priority);
        }
    }

    public void stop () {
        if (!this.is_running ()) {
            return;
        }
        GLib.Source.remove (this.source_id);
        this.source_id = 0;
    }

    public bool is_running () {
        return this.source_id > 0;
    }

    private void restart_if_running () {
        if (this.is_running ()) {
            this.start ();
        }
    }

    private bool timeout_wrapper () {
        bool result = this.timeout_cb ();
        if (result == GLib.Source.REMOVE) {
            this.source_id = 0;
        }
        return result;
    }
}

}
