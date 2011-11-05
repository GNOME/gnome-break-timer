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

public class TimeChooser : Gtk.ComboBox {
	private Gtk.ListStore list_store;
	
	private Gtk.TreeIter other_item;
	private Gtk.TreeIter? custom_item;
	
	private const int OPTION_OTHER = -1;
	
	private string title;
	
	public int time_seconds {get; set;}
	
	public signal void time_selected(int time);
	
	public TimeChooser(int[] options, string title) {
		Object();
		
		this.title = title;
		
		this.list_store = new Gtk.ListStore(3, typeof(string), typeof(string), typeof(int));
		
		this.set_model(this.list_store);
		this.set_id_column(1);
		
		Gtk.CellRendererText cell = new Gtk.CellRendererText();
		this.pack_start(cell, true);
		this.set_attributes(cell, "text", null);
		
		foreach (int time in options) {
			string label = NaturalTime.get_instance().get_label_for_seconds(time);
			this.add_option(label, time);
		}
		this.other_item = this.add_option(_("Other…"), OPTION_OTHER);
		this.custom_item = null;
		
		this.changed.connect(this.on_changed);
		
		this.notify["time-seconds"].connect((s, p) => {
			this.set_time(this.time_seconds);
		});
	}
	
	public bool set_time(int seconds) {
		string id = seconds.to_string();
		
		bool option_exists = this.set_active_id(id);
		
		if (!option_exists) {
			if (seconds > 0) {
				Gtk.TreeIter new_option = this.add_custom_option(seconds);
				this.set_active_iter(new_option);
				return true;
			} else {
				return false;
			}
		} else {
			return true;
		}
	}
	
	public int get_time() {
		return this.time_seconds;
	}
	
	private Gtk.TreeIter add_option(string label, int seconds) {
		string id = seconds.to_string();
		
		Gtk.TreeIter iter;
		this.list_store.append(out iter);
		this.list_store.set(iter, 0, label, 1, id, 2, seconds, -1);
		
		return iter;
	}
	
	private Gtk.TreeIter add_custom_option(int seconds) {
		string label = NaturalTime.get_instance().get_label_for_seconds(seconds);
		string id = seconds.to_string();
		
		if (this.custom_item == null) {
			this.list_store.append(out this.custom_item);
			this.list_store.set(this.custom_item, 0, label, 1, id, 2, seconds, -1);
			return this.custom_item;
		} else {
			this.list_store.set(this.custom_item, 0, label, 1, id, 2, seconds, -1);
			return this.custom_item;
		}
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
		} else if (val > 0) {
			this.time_seconds = val;
			this.time_selected(val);
		}
	}
	
	private void start_custom_input() {
		Gtk.Window? parent_window = (Gtk.Window)this.get_toplevel();
		if (! parent_window.is_toplevel()) {
			parent_window = null;
		}
		TimeEntryDialog dialog = new TimeEntryDialog(parent_window, this.title);
		dialog.time_entered.connect((time) => {
			bool success = this.set_time(time);
			if (! success) {
				this.set_time(this.time_seconds);
			}
		});
		dialog.cancelled.connect(() => {
			this.set_time(this.time_seconds);
		});
		dialog.present();
	}
}

private class TimeEntryDialog : Gtk.Dialog {
	private Gtk.Widget ok_button;
	private Gtk.Entry time_entry;
	//private Gtk.SpinButton time_spinner;
	
	private Gtk.ListStore completion_store;
	
	public signal void time_entered(int time_seconds);
	public signal void cancelled();
	
	public TimeEntryDialog(Gtk.Window? parent, string title) {
		Object();
		
		this.set_title(title);
		
		this.set_modal(true);
		this.set_resizable(false);
		this.set_destroy_with_parent(true);
		this.set_transient_for(parent);
		
		this.ok_button = this.add_button(Gtk.Stock.OK, Gtk.ResponseType.OK);
		this.response.connect((response_id) => {
			if (response_id == Gtk.ResponseType.OK) this.submit();
		});
		this.destroy.connect(() => {
			this.cancelled();
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
		this.time_entry.changed.connect(this.time_entry_changed);
		content_grid.attach(this.time_entry, 0, 1, 1, 1);
		
		/*
		Gtk.Adjustment time_spinner_adjustment = new Gtk.Adjustment(30, 1, 86400, 1, 60, 60);
		this.time_spinner = new Gtk.SpinButton(time_spinner_adjustment, 60, 0);
		this.time_spinner.output.connect(this.time_spinner_output);
		this.time_spinner.value_changed.connect(this.time_spinner_value_changed);
		content_grid.attach(this.time_spinner, 0, 2, 1, 1);
		*/
		
		Gtk.EntryCompletion completion = new Gtk.EntryCompletion();
		this.completion_store = new Gtk.ListStore(1, typeof(string));
		completion.set_model(this.completion_store);
		completion.set_text_column(0);
		completion.set_inline_completion(true);
		completion.set_popup_completion(true);
		completion.set_popup_single_match(false);
		
		this.time_entry.set_completion(completion);
		
		this.validate_input();
		
		content_area.show_all();
	}
	
	private void validate_input() {
		string text = this.time_entry.get_text();
		
		bool valid = NaturalTime.get_instance().get_instance().get_seconds_for_input(text) > 0;
		
		this.set_response_sensitive(Gtk.ResponseType.OK, valid);
	}
	
	private void time_entry_changed() {
		string text = this.time_entry.get_text();
		string[] completions = NaturalTime.get_instance().get_completions_for_input(text);
		
		// replace completion options without deleting rows
		// if we delete rows, gtk throws some unhappy error messages
		Gtk.TreeIter iter;
		bool iter_valid = this.completion_store.get_iter_first(out iter);
		if (!iter_valid) this.completion_store.append(out iter);
		
		foreach (string completion in completions) {
			this.completion_store.set(iter, 0, completion, -1);
			
			iter_valid = this.completion_store.iter_next(ref iter);
			if (!iter_valid) this.completion_store.append(out iter);
		}
		
		this.validate_input();
	}
	
	/*
	private bool time_spinner_output() {
		Gtk.Adjustment adjustment = this.time_spinner.get_adjustment();
		int seconds = (int)adjustment.get_value();
		string label = NaturalTime.get_instance().get_label_for_seconds(seconds);
		this.time_spinner.set_text(label);
		
		return true;
	}
	
	private void time_spinner_value_changed() {
		Gtk.Adjustment adjustment = this.time_spinner.get_adjustment();
		int seconds = (int)adjustment.get_value();
		if (seconds >= 3600) {
			this.time_spinner.set_increments(3600, 1);
		} else if (seconds >= 60) {
			this.time_spinner.set_increments(60, 1);
		} else {
			this.time_spinner.set_increments(1, 1);
		}
	}
	*/
	
	private void submit() {
		int time = NaturalTime.get_instance().get_seconds_for_input(this.time_entry.get_text());
		if (time > 0) {
			this.time_entered(time);
			this.destroy();
		} else {
			Gdk.beep();
		}
	}
}

