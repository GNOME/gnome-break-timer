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

public class test_TimerBreakController : TestSuiteWithActivityMonitor {
	public const int DEFAULT_INTERVAL = 360;
	public const int DEFAULT_DURATION = 30;

	public testable_TimerBreakController break_controller;
	public Gee.List<string> break_log;
	public Gee.List<string> break_timestep_log;

	public test_TimerBreakController() {
		new test_start_disabled().add_to(this);
		new test_enable_and_idle().add_to(this);
		new test_enable_and_active().add_to(this);
		new test_force_activate().add_to(this);
		new test_postpone().add_to(this);
	}

	public override void setup() {
		base.setup();

		this.break_log = new Gee.ArrayList<string>();
		this.break_timestep_log = new Gee.ArrayList<string>();

		this.break_controller = new testable_TimerBreakController(this.activity_monitor);
		this.break_controller.interval = DEFAULT_INTERVAL;
		this.break_controller.duration = DEFAULT_DURATION;

		this.break_controller.enabled.connect(() => { this.log_break_message("enabled"); } );
		this.break_controller.disabled.connect(() => { this.log_break_message("disabled"); } );
		this.break_controller.warned.connect(() => { this.log_break_message("warned"); } );
		this.break_controller.unwarned.connect(() => { this.log_break_message("unwarned"); } );
		this.break_controller.activated.connect(() => { this.log_break_message("activated"); } );
		this.break_controller.finished.connect(() => { this.log_break_message("finished"); } );

		this.break_controller.counting.connect(() => { this.log_break_message("counting"); } );
		this.break_controller.delayed.connect(() => { this.log_break_message("delayed"); } );
	}

	private void log_break_message(string message) {
		this.break_log.add(message);
		this.break_timestep_log.add(message);
	}

	public override void time_step(bool is_active, int real_seconds, int monotonic_seconds) {
		this.break_timestep_log.clear();
		base.time_step(is_active, real_seconds, monotonic_seconds);
		this.break_controller.time_step(real_seconds, monotonic_seconds);
	}
}

public class testable_TimerBreakController : TimerBreakController {
	public testable_TimerBreakController(ActivityMonitor activity_monitor) {
		base(activity_monitor);
	}

	public void time_step(int real_seconds, int monotonic_seconds) {
		this.countdowns_timeout.run_once();
	}

	public void assert_timers(int? starts_in, int? remaining) {
		if (starts_in != null) assert(this.starts_in() == starts_in);
		if (remaining != null) assert(this.get_time_remaining() == remaining);
	}
}

class test_start_disabled : Object, SimpleTestCase<test_TimerBreakController> {
	public void run(test_TimerBreakController context) {
		assert(context.break_controller.is_enabled() == false);
		assert(context.break_controller.is_active() == false);
		assert(context.break_controller.get_seconds_since_start() == 0);

		context.break_controller.activate();

		assert(context.break_controller.is_enabled() == false);
		assert(context.break_log.size == 0);
	}
}

class test_enable_and_idle : Object, SimpleTestCase<test_TimerBreakController> {
	public void run(test_TimerBreakController context) {
		context.break_controller.set_enabled(true);
		assert(context.break_log.last() == "enabled");

		int expected_starts_in = test_TimerBreakController.DEFAULT_INTERVAL;
		int expected_remaining = test_TimerBreakController.DEFAULT_DURATION;

		context.time_step(true, 1, 1);
		expected_starts_in -= 1;
		context.break_controller.assert_timers(expected_starts_in, expected_remaining);

		for (int step = 0; step <= test_TimerBreakController.DEFAULT_DURATION; step++) {
			context.time_step(false, 1, 1);
			assert(context.break_timestep_log[0] == "counting");
			if (step == test_TimerBreakController.DEFAULT_DURATION) {
				assert(context.break_timestep_log[1] == "finished");
			}
		}
		expected_starts_in = test_TimerBreakController.DEFAULT_INTERVAL;
		expected_remaining = test_TimerBreakController.DEFAULT_DURATION;
		context.break_controller.assert_timers(expected_starts_in, expected_remaining);

		for (int step = 0; step < test_TimerBreakController.DEFAULT_INTERVAL; step++) {
			context.time_step(false, 1, 1);
			assert(context.break_timestep_log[0] == "counting");	
		}
		context.break_controller.assert_timers(expected_starts_in, expected_remaining);
	}
}

