/*
 * This file is part of GNOME Break Timer.
 * 
 * GNOME Break Timer is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * GNOME Break Timer is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with GNOME Break Timer.  If not, see <http://www.gnu.org/licenses/>.
 */

public class test_ActivityMonitor : SimpleTestSuite {
	public testable_ActivityMonitorBackend activity_monitor_backend;
	public testable_SessionStatus session_status;
	public ActivityMonitor activity_monitor;
	public Gee.List<ActivityMonitor.UserActivity?> activity_log;

	public const int START_REAL_TIME = 1000000;
	public const int START_MONOTONIC_TIME = 5;

	public test_ActivityMonitor() {
		new test_simple_idle().add_to(this);
		new test_simple_active().add_to(this);
		new test_lock_idle().add_to(this);
		new test_active_then_idle().add_to(this);
		new test_sleep_and_unlock().add_to(this);
		new test_unlock_signal_activity().add_to(this);
	}

	public override void setup() {
		Util._override_real_time = START_REAL_TIME;
		Util._override_monotonic_time = START_MONOTONIC_TIME;

		this.activity_log = new Gee.ArrayList<ActivityMonitor.UserActivity?>();
		this.activity_monitor_backend = new testable_ActivityMonitorBackend();
		this.session_status = new testable_SessionStatus();
		this.activity_monitor = new ActivityMonitor(session_status, activity_monitor_backend);
		this.activity_monitor.detected_idle.connect(this.log_activity);
		this.activity_monitor.detected_activity.connect(this.log_activity);
		this.activity_monitor.stop();
	}

	internal void set_idle(int idle_seconds) {
		this.activity_monitor_backend.idle_seconds = idle_seconds;
	}

	internal void advance_time(int real_seconds, int monotonic_seconds, bool with_idle=false) {
		Util._override_real_time += real_seconds;
		Util._override_monotonic_time += monotonic_seconds;
		if (with_idle) this.activity_monitor_backend.idle_seconds += real_seconds;
	}

	private void log_activity(ActivityMonitor.UserActivity activity) {
		this.activity_log.add(activity);
	}
}

public class testable_ActivityMonitorBackend : Object, IActivityMonitorBackend {
	public int idle_seconds = 0;

	public int get_idle_seconds() {
		return this.idle_seconds;
	}
}

public class testable_SessionStatus : Object, ISessionStatus {
	public bool virt_is_locked = false;

	public void do_lock() {
		this.virt_is_locked = true;
		this.locked();
	}

	public void do_unlock() {
		this.virt_is_locked = false;
		this.unlocked();
	}

	public bool is_locked() {
		return this.virt_is_locked;
	}

	public void lock_screen() {
		this.virt_is_locked = true;
	}

	public void blank_screen() {}

	public void unblank_screen() {}
}

class test_simple_idle : Object, SimpleTestCase<test_ActivityMonitor> {
	public void run(test_ActivityMonitor context) {
		context.session_status.virt_is_locked = false;
		context.set_idle(1);
		context.advance_time(0, 0);
		context.activity_monitor.poll_activity();

		context.advance_time(1, 1, true);
		context.activity_monitor.poll_activity();

		assert(context.activity_log.size == 2);

		assert(context.activity_log[0].type == ActivityMonitor.ActivityType.NONE);
		assert(context.activity_log[0].is_active() == false);
		assert(context.activity_log[0].idle_time == 1);

		assert(context.activity_log[1].type == ActivityMonitor.ActivityType.NONE);
		assert(context.activity_log[1].is_active() == false);
		assert(context.activity_log[1].idle_time == 2);
	}
}

class test_simple_active : Object, SimpleTestCase<test_ActivityMonitor> {
	public void run(test_ActivityMonitor context) {
		context.session_status.virt_is_locked = false;
		context.set_idle(0);
		context.advance_time(0, 0);
		context.activity_monitor.poll_activity();

		context.set_idle(0);
		context.advance_time(1, 1);
		context.activity_monitor.poll_activity();

		context.set_idle(0);
		context.advance_time(1, 1);
		context.activity_monitor.poll_activity();

		assert(context.activity_log.size == 3);

		assert(context.activity_log[0].type == ActivityMonitor.ActivityType.INPUT);
		assert(context.activity_log[0].is_active() == true);
		assert(context.activity_log[0].idle_time == 0);

		assert(context.activity_log[1].type == ActivityMonitor.ActivityType.INPUT);
		assert(context.activity_log[1].is_active() == true);
		assert(context.activity_log[1].idle_time == 0);

		assert(context.activity_log[2].type == ActivityMonitor.ActivityType.INPUT);
		assert(context.activity_log[2].is_active() == true);
		assert(context.activity_log[2].idle_time == 0);
	}
}

