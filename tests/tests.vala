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
	}

	public virtual void teardown() {
	}
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


class TestRunner : Object {
	private GLib.TestSuite root_suite;

	private File tmp_dir;
	const string SCHEMA_FILE_NAME = "org.gnome.break-timer.gschema.xml";

	public TestRunner(ref unowned string[] args, GLib.TestSuite? root_suite = null) {
		GLib.Test.init(ref args);
		if (root_suite == null) {
			this.root_suite = GLib.TestSuite.get_root();
		} else {
			this.root_suite = root_suite;
		}
	}

	public void add(SimpleTestSuite suite) {
		suite.add_to(this.root_suite);
	}

	public virtual void global_setup() {
		try {
			var tmp_path = DirUtils.make_tmp("gnome-break-timer-test-XXXXXX");
			tmp_dir = File.new_for_path(tmp_path);
		} catch (Error e) {
			GLib.warning("Error creating temporary directory for test files: %s".printf(e.message));
		}

		string target_data_path = Path.build_filename(tmp_dir.get_path(), "share");
		string target_schema_path = Path.build_filename(tmp_dir.get_path(), "share", "glib-2.0", "schemas");

		Environment.set_variable("GSETTINGS_BACKEND", "memory", true);

		var original_data_dirs = Environment.get_variable("XDG_DATA_DIRS");
		Environment.set_variable("XDG_DATA_DIRS", "%s:%s".printf(target_data_path, original_data_dirs), true);

		File source_schema_file = File.new_for_path(
			Path.build_filename(get_top_builddir(), "data", SCHEMA_FILE_NAME)
		);

		File target_schema_dir = File.new_for_path(target_schema_path);
		target_schema_dir.make_directory_with_parents();

		File target_schema_file = File.new_for_path(
			Path.build_filename(target_schema_dir.get_path(), SCHEMA_FILE_NAME)
		);

		try {
			source_schema_file.copy(target_schema_file, FileCopyFlags.OVERWRITE);
		} catch (Error e) {
			GLib.warning("Error copying schema file: %s", e.message);
		}

		int compile_schemas_result = Posix.system("glib-compile-schemas %s".printf(target_schema_path));
		if (compile_schemas_result != 0) {
			GLib.warning("Could not compile schemas in %s", target_schema_path);
		}
	}

	public virtual void global_teardown() {
		if (tmp_dir != null) {
			int delete_tmp_result = Posix.system("rm -rf %s".printf(tmp_dir.get_path()));
		}
	}

	public int run() {
		this.global_setup();
		GLib.Test.run();
		this.global_teardown();
		return 0;
	}

	private static string get_top_builddir() {
		var builddir = Environment.get_variable("top_builddir");
		if (builddir == null) builddir = "..";
		return builddir;
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
		base.setup();

		Util._override_real_time = START_REAL_TIME;
		Util._override_monotonic_time = START_MONOTONIC_TIME;

		this.activity_log = new Gee.ArrayList<ActivityMonitor.UserActivity?>();
		this.activity_monitor_backend = new testable_ActivityMonitorBackend();
		this.activity_monitor_backend.idle_seconds = START_MONOTONIC_TIME;
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

	private const int MICROSECONDS_IN_SECONDS = 1000 * 1000;

	public virtual void time_step(bool is_active, int real_seconds, int monotonic_seconds) {
		Util._override_real_time += real_seconds * MICROSECONDS_IN_SECONDS;
		Util._override_monotonic_time += monotonic_seconds * MICROSECONDS_IN_SECONDS;
		if (is_active) {
			this.activity_monitor_backend.idle_seconds = 0;
		} else {
			this.activity_monitor_backend.idle_seconds += monotonic_seconds;
		}
		this.activity_monitor.poll_activity();
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
