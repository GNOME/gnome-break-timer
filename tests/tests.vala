/* tests.vala
 *
 * Copyright 2020 Dylan McCall <dylan@dylanmccall.ca>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

// GLib's TestSuite and TestCase are compact classes, so we wrap them in real GLib.Objects for convenience
// This base code is partly borrowed from libgee's test suite, at https://git.gnome.org/browse/libgee

using BreakTimer.Common;
using BreakTimer.Daemon.Activity;
using BreakTimer.Daemon.Util;

namespace BreakTimer.Tests {

public abstract class SimpleTestSuite : GLib.Object {
    private GLib.TestSuite g_test_suite;
    private Adaptor[] adaptors = new Adaptor[0];

    private class Adaptor {
        private SimpleTestSuite test_suite;
        private SimpleTestCase<SimpleTestSuite> test;

        public Adaptor (SimpleTestSuite test_suite, owned SimpleTestCase<SimpleTestSuite> test) {
            this.test_suite = test_suite;
            this.test = (owned) test;
        }

        private string get_short_name () {
            string base_name = this.test_suite.get_name ();
            string test_full_name = this.test.get_name ();
            if (test_full_name.has_prefix (base_name)) {
                return test_full_name.splice (0, base_name.length);
            } else {
                return test_full_name;
            }
        }

        private void setup (void *fixture) {
            this.test_suite.setup ();
        }

        private void run (void *fixture) {
            this.test.run (this.test_suite);
        }

        private void teardown (void *fixture) {
            this.test_suite.teardown ();
        }

        public GLib.TestCase get_g_test_case () {
            return new GLib.TestCase (
                this.get_short_name (),
                (TestFixtureFunc) this.setup,
                (TestFixtureFunc) this.run,
                (TestFixtureFunc) this.teardown
            );
        }
    }

    protected SimpleTestSuite () {
        var name = this.get_name ();
        this.g_test_suite = new GLib.TestSuite (name);
    }

    public void add_to (GLib.TestSuite parent) {
        parent.add_suite (this.g_test_suite);
    }

    public GLib.TestSuite get_g_test_suite () {
        return this.g_test_suite;
    }

    public string get_name () {
        return this.get_type ().name ();
    }

    public void add_test (owned SimpleTestCase test) {
        var adaptor = new Adaptor (this, (owned) test);
        this.adaptors += adaptor;
        this.g_test_suite.add (adaptor.get_g_test_case ());
    }

    public virtual void setup () {
    }

    public virtual void teardown () {
    }
}

public interface SimpleTestCase<T> : GLib.Object {
    public abstract void run (T context);

    public void add_to (SimpleTestSuite test_suite) {
        test_suite.add_test (this);
    }

    public string get_name () {
        return this.get_type ().name ();
    }
}


public class TestRunner : GLib.Object {
    private GLib.TestSuite root_suite;

    private GLib.File tmp_dir;
    const string SCHEMA_FILE_NAME = "org.gnome.BreakTimer.gschema.xml";

    public TestRunner (ref unowned string[] args, GLib.TestSuite? root_suite = null) {
        GLib.Test.init (ref args);
        if (root_suite == null) {
            this.root_suite = GLib.TestSuite.get_root ();
        } else {
            this.root_suite = root_suite;
        }
    }

    public void add (SimpleTestSuite suite) {
        suite.add_to (this.root_suite);
    }

    public virtual void global_setup () {
        GLib.Environment.set_variable ("LANGUAGE", "C", true);

        try {
            var tmp_path = GLib.DirUtils.make_tmp ("gnome-break-timer-test-XXXXXX");
            tmp_dir = GLib.File.new_for_path (tmp_path);
        } catch (Error e) {
            GLib.warning ("Error creating temporary directory for test files: %s".printf (e.message));
        }
    }

    public virtual void global_teardown () {
        if (tmp_dir != null) {
            var tmp_dir_path = tmp_dir.get_path ();
            int delete_tmp_result = Posix.system ("rm -rf %s".printf (tmp_dir_path));
            if (delete_tmp_result != 0) {
                GLib.warning ("Could not delete temporary files in %s", tmp_dir_path);
            }
        }
    }

    public int run () {
        this.global_setup ();
        GLib.Test.run ();
        this.global_teardown ();
        return 0;
    }
}


// Special test suites suited for particular pieces of the application

public class TestSuiteWithActivityMonitor : SimpleTestSuite {
    public testable_ActivityMonitorBackend activity_monitor_backend;
    public testable_SessionStatus session_status;
    public ActivityMonitor activity_monitor;
    public GLib.List<UserActivity?> activity_log;

    public const int64 START_REAL_TIME = 100000 * TimeUnit.MICROSECONDS_IN_SECONDS;
    public const int64 START_MONOTONIC_TIME = 50 * TimeUnit.MICROSECONDS_IN_SECONDS;

    public override void setup () {
        base.setup ();

        TimeUnit._do_override_time = true;
        TimeUnit._override_real_time = START_REAL_TIME;
        TimeUnit._override_monotonic_time = START_MONOTONIC_TIME;

        this.activity_log = new GLib.List<UserActivity?> ();
        this.refresh_environment ();
    }

    public override void teardown () {
        TimeUnit._do_override_time = false;
        TimeUnit._override_real_time = 0;
        TimeUnit._override_monotonic_time = 0;
    }

    public virtual void refresh_environment () {
        // We keep _override_real_time as it is, because time never goes backward within a test case
        TimeUnit._override_monotonic_time = START_MONOTONIC_TIME;

        this.activity_log = new GLib.List<UserActivity?> ();
        this.activity_monitor_backend = new testable_ActivityMonitorBackend ();
        this.session_status = new testable_SessionStatus ();
        this.activity_monitor = new ActivityMonitor (session_status, activity_monitor_backend);
        this.activity_monitor.detected_idle.connect (this.log_activity);
        this.activity_monitor.detected_activity.connect (this.log_activity);
        this.activity_monitor.stop ();
    }

    public virtual void time_step (bool is_active, int real_seconds, int monotonic_seconds) {
        TimeUnit._override_real_time += real_seconds * TimeUnit.MICROSECONDS_IN_SECONDS;
        TimeUnit._override_monotonic_time += monotonic_seconds * TimeUnit.MICROSECONDS_IN_SECONDS;
        if (is_active) this.activity_monitor_backend.push_activity ();
        this.activity_monitor.poll_activity ();
    }

    private void log_activity (UserActivity activity) {
        this.activity_log.append (activity);
    }
}


// We also need special testable implementations of certain classes and interfaces

public class testable_ActivityMonitorBackend : ActivityMonitorBackend {
    private int64 start_time_ms = 0;
    private int64 last_event_time_ms = 0;

    public testable_ActivityMonitorBackend () {
        this.start_time_ms = TimeUnit.get_monotonic_time_ms () - 10000;
    }

    public void push_activity () {
        this.last_event_time_ms = TimeUnit.get_monotonic_time_ms ();
    }

    protected override uint64 time_since_last_event_ms () {
        int64 now_monotonic_ms = TimeUnit.get_monotonic_time_ms ();
        int64 event_time_ms = this.last_event_time_ms;
        if (event_time_ms == 0) event_time_ms = this.start_time_ms;
        return now_monotonic_ms - event_time_ms;
    }
}

public class testable_SessionStatus : GLib.Object, ISessionStatus {
    public bool virt_is_locked = false;

    public void do_lock () {
        this.virt_is_locked = true;
        this.locked ();
    }

    public void do_unlock () {
        this.virt_is_locked = false;
        this.unlocked ();
    }

    public bool is_locked () {
        return this.virt_is_locked;
    }

    public void lock_screen () {
        this.virt_is_locked = true;
    }

    public void blank_screen () {}

    public void unblank_screen () {}
}

}
