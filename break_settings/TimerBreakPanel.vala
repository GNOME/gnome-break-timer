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
	
	private Gtk.ListStore completion_store;
	
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
		this.time_entry.insert_text.connect(this.time_entry_text_inserted);
		this.time_entry.changed.connect(this.time_entry_changed);
		content_grid.attach(this.time_entry, 0, 1, 1, 1);
		
		Gtk.EntryCompletion completion = new Gtk.EntryCompletion();
		this.completion_store = new Gtk.ListStore(1, typeof(string));
		completion.set_model(this.completion_store);
		completion.set_text_column(0);
		completion.set_inline_completion(true);
		completion.set_popup_completion(true);
		
		completion.match_selected.connect(() => {
			stdout.printf("MATCH\n");
			return true;
		});
		
		this.time_entry.set_completion(completion);
		
		content_area.show_all();
	}
	
	public void time_entry_text_inserted(string new_text, int new_text_length, void* position) {
		bool valid = false;
		
		string text = this.time_entry.get_text();
		string[] text_parts = text.split(" ");
		
		if (text_parts.length > 1) {
			// should be entering a unit at this point
			/*
			Gtk.TreeIter iter;
			bool iter_valid = this.completion_store.get_iter_first(out iter);
			if (! iter_valid) valid = true;
			while (iter_valid) {
				string completion;
				this.completion_store.get(iter, 0, out completion, -1);
				if (completion != null && completion.contains(new_text)) {
					valid = true;
				}
			}
			*/
			valid = true;
		} else {
			// should be entering a number
			/*
			if (Regex.match_simple("[\\d\\s]", new_text)) {
				valid = true;
			} else {
				valid = false;
			}
			*/
			valid = true;
		}
		
		if (! valid) Signal.stop_emission_by_name(this.time_entry, "insert-text");
	}
	
	string? last_time_entered = "";
	public void time_entry_changed() {
		string text = this.time_entry.get_text();
		string[] text_parts = text.split(" ");
		
		int time = 1;
		if (text_parts.length > 0) {
			time = int.parse(text_parts[0]);
		}
		
		string[] completions = NaturalTime.get_completions_for_time(time);
		
		Gtk.TreeIter iter;
		bool iter_valid = this.completion_store.get_iter_first(out iter);
		if (!iter_valid) {
			this.completion_store.append(out iter);
			iter_valid = true;
		}
		
		foreach (string completion in completions) {
			this.completion_store.set(iter, 0, completion, -1);
			
			iter_valid = this.completion_store.iter_next(ref iter);
			if (!iter_valid) {
				this.completion_store.append(out iter);
				iter_valid = true;
			}
		}
		this.last_time_entered = text;
	}
	
	public void submit() {
		this.time_entered(60);
		this.destroy();
	}
}

