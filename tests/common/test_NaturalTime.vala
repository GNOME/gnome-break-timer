/* test_NaturalTime.vala
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

using BreakTimer.Common;

namespace BreakTimer.Tests.Common {

public class test_NaturalTime : SimpleTestSuite {
    public NaturalTime natural_time;

    public test_NaturalTime () {
        new test_get_label_for_seconds ().add_to (this);
        new test_get_simplest_label_for_seconds ().add_to (this);
        new test_get_countdown_for_seconds ().add_to (this);
        new test_get_countdown_for_seconds_with_start ().add_to (this);
    }

    public override void setup () {
        this.natural_time = NaturalTime.instance;
    }

    class test_get_label_for_seconds : Object, SimpleTestCase<test_NaturalTime> {
        public void run (test_NaturalTime context) {
            int value_60;
            var label_60 = context.natural_time.get_label_for_seconds (60, out value_60);
            assert (label_60 == "%d minute".printf (1));
            assert (value_60 == 1);

            int value_61;
            var label_61 = context.natural_time.get_label_for_seconds (61, out value_61);
            assert (label_61 == "%d seconds".printf (61));
            assert (value_61 == 61);
        }
    }

    class test_get_simplest_label_for_seconds : Object, SimpleTestCase<test_NaturalTime> {
        public void run (test_NaturalTime context) {
            int value_60;
            var label_60 = context.natural_time.get_simplest_label_for_seconds (60, out value_60);
            assert (label_60 == "%d minute".printf (1));
            assert (value_60 == 1);

            int value_61;
            var label_61 = context.natural_time.get_simplest_label_for_seconds (61, out value_61);
            assert (label_61 == "%d minute".printf (1));
            assert (value_61 == 1);
        }
    }

    class test_get_countdown_for_seconds : Object, SimpleTestCase<test_NaturalTime> {
        public void run (test_NaturalTime context) {
            int value_90;
            var label_90 = context.natural_time.get_countdown_for_seconds (90, out value_90);
            assert (label_90 == "%d minutes".printf (2));
            assert (value_90 == 2);

            int value_60;
            var label_60 = context.natural_time.get_countdown_for_seconds (60, out value_60);
            assert (label_60 == "%d minute".printf (1));
            assert (value_60 == 1);

            int value_55;
            var label_55 = context.natural_time.get_countdown_for_seconds (55, out value_55);
            assert (label_55 == "%d minute".printf (1));
            assert (value_55 == 1);

            int value_42;
            var label_42 = context.natural_time.get_countdown_for_seconds (42, out value_42);
            assert (label_42 == "%d seconds".printf (50));
            assert (value_42 == 50);

            int value_8;
            var label_8 = context.natural_time.get_countdown_for_seconds (8, out value_8);
            assert (label_8 == "%d seconds".printf (8));
            assert (value_8 == 8);
        }
    }

    class test_get_countdown_for_seconds_with_start : Object, SimpleTestCase<test_NaturalTime> {
        public void run (test_NaturalTime context) {
            int value_90;
            var label_90 = context.natural_time.get_countdown_for_seconds_with_start (90, 90, out value_90);
            assert (label_90 == "%d minute".printf (1));
            assert (value_90 == 1);

            int value_60;
            var label_60 = context.natural_time.get_countdown_for_seconds_with_start (60, 55, out value_60);
            assert (label_60 == "%d seconds".printf (55));
            assert (value_60 == 55);

            int value_55;
            var label_55 = context.natural_time.get_countdown_for_seconds_with_start (55, 55, out value_55);
            assert (label_55 == "%d seconds".printf (55));
            assert (value_55 == 55);

            int value_51;
            var label_51 = context.natural_time.get_countdown_for_seconds_with_start (51, 55, out value_51);
            assert (label_51 == "%d seconds".printf (55));
            assert (value_51 == 55);
        }
    }
}

}
