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

/**
 * A type of timer break that should activate frequently and for short
 * durations. Satisfied when the user is inactive for its entire duration,
 * and when it is active it restarts its countdown whenever the user types
 * or moves the mouse.
 */
public class MicroBreak : ActivityTimerBreak {
	public MicroBreak(FocusManager focus_manager) {
		Settings settings = new Settings("org.brainbreak.breaks.microbreak");
		
		base(focus_manager, FocusPriority.LOW, settings);	
	}
	
	protected override BreakView make_view() {
		BreakView break_view = new MicroBreakView(this);
		return break_view;
	}
	
	protected override void active_nice() {
		this.duration_countdown.continue();
	}
	
	protected override void active_naughty() {
		this.duration_countdown.start();
	}
}

