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

public abstract class TimerBreakView : BreakView {
	protected TimerBreakModel timer_break;
	
	protected TimerBreakStatusWidget status_widget;
	
	public TimerBreakView(TimerBreakModel timer_break, FocusPriority priority) {
		base(timer_break, priority);
		
		this.timer_break = timer_break;
		
		this.status_widget = new TimerBreakStatusWidget();
		
		this.overlay_started.connect(this.overlay_started_cb);
		
		timer_break.warned.connect(this.timer_break_warned_cb);
		timer_break.unwarned.connect(this.timer_break_unwarned_cb);
		
		timer_break.active_countdown_changed.connect(this.active_countdown_changed_cb);
		timer_break.attention_demanded.connect(this.attention_demanded_cb);
	}

	protected abstract string get_countdown_label(int time_remaining, int start_time);
	
	private void overlay_started_cb() {
		this.active_countdown_changed_cb( this.timer_break.get_time_remaining() );
	}
	
	private void timer_break_warned_cb() {
		this.request_focus();
	}
	
	private void timer_break_unwarned_cb() {
		this.release_focus();
	}
	
	private void active_countdown_changed_cb(int time_remaining) {
		int start_time = this.timer_break.get_current_duration();
		string countdown = this.get_countdown_label(time_remaining, start_time);
		this.status_widget.set_time( countdown );
	}
	
	private void attention_demanded_cb() {
		this.request_attention();
	}
	
	public override string get_status_message() {
		string message;
		
		int starts_in = this.timer_break.starts_in();
		int time_remaining = this.timer_break.get_time_remaining();
		string state_label = this.timer_break.state.to_string();
		
		message = "%s, I:%d, D:%d".printf(state_label, starts_in, time_remaining);
		
		return message;
	}
	
	public override int get_lead_in_seconds() {
		int lead_in = this.timer_break.duration+3;
		if (lead_in > 40) {
			lead_in = 40;
		} else if (lead_in < 15) {
			lead_in = 15;
		}
		return lead_in;
	}
	
	public override Gtk.Widget get_overlay_content() {
		return this.status_widget;
	}
}

