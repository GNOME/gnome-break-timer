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

using GLib;
using Gdk;
using Notify;

public class BrainBreak : Gtk.Application {
	const string app_id = "com.dylanmccall.BrainBreak";
	const string app_name = "Brain Break"; /* TODO: translate */
	
	private FocusManager focus_manager;
	private RestBreak rest_break;
	private MicroBreak micro_break;
	
	private BreakViewCommon break_view_common;
	private RestBreakView rest_break_view;
	private MicroBreakView micro_break_view;
	
	public BrainBreak() {
		Object(application_id: app_id, flags: ApplicationFlags.FLAGS_NONE);
		GLib.Environment.set_application_name(app_name);
	}
	
	public override void activate() {
	}
	
	public override void startup() {
		this.hold(); /* we're doing stuff, even if no windows are open */
		
		Magic.begin();
		Notify.init(app_name);
		
		/* set up custom gtk style for application */
		Gdk.Screen screen = Gdk.Screen.get_default();
		Gtk.CssProvider style_provider = new Gtk.CssProvider();
		/* FIXME: of course, we should load data files in a smarter way */
		style_provider.load_from_path("data/style.css");
		Gtk.StyleContext.add_provider_for_screen(screen,
		                                         style_provider,
		                                         Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
		
		this.focus_manager = new FocusManager();
		this.rest_break = new RestBreak(this.focus_manager);
		this.micro_break = new MicroBreak(this.focus_manager);
		
		this.break_view_common = new BreakViewCommon();
		this.micro_break_view = new MicroBreakView(this.break_view_common, this.micro_break);
		this.rest_break_view = new RestBreakView(this.break_view_common, this.rest_break);
	}
}