class test_enable_and_active : Object, SimpleTestCase<test_TimerBreakController> {
	public void run(test_TimerBreakController context) {
		context.break_controller.set_enabled(true);

		int expected_starts_in = test_TimerBreakController.DEFAULT_INTERVAL;
		int expected_remaining = test_TimerBreakController.DEFAULT_DURATION;

		var active_time_1 = 20;
		for (int step = 0; step < active_time_1; step++) {
			context.time_step(true, 1, 1);
			assert(context.break_timestep_log[0] == "delayed");
		}
		expected_starts_in -= active_time_1;
		context.break_controller.assert_timers(expected_starts_in, expected_remaining);

		var idle_time_1 = 10;
		for (int step = 0; step < idle_time_1+1; step++) {
			context.time_step(false, 1, 1);
			assert(context.break_timestep_log[0] == "counting");
		}
		expected_starts_in -= 1;
		expected_remaining -= idle_time_1;
		context.break_controller.assert_timers(expected_starts_in, expected_remaining);

		var active_time_2 = test_TimerBreakController.DEFAULT_INTERVAL - active_time_1;
		var warn_step = active_time_2 - test_TimerBreakController.DEFAULT_DURATION - 1;
		for (int step = 0; step < active_time_2; step++) {
			context.time_step(true, 1, 1);
			assert(context.break_timestep_log[0] == "delayed");
			if (step == warn_step) {
				assert(context.break_timestep_log[1] == "warned");
			} else if (step == active_time_2-1) {
				assert(context.break_timestep_log[1] == "activated");
			}
		}
		expected_starts_in = 0;
		expected_remaining -= 1;
		context.break_controller.assert_timers(expected_starts_in, expected_remaining);

		for (int step = 0; step < 5; step++) {
			context.time_step(false, 1, 1);
			assert(context.break_timestep_log[0] == "counting");
		}
		expected_remaining -= 5;
		context.break_controller.assert_timers(expected_starts_in, expected_remaining);

		for (int step = 0; step < expected_remaining; step++) {
			context.time_step(false, 1, 1);
			assert(context.break_timestep_log[0] == "counting");
			if (step == expected_remaining-1) {
				assert(context.break_timestep_log[1] == "finished");
			}
		}
		expected_starts_in = test_TimerBreakController.DEFAULT_INTERVAL;
		expected_remaining = test_TimerBreakController.DEFAULT_DURATION;
		context.break_controller.assert_timers(expected_starts_in, expected_remaining);
	}
}

class test_force_activate : Object, SimpleTestCase<test_TimerBreakController> {
	public void run(test_TimerBreakController context) {
		context.break_controller.set_enabled(true);

		int expected_starts_in = test_TimerBreakController.DEFAULT_INTERVAL;
		int expected_remaining = test_TimerBreakController.DEFAULT_DURATION;

		context.break_controller.activate();
		assert(context.break_log.last() == "activated");

		assert(context.break_controller.get_seconds_since_start() == 0);
		context.break_controller.assert_timers(null, expected_remaining);

		for (int step = 0; step < 10; step++) {
			context.time_step(false, 1, 1);
		}
		expected_remaining -= 10;
		context.break_controller.assert_timers(null, expected_remaining);
	}
}

class test_postpone : Object, SimpleTestCase<test_TimerBreakController> {
	public void run(test_TimerBreakController context) {
		context.break_controller.set_enabled(true);

		int expected_starts_in = test_TimerBreakController.DEFAULT_INTERVAL;
		int expected_remaining = test_TimerBreakController.DEFAULT_DURATION;

		context.break_controller.activate();
		for (int step = 0; step < 10; step++) {
			context.time_step(false, 1, 1);
		}
		expected_remaining -= 10;
		context.break_controller.assert_timers(null, expected_remaining);
		assert(context.break_controller.get_seconds_since_start() == 10);

		context.break_controller.postpone(60);
		expected_starts_in = 60;
		expected_remaining = test_TimerBreakController.DEFAULT_DURATION;
		assert(context.break_controller.is_active() == false);
		context.break_controller.assert_timers(expected_starts_in, expected_remaining);

		for (int step = 0; step < expected_starts_in; step++) {
			context.time_step(true, 1, 1);
			if (step == expected_starts_in-1) {
				assert(context.break_timestep_log[1] == "activated");
			}
		}
		expected_starts_in = 0;
		expected_remaining = test_TimerBreakController.DEFAULT_DURATION;
		assert(context.break_controller.is_active() == true);
		context.break_controller.assert_timers(expected_starts_in, expected_remaining);
	}
}
