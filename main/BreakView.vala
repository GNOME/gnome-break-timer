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

abstract class BreakView {
	protected BreakViewCommon common {get; private set;}
	protected Break break_scheduler {get; private set;}
	
	public BreakView(BreakViewCommon common, Break break_scheduler) {
		this.common = common;
		this.break_scheduler = break_scheduler;
		
		break_scheduler.started.connect(this.break_started_cb);
		break_scheduler.finished.connect(this.break_finished_cb);
	}
	
	protected abstract void show_break_ui();
	protected abstract void hide_break_ui();
	
	protected bool break_is_active() {
		return break_scheduler.state == Break.State.ACTIVE;
	}
	
	private void break_started_cb() {
		this.show_break_ui();
	}
	
	private void break_finished_cb() {
		this.hide_break_ui();
	}
}

