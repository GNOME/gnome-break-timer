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

using Gtk;
using GLib;

namespace BreakTimer.Settings {

public abstract class TimerBreakType : BreakType {
    public int interval { get; protected set; }
    public int duration { get; protected set; }

    public int[] interval_options;
    public int[] duration_options;

    public IBreakHelper_TimerBreak? break_server;

    public TimerBreakType (string name, GLib.Settings settings) {
        base (name, settings);
        settings.bind ("interval-seconds", this, "interval", SettingsBindFlags.GET);
        settings.bind ("duration-seconds", this, "duration", SettingsBindFlags.GET);
    }

    public signal void timer_status_changed (TimerBreakStatus? status);

    public override void initialize () {
        base.initialize ();
        Bus.watch_name (BusType.SESSION, Config.HELPER_BUS_NAME, BusNameWatcherFlags.NONE,
                this.breakhelper_appeared, this.breakhelper_disappeared);
    }

    protected new void update_status (TimerBreakStatus? status) {
        if (status != null) {
            base.update_status (BreakStatus () {
                is_enabled = status.is_enabled,
                is_focused = status.is_focused,
                is_active = status.is_active
            });
        } else {
            base.update_status (null);
        }
        this.timer_status_changed (status);
    }

    private uint update_timeout_id;
    private bool update_status_cb () {
        TimerBreakStatus? status = this.get_status ();
        this.update_status (status);
        return true;
    }

    private TimerBreakStatus? get_status () {
        if (this.break_server != null) {
            try {
                return this.break_server.get_status ();
            } catch (IOError error) {
                GLib.warning ("Error getting break status: %s", error.message);
                return null;
            }
        } else {
            return null;
        }
    }

    private void breakhelper_appeared () {
        try {
            this.break_server = Bus.get_proxy_sync (
                BusType.SESSION,
                Config.HELPER_BUS_NAME,
                Config.HELPER_BREAK_OBJECT_BASE_PATH+this.id,
                DBusProxyFlags.DO_NOT_AUTO_START
            );
            // We can only poll the break helper application for updates, so
            // for responsiveness we update at a faster than normal rate.
            this.update_timeout_id = Timeout.add (500, this.update_status_cb);
            this.update_status_cb ();
        } catch (IOError error) {
            this.break_server = null;
            GLib.warning ("Error connecting to break helper service: %s", error.message);
        }
    }

    private void breakhelper_disappeared () {
        if (this.update_timeout_id > 0) {
            Source.remove (this.update_timeout_id);
            this.update_timeout_id = 0;
        }
        this.break_server = null;
        this.update_status_cb ();
    }
}

public abstract class TimerBreakStatusPanel : BreakStatusPanel {
    private string upcoming_text;
    private string ongoing_text;

    private CircleCounter circle_counter;
    private Gtk.Label status_label;
    private Gtk.Label time_label;

    public TimerBreakStatusPanel (TimerBreakType break_type, string upcoming_text, string ongoing_text) {
        base (break_type);
        this.upcoming_text = upcoming_text;
        this.ongoing_text = ongoing_text;

        this.set_column_spacing (12);

        // FIXME: This is an application icon. It doesn't make sense here.
        this.circle_counter = new CircleCounter ();
        this.attach (this.circle_counter, 0, 0, 1, 1);

        var labels_grid = new Gtk.Grid ();
        this.attach (labels_grid, 1, 0, 1, 1);
        labels_grid.set_orientation (Gtk.Orientation.VERTICAL);
        labels_grid.set_row_spacing (18);
        labels_grid.set_valign (Gtk.Align.CENTER);

        this.status_label = new Gtk.Label (null);
        labels_grid.add (this.status_label);
        this.status_label.set_width_chars (25);
        this.status_label.get_style_context ().add_class ("_break-status-heading");

        this.time_label = new Gtk.Label (null);
        labels_grid.add (this.time_label);
        this.time_label.set_width_chars (25);
        this.time_label.get_style_context ().add_class ("_break-status-body");

        this.show_all ();

        break_type.timer_status_changed.connect (this.timer_status_changed_cb);
    }

    private void timer_status_changed_cb (TimerBreakStatus? status) {
        if (status == null) return;

        TimerBreakType timer_break = (TimerBreakType) this.break_type;
        
        if (status.is_active) {
            this.status_label.set_label (this.ongoing_text);
            string time_text = NaturalTime.instance.get_countdown_for_seconds_with_start (
                status.time_remaining, status.current_duration);
            this.time_label.set_label (time_text);
            this.circle_counter.direction = CircleCounter.Direction.COUNT_DOWN;
            this.circle_counter.progress = (status.current_duration - status.time_remaining) / (double)status.current_duration;
        } else {
            this.status_label.set_label (this.upcoming_text);
            string time_text = NaturalTime.instance.get_countdown_for_seconds (status.starts_in);
            this.time_label.set_label (time_text);
            this.circle_counter.direction = CircleCounter.Direction.COUNT_UP;
            this.circle_counter.progress = (timer_break.interval - status.starts_in) / (double)timer_break.interval;
        }
    }
}

public abstract class TimerBreakSettingsPanel : BreakSettingsPanel {
    public TimerBreakSettingsPanel (TimerBreakType break_type, string title, string? description) {
        base (break_type, title, description);
        
        var details_grid = new Gtk.Grid ();
        this.set_details (details_grid);
        
        details_grid.set_column_spacing (8);
        details_grid.set_row_spacing (8);
        
        /* Label for the widget to choose how frequently a break occurs. (Choices such as "6 minutes" or "45 minutes") */
        var interval_label = new Gtk.Label.with_mnemonic ( _("Every"));
        interval_label.set_halign (Gtk.Align.END);
        details_grid.attach (interval_label, 0, 1, 1, 1);

        var interval_chooser = new TimeChooser (break_type.interval_options);
        details_grid.attach_next_to (interval_chooser, interval_label, Gtk.PositionType.RIGHT, 1, 1);
        break_type.settings.bind ("interval-seconds", interval_chooser, "time-seconds", SettingsBindFlags.DEFAULT);
        
        /* Label for the widget to choose how long a break lasts when it occurs. (Choices such as "30 seconds" or "5 minutes") */
        var duration_label = new Gtk.Label.with_mnemonic ( _("For"));
        duration_label.set_halign (Gtk.Align.END);
        details_grid.attach (duration_label, 0, 2, 1, 1);
        
        var duration_chooser = new TimeChooser (break_type.duration_options);
        details_grid.attach_next_to (duration_chooser, duration_label, Gtk.PositionType.RIGHT, 1, 1);
        break_type.settings.bind ("duration-seconds", duration_chooser, "time-seconds", SettingsBindFlags.DEFAULT);
        
        details_grid.show_all ();
    }
}

}
