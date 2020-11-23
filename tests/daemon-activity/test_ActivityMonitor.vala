/* test_ActivityMonitor.vala
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

using BreakTimer.Daemon.Activity;

namespace BreakTimer.Tests.Daemon.Activity {

public class test_ActivityMonitor : TestSuiteWithActivityMonitor {
    public test_ActivityMonitor () {
        new test_simple_idle ().add_to (this);
        new test_simple_active ().add_to (this);
        new test_lock_idle ().add_to (this);
        new test_active_then_idle ().add_to (this);
        new test_sleep_and_unlock ().add_to (this);
        new test_unlock_signal_activity ().add_to (this);
    }

    class test_simple_idle : Object, SimpleTestCase<test_ActivityMonitor> {
        public void run (test_ActivityMonitor context) {
            context.session_status.virt_is_locked = false;
            context.time_step (false, 0, 0);
            context.time_step (false, 1, 1);

            assert (context.activity_log.length () == 2);

            assert (context.activity_log.nth_data (0).type == ActivityType.NONE);
            assert (context.activity_log.nth_data (0).is_active () == false);
            assert (context.activity_log.nth_data (0).idle_time == 10);

            assert (context.activity_log.nth_data (1).type == ActivityType.NONE);
            assert (context.activity_log.nth_data (1).is_active () == false);
            assert (context.activity_log.nth_data (1).idle_time == context.activity_log.nth_data (0).idle_time + 1);
        }
    }

    class test_simple_active : Object, SimpleTestCase<test_ActivityMonitor> {
        public void run (test_ActivityMonitor context) {
            context.session_status.virt_is_locked = false;
            context.time_step (true, 1, 1);

            context.time_step (true, 1, 1);

            context.time_step (true, 1, 1);

            assert (context.activity_log.length () == 3);

            assert (context.activity_log.nth_data (0).type == ActivityType.INPUT);
            assert (context.activity_log.nth_data (0).is_active () == true);
            assert (context.activity_log.nth_data (0).idle_time == 0);

            assert (context.activity_log.nth_data (1).type == ActivityType.INPUT);
            assert (context.activity_log.nth_data (1).is_active () == true);
            assert (context.activity_log.nth_data (1).idle_time == 0);

            assert (context.activity_log.nth_data (2).type == ActivityType.INPUT);
            assert (context.activity_log.nth_data (2).is_active () == true);
            assert (context.activity_log.nth_data (2).idle_time == 0);
        }
    }

    class test_active_then_idle : Object, SimpleTestCase<test_ActivityMonitor> {
        public void run (test_ActivityMonitor context) {
            context.session_status.virt_is_locked = false;
            context.time_step (true, 1, 1);

            context.time_step (false, 1, 1);

            context.time_step (false, 1, 1);

            context.time_step (true, 1, 1);

            context.time_step (true, 1, 1);

            assert (context.activity_log.length () == 5);

            assert (context.activity_log.nth_data (0).type == ActivityType.INPUT);
            assert (context.activity_log.nth_data (0).is_active () == true);
            assert (context.activity_log.nth_data (0).idle_time == 0);

            assert (context.activity_log.nth_data (1).type == ActivityType.NONE);
            assert (context.activity_log.nth_data (1).is_active () == false);
            assert (context.activity_log.nth_data (1).idle_time == 1);
            assert (context.activity_log.nth_data (1).time_since_active == 1);

            assert (context.activity_log.nth_data (2).type == ActivityType.NONE);
            assert (context.activity_log.nth_data (2).is_active () == false);
            assert (context.activity_log.nth_data (2).idle_time == 2);
            assert (context.activity_log.nth_data (2).time_since_active == 2);

            assert (context.activity_log.nth_data (3).type == ActivityType.INPUT);
            assert (context.activity_log.nth_data (3).is_active () == true);
            assert (context.activity_log.nth_data (3).idle_time == 0);
            assert (context.activity_log.nth_data (3).time_since_active == 3);

            assert (context.activity_log.nth_data (4).type == ActivityType.INPUT);
            assert (context.activity_log.nth_data (4).is_active () == true);
            assert (context.activity_log.nth_data (4).idle_time == 0);
            assert (context.activity_log.nth_data (4).time_since_active == 1);
        }
    }

    class test_lock_idle : Object, SimpleTestCase<test_ActivityMonitor> {
        public void run (test_ActivityMonitor context) {
            context.session_status.virt_is_locked = true;
            context.time_step (true, 1, 1);

            context.time_step (true, 1, 1);

            context.time_step (false, 1, 1);

            assert (context.activity_log.length () == 3);

            assert (context.activity_log.nth_data (0).type == ActivityType.LOCKED);
            assert (context.activity_log.nth_data (0).is_active () == false);
            assert (context.activity_log.nth_data (0).idle_time == 0);

            assert (context.activity_log.nth_data (1).type == ActivityType.LOCKED);
            assert (context.activity_log.nth_data (1).is_active () == false);
            assert (context.activity_log.nth_data (1).idle_time == 0);

            assert (context.activity_log.nth_data (2).type == ActivityType.LOCKED);
            assert (context.activity_log.nth_data (2).is_active () == false);
            assert (context.activity_log.nth_data (2).idle_time == 1);
        }
    }

    class test_sleep_and_unlock : Object, SimpleTestCase<test_ActivityMonitor> {
        public void run (test_ActivityMonitor context) {
            context.session_status.virt_is_locked = false;
            context.time_step (true, 1, 1);

            context.session_status.virt_is_locked = true;
            context.time_step (true, 120, 2);

            context.time_step (true, 1, 1);

            context.session_status.virt_is_locked = false;
            context.time_step (true, 1, 1);

            assert (context.activity_log.length () == 4);

            assert (context.activity_log.nth_data (0).type == ActivityType.INPUT);
            assert (context.activity_log.nth_data (0).is_active () == true);
            assert (context.activity_log.nth_data (0).idle_time == 0);
            assert (context.activity_log.nth_data (0).time_correction == 0);

            assert (context.activity_log.nth_data (1).type == ActivityType.SLEEP);
            assert (context.activity_log.nth_data (1).is_active () == false);
            assert (context.activity_log.nth_data (1).time_since_active == 120);
            assert (context.activity_log.nth_data (1).idle_time == 0);
            assert (context.activity_log.nth_data (1).time_correction == 120-2);

            assert (context.activity_log.nth_data (2).type == ActivityType.LOCKED);
            assert (context.activity_log.nth_data (2).is_active () == false);
            assert (context.activity_log.nth_data (2).idle_time == 0);
            assert (context.activity_log.nth_data (2).time_correction == 0);

            assert (context.activity_log.nth_data (3).type == ActivityType.INPUT);
            assert (context.activity_log.nth_data (3).is_active () == true);
            assert (context.activity_log.nth_data (3).idle_time == 0);
            assert (context.activity_log.nth_data (3).time_correction == 0);
        }
    }

    class test_unlock_signal_activity : Object, SimpleTestCase<test_ActivityMonitor> {
        public void run (test_ActivityMonitor context) {
            context.session_status.virt_is_locked = true;
            context.time_step (true, 1, 1);

            context.session_status.do_unlock ();

            assert (context.activity_log.length () == 2);

            assert (context.activity_log.nth_data (0).type == ActivityType.LOCKED);
            assert (context.activity_log.nth_data (0).is_active () == false);
            assert (context.activity_log.nth_data (0).idle_time == 0);

            assert (context.activity_log.nth_data (1).type == ActivityType.UNLOCK);
            assert (context.activity_log.nth_data (1).is_active () == true);
            assert (context.activity_log.nth_data (1).idle_time == 0);
        }
    }
}

}
