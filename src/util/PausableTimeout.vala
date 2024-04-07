/* PausableTimeout.vala
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

namespace BreakTimer.Daemon.Util {

/**
 * Calls a function continuously with a particular interval, in seconds. An
 * instance of PausableTimout is attached to a particular TimeoutCB function,
 * so it is trivial to stop and start the timeout by calling the stop and
 * start methods, respectively.
 */
public class PausableTimeout : GLib.Object {
    public delegate void TimeoutCB (PausableTimeout timeout, int delta_millisecs);

    private unowned TimeoutCB timeout_cb;
    private uint source_id;
    private int frequency;
    private int64 last_time;

    public PausableTimeout (TimeoutCB callback, int frequency) {
        this.timeout_cb = callback;
        this.frequency = frequency;
    }

    public string serialize () {
        return string.joinv (",", {
            this.frequency.to_string (),
            this.last_time.to_string ()
        });
    }

    public void deserialize (string data) {
        string[] data_parts = data.split (",");
        this.frequency = int.parse (data_parts[0]);
        this.last_time = int64.parse (data_parts[1]);
    }

    private bool timeout_wrapper () {
        int64 now = TimeUnit.get_monotonic_time ();
        int64 time_delta = now - this.last_time;
        this.last_time = now;

        int delta_millisecs = (int) (time_delta / TimeUnit.MILLISECONDS_IN_SECONDS);
        this.timeout_cb (this, delta_millisecs);

        return GLib.Source.CONTINUE;
    }

    public void run_once () {
        this.timeout_wrapper ();
    }

    public void start () {
        if (this.is_running ()) {
            GLib.Source.remove (this.source_id);
        }

        this.last_time = TimeUnit.get_monotonic_time ();

        this.source_id = GLib.Timeout.add_seconds (this.frequency, this.timeout_wrapper);
    }

    public void set_frequency (int frequency) {
        this.frequency = frequency;
        if (this.is_running ()) {
            this.start ();
        }
    }

    public void stop () {
        if (this.is_running ()) {
            GLib.Source.remove (this.source_id);
            this.source_id = 0;
        }
    }

    public bool is_running () {
        return this.source_id > 0;
    }
}

}