class test_active_then_idle : Object, SimpleTestCase<test_ActivityMonitor> {
	public void run(test_ActivityMonitor context) {
		context.session_status.virt_is_locked = false;
		context.set_idle(0);
		context.advance_time(1, 1);
		context.activity_monitor.poll_activity();

		context.advance_time(1, 1, true);
		context.activity_monitor.poll_activity();

		context.advance_time(1, 1, true);
		context.activity_monitor.poll_activity();

		context.set_idle(0);
		context.advance_time(1, 1);
		context.activity_monitor.poll_activity();

		context.set_idle(0);
		context.advance_time(1, 1);
		context.activity_monitor.poll_activity();

		assert(context.activity_log.size == 5);

		assert(context.activity_log[0].type == ActivityMonitor.ActivityType.INPUT);
		assert(context.activity_log[0].is_active() == true);
		assert(context.activity_log[0].idle_time == 0);

		assert(context.activity_log[1].type == ActivityMonitor.ActivityType.NONE);
		assert(context.activity_log[1].is_active() == false);
		assert(context.activity_log[1].idle_time == 1);
		assert(context.activity_log[1].time_since_active == 1);

		assert(context.activity_log[2].type == ActivityMonitor.ActivityType.NONE);
		assert(context.activity_log[2].is_active() == false);
		assert(context.activity_log[2].idle_time == 2);
		assert(context.activity_log[2].time_since_active == 2);

		assert(context.activity_log[3].type == ActivityMonitor.ActivityType.INPUT);
		assert(context.activity_log[3].is_active() == true);
		assert(context.activity_log[3].idle_time == 0);
		assert(context.activity_log[3].time_since_active == 3);

		assert(context.activity_log[4].type == ActivityMonitor.ActivityType.INPUT);
		assert(context.activity_log[4].is_active() == true);
		assert(context.activity_log[4].idle_time == 0);
		assert(context.activity_log[4].time_since_active == 1);
	}
}

class test_lock_idle : Object, SimpleTestCase<test_ActivityMonitor> {
	public void run(test_ActivityMonitor context) {
		context.session_status.virt_is_locked = true;
		context.set_idle(0);
		context.advance_time(1, 1);
		context.activity_monitor.poll_activity();

		context.set_idle(0);
		context.advance_time(1, 1);
		context.activity_monitor.poll_activity();

		context.advance_time(1, 1, true);
		context.activity_monitor.poll_activity();

		assert(context.activity_log.size == 3);

		assert(context.activity_log[0].type == ActivityMonitor.ActivityType.LOCKED);
		assert(context.activity_log[0].is_active() == false);
		assert(context.activity_log[0].idle_time == 0);

		assert(context.activity_log[1].type == ActivityMonitor.ActivityType.LOCKED);
		assert(context.activity_log[1].is_active() == false);
		assert(context.activity_log[1].idle_time == 0);

		assert(context.activity_log[2].type == ActivityMonitor.ActivityType.LOCKED);
		assert(context.activity_log[2].is_active() == false);
		assert(context.activity_log[2].idle_time == 1);
	}
}

class test_sleep_and_unlock : Object, SimpleTestCase<test_ActivityMonitor> {
	public void run(test_ActivityMonitor context) {
		context.session_status.virt_is_locked = false;
		context.set_idle(0);
		context.advance_time(1, 1);
		context.activity_monitor.poll_activity();

		context.session_status.virt_is_locked = true;
		context.set_idle(0);
		context.advance_time(120, 2);
		context.activity_monitor.poll_activity();

		context.set_idle(0);
		context.advance_time(1, 1);
		context.activity_monitor.poll_activity();

		context.session_status.virt_is_locked = false;
		context.set_idle(0);
		context.advance_time(1, 1);
		context.activity_monitor.poll_activity();

		assert(context.activity_log.size == 4);

		assert(context.activity_log[0].type == ActivityMonitor.ActivityType.INPUT);
		assert(context.activity_log[0].is_active() == true);
		assert(context.activity_log[0].idle_time == 0);
		assert(context.activity_log[0].time_correction == 0);

		assert(context.activity_log[1].type == ActivityMonitor.ActivityType.SLEEP);
		assert(context.activity_log[1].is_active() == false);
		assert(context.activity_log[1].time_since_active == 120);
		assert(context.activity_log[1].idle_time == 0);
		assert(context.activity_log[1].time_correction == 120-2);

		assert(context.activity_log[2].type == ActivityMonitor.ActivityType.LOCKED);
		assert(context.activity_log[2].is_active() == false);
		assert(context.activity_log[2].idle_time == 0);
		assert(context.activity_log[2].time_correction == 0);

		assert(context.activity_log[3].type == ActivityMonitor.ActivityType.INPUT);
		assert(context.activity_log[3].is_active() == true);
		assert(context.activity_log[3].idle_time == 0);
		assert(context.activity_log[3].time_correction == 0);
	}
}

class test_unlock_signal_activity : Object, SimpleTestCase<test_ActivityMonitor> {
	public void run(test_ActivityMonitor context) {
		context.session_status.virt_is_locked = true;
		context.set_idle(0);
		context.advance_time(1, 1);
		context.activity_monitor.poll_activity();

		context.session_status.do_unlock();

		assert(context.activity_log.size == 2);

		assert(context.activity_log[0].type == ActivityMonitor.ActivityType.LOCKED);
		assert(context.activity_log[0].is_active() == false);
		assert(context.activity_log[0].idle_time == 0);

		assert(context.activity_log[1].type == ActivityMonitor.ActivityType.UNLOCK);
		assert(context.activity_log[1].is_active() == true);
		assert(context.activity_log[1].idle_time == 0);
	}
}
