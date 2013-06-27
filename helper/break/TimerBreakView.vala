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
	protected TimerBreakController timer_break {
		get {return (TimerBreakController)this.break_controller; }
	}
	
	public TimerBreakView(BreakType break_type, TimerBreakController timer_break, UIManager ui_manager) {
		base(break_type, timer_break, ui_manager);
	}
	
	public override string get_status_message() {
		string message;
		
		int starts_in = this.timer_break.starts_in();
		int time_remaining = this.timer_break.get_time_remaining();
		string state_label = this.timer_break.state.to_string();
		
		message = "%s, I:%d, D:%d".printf(state_label, starts_in, time_remaining);
		
		return message;
	}
	
	protected int get_lead_in_seconds() {
		int lead_in = this.timer_break.duration+3;
		if (lead_in > 40) {
			lead_in = 40;
		} else if (lead_in < 15) {
			lead_in = 15;
		}
		return lead_in;
	}
}

