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
	
	public TimerBreakPanel(string break_name, string break_id, int[] interval_options, int[] duration_options) {
		base(break_name, break_id, interval_options);
		
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
		
		this.interval_chooser = new TimeChooser(this.interval_options);
		details_grid.attach_next_to(this.interval_chooser, interval_label, Gtk.PositionType.RIGHT, 1, 1);
		
		Gtk.Label duration_label = new Gtk.Label.with_mnemonic("For");
		duration_label.set_halign(Gtk.Align.START);
		details_grid.attach(duration_label, 0, 2, 1, 1);
		
		this.duration_chooser = new TimeChooser(this.duration_options);
		details_grid.attach_next_to(this.duration_chooser, duration_label, Gtk.PositionType.RIGHT, 1, 1);
		
		details_grid.show_all();
		
		return details_grid;
	}
}

private class TimeChooser : Gtk.ComboBox {
	private Gtk.ListStore list_store;
	
	private const int OPTION_OTHER = -1;
	
	public signal void time_selected(int time);
	
	public TimeChooser(int[] options) {
		Object();
		
		this.list_store = new Gtk.ListStore(3, typeof(string), typeof(string), typeof(int));
		
		this.set_model(this.list_store);
		this.set_id_column(1);
		
		Gtk.CellRendererText cell = new Gtk.CellRendererText();
		this.pack_start(cell, true);
		this.set_attributes(cell, "text", null);
		
		foreach (int time in options) {
			string label = NaturalTime.get_label_for_seconds(time);
			this.add_option(label, time);
		}
		this.add_option(_("Other…"), OPTION_OTHER);
		
		this.changed.connect(this.on_changed);
	}
	
	private void add_option(string label, int val) {
		string id = val.to_string();
		
		Gtk.TreeIter iter;
		this.list_store.append(out iter);
		this.list_store.set(iter, 0, label, 1, id, 2, val, -1);
	}
	
	private void on_changed() {
		if (this.get_active() < 0) {
			return;
		}
		
		Gtk.TreeIter iter;
		this.get_active_iter(out iter);
		
		int val;
		this.list_store.get(iter, 2, out val);
		if (val == OPTION_OTHER) {
			this.start_custom_input();
		} else {
			this.time_selected(val);
		}
	}
	
	private void start_custom_input() {
		Gtk.Window? parent_window = (Gtk.Window)this.get_toplevel();
		if (! parent_window.is_toplevel()) {
			parent_window = null;
		}
		TimeEntryDialog dialog = new TimeEntryDialog(parent_window, "Break interval"); // FIXME: get a better label
		dialog.present();
	}
}

private class TimeEntryDialog : Gtk.Dialog {
	private Gtk.Widget ok_button;
	private Gtk.Entry time_entry;
	
	public signal void time_entered(int time_seconds);
	
	public TimeEntryDialog(Gtk.Window? parent, string title) {
		Object();
		
		this.set_title(title);
		
		this.set_modal(true);
		this.set_destroy_with_parent(true);
		this.set_transient_for(parent);
		
		this.ok_button = this.add_button(Gtk.Stock.OK, Gtk.ResponseType.OK);
		this.response.connect((response_id) => {
			if (response_id == Gtk.ResponseType.OK) this.submit();
		});
		
		Gtk.Container content_area = (Gtk.Container)this.get_content_area();
		
		Gtk.Grid content_grid = new Gtk.Grid();
		content_grid.margin = 6;
		content_grid.set_row_spacing(4);
		content_area.add(content_grid);
		
		Gtk.Label entry_label = new Gtk.Label(title);
		content_grid.attach(entry_label, 0, 0, 1, 1);
		
		this.time_entry = new Gtk.Entry();
		this.time_entry.activate.connect(this.submit);
		content_grid.attach(this.time_entry, 0, 1, 1, 1);
		
		Gtk.EntryCompletion completion = new Gtk.EntryCompletion();
		Gtk.ListStore completion_store = new Gtk.ListStore(1, typeof(string));
		completion.set_model(completion_store);
		completion.set_text_column(0);
		completion.set_inline_completion(true);
		completion.set_popup_completion(false);
		
		Gtk.TreeIter iter;
		completion_store.append(out iter);
		completion_store.set(iter, 0, "minutes", -1);
		
		this.time_entry.set_completion(completion);
		
		content_area.show_all();
	}
	
	public void submit() {
		this.time_entered(60);
		this.destroy();
	}
}

