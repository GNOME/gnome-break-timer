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

		for (int step = 0; step < test_TimerBreakController.DEFAULT_DURATION; step++) {
			context.time_step(false, 1, 1);
			assert(context.break_timestep_log.last() == "counting");	
		}
		context.time_step(false, 1, 1);
		assert(context.break_timestep_log.last() == "finished");

		for (int step = 0; step < test_TimerBreakController.DEFAULT_DURATION; step++) {
			context.time_step(false, 1, 1);
			assert(context.break_timestep_log.last() == "counting");			
		}
		assert(context.break_controller.starts_in() == test_TimerBreakController.DEFAULT_INTERVAL);
		assert(context.break_controller.get_time_remaining() == test_TimerBreakController.DEFAULT_DURATION);
	}
}

class test_enable_and_active : Object, SimpleTestCase<test_TimerBreakController> {
	public void run(test_TimerBreakController context) {
		context.break_controller.set_enabled(true);
		assert(context.break_log[0] == "enabled");

		var active_time_1 = 20;
		for (int step = 0; step < active_time_1; step++) {
			context.time_step(true, 1, 1);
			assert(context.break_timestep_log.last() == "delayed");
		}
		assert(context.break_controller.starts_in() == test_TimerBreakController.DEFAULT_INTERVAL - active_time_1);
		assert(context.break_controller.get_time_remaining() == test_TimerBreakController.DEFAULT_DURATION);

		var idle_time_1 = 10;
		for (int step = 0; step < idle_time_1+1; step++) {
			context.time_step(false, 1, 1);
			assert(context.break_timestep_log.last() == "counting");	
		}
		assert(context.break_controller.starts_in() == test_TimerBreakController.DEFAULT_INTERVAL - active_time_1 - 1);
		assert(context.break_controller.get_time_remaining() == test_TimerBreakController.DEFAULT_DURATION - idle_time_1);

		var active_time_2 = test_TimerBreakController.DEFAULT_INTERVAL - active_time_1;
		var warn_step = active_time_2 - test_TimerBreakController.DEFAULT_DURATION - 1;
		for (int step = 0; step < active_time_2 - 1; step++) {
			context.time_step(true, 1, 1);
			assert(context.break_timestep_log[0] == "delayed");
			if (step == warn_step) {
				assert(context.break_timestep_log[1] == "warned");
			}
		}
		context.time_step(true, 1, 1);
		assert(context.break_timestep_log.last() == "activated");
	}
}

