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
public class MicroBreakController : TimerBreakController {
	private ActivityMonitor activity_monitor;
	
	public MicroBreakController(BreakType break_type, Settings settings, IActivityMonitorBackend activity_monitor_backend) {
		base(break_type, settings);
		this.activity_monitor = new ActivityMonitor(activity_monitor_backend);
	}

	protected override void waiting_timeout_cb(PausableTimeout timeout, int delta_millisecs) {
		ActivityMonitor.UserActivity activity = this.activity_monitor.get_activity();
		this.update_waiting_countdowns_for_activity(activity);
		base.waiting_timeout_cb(timeout, delta_millisecs);
	}
	
	protected override void active_timeout_cb(PausableTimeout timeout, int delta_millisecs) {
		ActivityMonitor.UserActivity activity = this.activity_monitor.get_activity();
		bool is_delayed = this.update_active_countdowns_for_activity(activity, 0);
		if (is_delayed) {
			this.duration_countdown.reset();
		}
		base.active_timeout_cb(timeout, delta_millisecs);
	}
}

