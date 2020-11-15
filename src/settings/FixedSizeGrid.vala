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

namespace BreakTimer.Settings {

class FixedSizeGrid : Gtk.Grid {
    public override void adjust_size_request (Gtk.Orientation orientation, ref int minimum_size, ref int natural_size) {
        foreach (Gtk.Widget widget in this.get_hidden_children ()) {
            int widget_allocated_size = 0;

            if (orientation == Gtk.Orientation.VERTICAL && this.orientation == Gtk.Orientation.VERTICAL) {
                widget_allocated_size = widget.get_allocated_height ();
            } else if (orientation == Gtk.Orientation.HORIZONTAL && this.orientation == Gtk.Orientation.HORIZONTAL) {
                widget_allocated_size = widget.get_allocated_width ();
            }

            minimum_size += widget_allocated_size;
            natural_size += widget_allocated_size;

            widget.adjust_size_request (orientation, ref minimum_size, ref natural_size);
        }

        base.adjust_size_request (orientation, ref minimum_size, ref natural_size);
    }

    private GLib.List<weak Gtk.Widget> get_hidden_children () {
        var hidden_children = new GLib.List<weak Gtk.Widget> ();
        foreach (Gtk.Widget widget in this.get_children ()) {
            if (! widget.is_visible ()) hidden_children.append (widget);
        }
        return hidden_children;
    }
}

}
