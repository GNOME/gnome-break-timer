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

// GLib's TestSuite and TestCase are compact classes, so we wrap them in real GLib.Objects for convenience
// This base code is partly borrowed from libgee's test suite, at https://git.gnome.org/browse/libgee

public abstract class SimpleTestSuite : Object {
	private GLib.TestSuite g_test_suite;
	private Adaptor[] adaptors = new Adaptor[0];

	private class Adaptor {
		private SimpleTestSuite test_suite;
		private SimpleTestCase<SimpleTestSuite> test;

		public Adaptor(SimpleTestSuite test_suite, owned SimpleTestCase<SimpleTestSuite> test) {
			this.test_suite = test_suite;
			this.test = (owned)test;
		}

		private string get_short_name() {
			string base_name = this.test_suite.get_name();
			string test_full_name = this.test.get_name();
			if (test_full_name.has_prefix(base_name)) {
				return test_full_name.splice(0, base_name.length);
			} else {
				return test_full_name;
			}
		}

		private void setup(void *fixture) {
			this.test_suite.setup();
		}

		private void run(void *fixture) {
			this.test.run(this.test_suite);
		}

		private void teardown(void *fixture) {
			this.test_suite.teardown();
		}

		public GLib.TestCase get_g_test_case() {
			return new GLib.TestCase(
				this.get_short_name(),
				(TestFixtureFunc)this.setup,
				(TestFixtureFunc)this.run,
				(TestFixtureFunc)this.teardown
			);
		}
	}

	public SimpleTestSuite() {
		var name = this.get_name();
		this.g_test_suite = new GLib.TestSuite(name);
	}

	public void add_to(GLib.TestSuite parent) {
		parent.add_suite(this.g_test_suite);
	}

	public GLib.TestSuite get_g_test_suite() {
		return this.g_test_suite;
	}

	public string get_name() {
		return this.get_type().name();
	}

	public void add_test(owned SimpleTestCase test) {
		var adaptor = new Adaptor(this, (owned)test);
		this.adaptors += adaptor;
		this.g_test_suite.add(adaptor.get_g_test_case());
	}

	public virtual void setup() {
		Environment.set_variable("GSETTINGS_BACKEND", "memory", true);
	}

	public virtual void teardown() {}
}

public interface SimpleTestCase<T> : Object {
	public abstract void run(T context);

	public void add_to(SimpleTestSuite test_suite) {
		test_suite.add_test(this);
	}

	public string get_name() {
		return this.get_type().name();
	}
}


// Special test suites suited for particular pieces of the application

public class TestSuiteWithActivityMonitor : SimpleTestSuite {
	public testable_ActivityMonitorBackend activity_monitor_backend;
	public testable_SessionStatus session_status;
	public ActivityMonitor activity_monitor;
	public Gee.List<ActivityMonitor.UserActivity?> activity_log;

	public const int START_REAL_TIME = 1000000;
	public const int START_MONOTONIC_TIME = 5;

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
	
	public override void teardown() {
		Util._override_real_time = -1;
		Util._override_monotonic_time = -1;
	}

	public void set_idle(int idle_seconds) {
		this.activity_monitor_backend.idle_seconds = idle_seconds;
	}

	public void advance_time(int real_seconds, int monotonic_seconds, bool with_idle=false) {
		Util._override_real_time += real_seconds;
		Util._override_monotonic_time += monotonic_seconds;
		if (with_idle) this.activity_monitor_backend.idle_seconds += real_seconds;
	}

	private void log_activity(ActivityMonitor.UserActivity activity) {
		this.activity_log.add(activity);
	}
}


// We also need special testable implementations of certain classes and interfaces

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
