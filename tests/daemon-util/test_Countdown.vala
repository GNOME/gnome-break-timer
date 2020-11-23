/* test_Countdown.vala
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

using BreakTimer.Daemon.Util;

namespace BreakTimer.Tests.Daemon.Util {

public class test_Countdown : TestSuiteWithActivityMonitor {
    public test_Countdown () {
        new test_construct ().add_to (this);
        new test_reset ().add_to (this);
        new test_start ().add_to (this);
        new test_start_from ().add_to (this);
        new test_pause ().add_to (this);
        new test_continue ().add_to (this);
        new test_continue_from ().add_to (this);
        new test_cancel_pause ().add_to (this);
        new test_advance_time ().add_to (this);
        new test_set_penalty ().add_to (this);
        new test_set_base_duration ().add_to (this);
        new test_get_duration ().add_to (this);
        new test_get_time_elapsed ().add_to (this);
        new test_timers ().add_to (this);
        new test_serialization ().add_to (this);
    }

    class test_construct : Object, SimpleTestCase<test_Countdown> {
        public void run (test_Countdown context) {
            var countdown = new Countdown (30);

            assert (countdown.get_time_remaining () == 30);

            context.time_step (false, 10, 10);
            assert (countdown.get_time_remaining () == 30);
        }
    }

    class test_reset : Object, SimpleTestCase<test_Countdown> {
        public void run (test_Countdown context) {
            var countdown = new Countdown (30);

            countdown.start_from (-10);
            countdown.set_penalty (20);
            assert (countdown.get_time_remaining () == 40);
            assert (countdown.is_counting () == true);

            countdown.reset ();
            assert (countdown.get_time_remaining () == 30);
            assert (countdown.is_counting () == false);
        }
    }

    class test_start : Object, SimpleTestCase<test_Countdown> {
        public void run (test_Countdown context) {
            var countdown = new Countdown (30);

            assert (countdown.is_counting () == false);

            countdown.start ();
            assert (countdown.get_time_remaining () == 30);
            assert (countdown.is_counting () == true);

            context.time_step (false, 10, 10);
            assert (countdown.get_time_remaining () == 20);

            countdown.start ();
            assert (countdown.get_time_remaining () == 30);

            context.time_step (false, 10, 10);
            assert (countdown.get_time_remaining () == 20);

            context.time_step (false, 35, 35);
            assert (countdown.get_time_remaining () == 0);
        }
    }

    class test_start_from : Object, SimpleTestCase<test_Countdown> {
        public void run (test_Countdown context) {
            var countdown = new Countdown (30);

            countdown.start_from (-10);
            assert (countdown.get_time_remaining () == 20);

            context.time_step (false, 5, 5);
            assert (countdown.get_time_remaining () == 15);

            countdown.start_from (-10);
            assert (countdown.get_time_remaining () == 20);

            countdown.start_from (-50);
            assert (countdown.get_time_remaining () == 0);

            // Test that start_from doesn't allow time_remaining to exceed duration
            countdown.start_from (10);
            assert (countdown.get_time_remaining () == 30);
        }
    }

    class test_pause : Object, SimpleTestCase<test_Countdown> {
        public void run (test_Countdown context) {
            var countdown = new Countdown (30);

            countdown.start ();
            context.time_step (false, 10, 10);
            assert (countdown.get_time_remaining () == 20);

            countdown.pause ();
            context.time_step (false, 10, 10);
            assert (countdown.get_time_remaining () == 20);
        }
    }

    class test_continue : Object, SimpleTestCase<test_Countdown> {
        public void run (test_Countdown context) {
            var countdown = new Countdown (30);

            countdown.continue ();
            context.time_step (false, 10, 10);
            assert (countdown.get_time_remaining () == 20);

            countdown.pause ();
            context.time_step (false, 10, 10);
            assert (countdown.get_time_remaining () == 20);

            countdown.continue ();
            context.time_step (false, 10, 10);
            assert (countdown.get_time_remaining () == 10);
        }
    }

    class test_continue_from : Object, SimpleTestCase<test_Countdown> {
        public void run (test_Countdown context) {
            var countdown = new Countdown (30);

            countdown.continue_from (-10);
            assert (countdown.get_time_remaining () == 20);
            assert (countdown.is_counting () == true);

            context.time_step (false, 10, 10);
            assert (countdown.get_time_remaining () == 10);
            assert (countdown.is_counting () == true);

            // Test that continue_from doesn't do anything if countdown is already running
            countdown.continue_from (-10);
            assert (countdown.get_time_remaining () == 10);
            assert (countdown.is_counting () == true);
        }
    }

    class test_cancel_pause : Object, SimpleTestCase<test_Countdown> {
        public void run (test_Countdown context) {
            var countdown = new Countdown (30);

            countdown.start ();

            countdown.pause ();
            context.time_step (false, 10, 10);
            assert (countdown.get_time_remaining () == 30);
            assert (countdown.is_counting () == false);

            countdown.cancel_pause ();
            assert (countdown.get_time_remaining () == 20);
            assert (countdown.is_counting () == true);
        }
    }

    class test_advance_time : Object, SimpleTestCase<test_Countdown> {
        public void run (test_Countdown context) {
            var countdown = new Countdown (30);

            countdown.advance_time (10);
            assert (countdown.get_time_remaining () == 20);

            countdown.continue ();
            assert (countdown.get_time_remaining () == 20);

            countdown.advance_time (10);
            assert (countdown.get_time_remaining () == 10);
        }
    }

    class test_set_penalty : Object, SimpleTestCase<test_Countdown> {
        public void run (test_Countdown context) {
            var countdown = new Countdown (30);

            countdown.set_penalty (20);
            assert (countdown.get_penalty () == 20);
            assert (countdown.get_time_remaining () == 50);

            countdown.continue ();
            context.time_step (false, 10, 10);
            assert (countdown.get_time_remaining () == 40);

            countdown.set_penalty (5);
            assert (countdown.get_penalty () == 5);
            assert (countdown.get_time_remaining () == 25);

            countdown.start ();
            assert (countdown.get_penalty () == 0);
            assert (countdown.get_time_remaining () == 30);
        }
    }

    class test_set_base_duration : Object, SimpleTestCase<test_Countdown> {
        public void run (test_Countdown context) {
            var countdown = new Countdown (30);

            countdown.start ();

            context.time_step (false, 10, 10);
            assert (countdown.get_time_remaining () == 20);

            countdown.set_base_duration (10);
            assert (countdown.get_time_remaining () == 0);

            countdown.set_base_duration (15);
            assert (countdown.get_time_remaining () == 5);

            countdown.start ();
            assert (countdown.get_time_remaining () == 15);
        }
    }

    class test_get_duration : Object, SimpleTestCase<test_Countdown> {
        public void run (test_Countdown context) {
            var countdown = new Countdown (30);

            assert (countdown.get_duration () == 30);

            countdown.set_penalty (5);
            assert (countdown.get_duration () == 35);

            countdown.set_base_duration (40);
            assert (countdown.get_duration () == 45);

            countdown.reset ();
            assert (countdown.get_duration () == 40);
        }
    }

    class test_get_time_elapsed : Object, SimpleTestCase<test_Countdown> {
        public void run (test_Countdown context) {
            var countdown = new Countdown (30);

            assert (countdown.get_time_elapsed () == 0);
            assert (countdown.get_time_remaining () == 30);
            assert (countdown.is_finished () == false);

            countdown.start ();

            context.time_step (false, 10, 10);
            assert (countdown.get_time_elapsed () == 10);
            assert (countdown.get_time_remaining () == 20);
            assert (countdown.is_finished () == false);

            context.time_step (false, 50, 50);
            assert (countdown.get_time_elapsed () == 60);
            assert (countdown.get_time_remaining () == 0);
            assert (countdown.is_finished () == true);

            countdown.reset ();

            assert (countdown.get_time_elapsed () == 0);
            assert (countdown.get_time_remaining () == 30);
            assert (countdown.is_finished () == false);
        }
    }

    class test_timers : Object, SimpleTestCase<test_Countdown> {
        public void run (test_Countdown context) {
            var countdown = new Countdown (30);

            countdown.start ();

            // Test that timer advances with change in wall time
            context.time_step (false, 10, 0);
            assert (countdown.get_time_remaining () == 20);

            // Test that it ignores change in monotonic time
            context.time_step (false, 0, 10);
            assert (countdown.get_time_remaining () == 20);
        }
    }

    class test_serialization : Object, SimpleTestCase<test_Countdown> {
        public void run (test_Countdown context) {
            var countdown = new Countdown (30);

            var data_0 = countdown.serialize ();

            countdown.start ();
            context.time_step (false, 10, 10);
            var data_1 = countdown.serialize ();

            countdown.pause ();
            var data_2 = countdown.serialize ();
            context.time_step (false, 10, 10);

            this.assert_deserialize (30, data_0, false, 0, 30);
            this.assert_deserialize (30, data_1, true, 10, 20);
            this.assert_deserialize (30, data_2, false, 10, 20);
        }

        private void assert_deserialize (int known_duration, string data, bool is_counting, int time_elapsed, int time_remaining) {
            var countdown = new Countdown (known_duration);
            countdown.deserialize (data);

            assert (countdown.is_counting () == is_counting);
            assert (countdown.get_time_elapsed () == time_elapsed);
            assert (countdown.get_time_remaining () == time_remaining);
        }
    }
}

}
