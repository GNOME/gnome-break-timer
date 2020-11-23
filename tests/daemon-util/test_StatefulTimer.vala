/* test_StatefulTimer.vala
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

public class test_StatefulTimer : TestSuiteWithActivityMonitor {
    /* We won't be able to test the timer mechanics in much detail because,
     * internally, it uses GTimer and the (real) system clock. Still, we can
     * test that StatefulTimer keeps track of state, as well as serialization.
     */

    public test_StatefulTimer () {
        new test_construct ().add_to (this);
        new test_stop_start ().add_to (this);
        new test_continue ().add_to (this);
        new test_start_lap ().add_to (this);
        new test_serialize_hardcoded ().add_to (this);
        new test_deserialize_hardcoded ().add_to (this);
    }

    class test_construct : Object, SimpleTestCase<test_StatefulTimer> {
        public void run (test_StatefulTimer context) {
            var timer = new StatefulTimer ();

            assert (timer.state == StatefulTimer.State.COUNTING);
        }
    }

    class test_stop_start : Object, SimpleTestCase<test_StatefulTimer> {
        public void run (test_StatefulTimer context) {
            var timer = new StatefulTimer ();

            timer.stop ();
            assert (timer.state == StatefulTimer.State.STOPPED);
            assert (timer.is_stopped () == true);
            assert (timer.is_counting () == false);

            timer.start ();
            assert (timer.state == StatefulTimer.State.COUNTING);
            assert (timer.is_stopped () == false);
            assert (timer.is_counting () == true);
        }
    }

    class test_continue : Object, SimpleTestCase<test_StatefulTimer> {
        public void run (test_StatefulTimer context) {
            var timer = new StatefulTimer ();

            timer.stop ();

            timer.continue ();
            assert (timer.state == StatefulTimer.State.COUNTING);
        }
    }

    class test_start_lap : Object, SimpleTestCase<test_StatefulTimer> {
        public void run (test_StatefulTimer context) {
            var timer = new StatefulTimer ();

            timer.stop ();

            timer.start_lap ();
            assert (timer.state == StatefulTimer.State.COUNTING);
        }
    }

    class test_serialize_hardcoded : Object, SimpleTestCase<test_StatefulTimer> {
        public void run (test_StatefulTimer context) {
            var timer = new StatefulTimer ();

            var data = timer.serialize ();
            string[] data_parts = data.split (",");

            assert (data_parts[0] == "1");
        }
    }

    class test_deserialize_hardcoded : Object, SimpleTestCase<test_StatefulTimer> {
        public void run (test_StatefulTimer context) {
            var timer = new StatefulTimer ();

            var data = "0,20.0,15.0";
            timer.deserialize (data);

            assert (timer.state == StatefulTimer.State.STOPPED);
            // Convert time values to ints to deal with floating point errors
            assert ((int)timer.elapsed () == 20);
            assert ((int)timer.lap_time () == 5);
        }
    }
}

}
