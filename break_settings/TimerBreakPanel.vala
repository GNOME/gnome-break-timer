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

public class TimerBreakPanel : BreakPanel {
	protected int[] duration_options;
	
	TimeChooser interval_chooser;
	TimeChooser duration_chooser;
	
	public TimerBreakPanel(Settings settings, string break_id, string break_name, int[] interval_options,
			int[] duration_options) {
		base(settings, break_id, break_name, interval_options);
		
		this.duration_options = duration_options;
		
		Gtk.Grid details_grid = this.build_details_grid();
		this.get_content_area().add(details_grid);
	}
	
	private inline Gtk.Grid build_details_grid() {
		Gtk.Grid details_grid = new Gtk.Grid();
		
		details_grid.set_column_spacing(12);
		details_grid.set_row_spacing(8);
		
		Gtk.Label interval_label = new Gtk.Label.with_mnemonic("Every");
		interval_label.set_halign(Gtk.Align.START);
		details_grid.attach(interval_label, 0, 1, 1, 1);
		
		this.interval_chooser = new TimeChooser(this.interval_options, _("%s interval").printf(this.break_name));
		this.settings.bind("interval-seconds", this.interval_chooser, "time-seconds", SettingsBindFlags.DEFAULT);
		details_grid.attach_next_to(this.interval_chooser, interval_label, Gtk.PositionType.RIGHT, 1, 1);
		
		Gtk.Label duration_label = new Gtk.Label.with_mnemonic("For");
		duration_label.set_halign(Gtk.Align.START);
		details_grid.attach(duration_label, 0, 2, 1, 1);
		
		this.duration_chooser = new TimeChooser(this.duration_options, _("%s duration").printf(this.break_name));
		this.settings.bind("duration-seconds", this.duration_chooser, "time-seconds", SettingsBindFlags.DEFAULT);
		details_grid.attach_next_to(this.duration_chooser, duration_label, Gtk.PositionType.RIGHT, 1, 1);
		
		details_grid.show_all();
		
		return details_grid;
	}
}

