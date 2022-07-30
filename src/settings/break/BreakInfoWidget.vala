/* BreakInfoWidget.vala
 *
 * Copyright 2020-2021 Dylan McCall <dylan@dylanmccall.ca>
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

namespace BreakTimer.Settings.Break {

public abstract class BreakInfoWidget : Gtk.Box {
    public BreakType break_type { public get; private set; }
    public string title { public get; private set; }

    private Adw.StatusPage status_page;
    private Gtk.Label detail_label;

    protected BreakInfoWidget (BreakType break_type, string title) {
        GLib.Object ();

        this.break_type = break_type;
        this.title = title;

        this.status_page = new Adw.StatusPage ();
        this.append (this.status_page);

        this.status_page.set_hexpand (true);
        this.status_page.set_vexpand (true);

        this.detail_label = new Gtk.Label (null);
        this.status_page.set_child (this.detail_label);

        this.show ();
    }

    protected void set_heading (string heading) {
        this.status_page.set_title (heading);
    }

    protected void set_description (string description) {
        this.status_page.set_description (description);
    }

    protected void set_detail (string detail) {
        this.detail_label.set_label (detail);
    }
}

}
