/*
 * This file is part of Brain Break.
 * 
 * Brain Break is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * Brain Break is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with Brain Break.  If not, see <http://www.gnu.org/licenses/>.
 */

public class TimerBreakSettingsPanel : BreakSettingsPanel {
	public TimerBreakSettingsPanel(TimerBreakType break_type, string title, string? description) {
		base(break_type, title, description);
		
		var details_grid = new Gtk.Grid();
		this.set_details(details_grid);
		
		details_grid.set_column_spacing(8);
		details_grid.set_row_spacing(8);
		
		var interval_label = new Gtk.Label.with_mnemonic(_("Every"));
		interval_label.set_halign(Gtk.Align.END);
		details_grid.attach(interval_label, 0, 1, 1, 1);
		
		var interval_chooser = new TimeChooser(break_type.interval_options, _("%s frequency").printf(title));
		details_grid.attach_next_to(interval_chooser, interval_label, Gtk.PositionType.RIGHT, 1, 1);
		break_type.settings.bind("interval-seconds", interval_chooser, "time-seconds", SettingsBindFlags.DEFAULT);
		
		var duration_label = new Gtk.Label.with_mnemonic(_("For"));
		duration_label.set_halign(Gtk.Align.END);
		details_grid.attach(duration_label, 0, 2, 1, 1);
		
		var duration_chooser = new TimeChooser(break_type.duration_options, _("%s duration").printf(title));
		details_grid.attach_next_to(duration_chooser, duration_label, Gtk.PositionType.RIGHT, 1, 1);
		break_type.settings.bind("duration-seconds", duration_chooser, "time-seconds", SettingsBindFlags.DEFAULT);
		
		details_grid.show_all();
	}
}

