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

public abstract class Panel : Gtk.Grid {
	private Gtk.Grid header;
	private Gtk.Grid content;
	
	public Panel() {
		Object();
		
		this.set_orientation(Gtk.Orientation.VERTICAL);
		this.set_row_spacing(12);
		
		this.header = new Gtk.Grid();
		this.header.set_orientation(Gtk.Orientation.HORIZONTAL);
		this.header.set_column_spacing(12);
		this.add(header);
		
		this.content = new Gtk.Grid();
		this.content.set_orientation(Gtk.Orientation.HORIZONTAL);
		this.content.set_column_spacing(6);
		this.content.set_margin_left(12);
		this.add(this.content);
		
		this.show_all();
	}
	
	public virtual Gtk.Container get_header() {
		return this.header;
	}
	
	public virtual Gtk.Container get_content() {
		return this.content;
	}
}

