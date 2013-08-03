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

class test_NaturalTime : SimpleTestSuite {
	public NaturalTime natural_time;

	public test_NaturalTime() {
		new test_get_label_for_seconds().add_to(this);
		new test_get_simplest_label_for_seconds().add_to(this);
		new test_get_countdown_for_seconds().add_to(this);
		new test_get_countdown_for_seconds_with_start().add_to(this);
		new test_get_seconds_for_input().add_to(this);
	}

	public override void setup() {
		this.natural_time = NaturalTime.instance;
	}
}

class test_get_label_for_seconds : SimpleTestCase<test_NaturalTime> {
	public override void run(test_NaturalTime context) {
		var label_60 = context.natural_time.get_label_for_seconds(60);
		var label_61 = context.natural_time.get_label_for_seconds(61);

		assert(label_60 == _("%d minute".printf(1)));
		assert(label_61 == _("%d seconds".printf(61)));
	}
}

class test_get_simplest_label_for_seconds : SimpleTestCase<test_NaturalTime> {
	public override void run(test_NaturalTime context) {
		var label_60 = context.natural_time.get_simplest_label_for_seconds(60);
		var label_61 = context.natural_time.get_simplest_label_for_seconds(61);
		
		assert(label_60 == _("%d minute".printf(1)));
		assert(label_61 == _("%d minute".printf(1)));
	}
}

class test_get_countdown_for_seconds : SimpleTestCase<test_NaturalTime> {
	public override void run(test_NaturalTime context) {
		var label_90 = context.natural_time.get_countdown_for_seconds(90);
		var label_60 = context.natural_time.get_countdown_for_seconds(60);
		var label_55 = context.natural_time.get_countdown_for_seconds(55);
		var label_42 = context.natural_time.get_countdown_for_seconds(42);
		var label_8 = context.natural_time.get_countdown_for_seconds(8);
		
		assert(label_90 == _("%d minutes".printf(2)));
		assert(label_60 == _("%d minute".printf(1)));
		assert(label_55 == _("%d minute".printf(1)));
		assert(label_42 == _("%d seconds".printf(50)));
		assert(label_8 == _("%d seconds".printf(8)));
	}
}

class test_get_countdown_for_seconds_with_start : SimpleTestCase<test_NaturalTime> {
	public override void run(test_NaturalTime context) {
		var label_90 = context.natural_time.get_countdown_for_seconds_with_start(90, 90);
		var label_60 = context.natural_time.get_countdown_for_seconds_with_start(60, 55);
		var label_55 = context.natural_time.get_countdown_for_seconds_with_start(55, 55);
		var label_51 = context.natural_time.get_countdown_for_seconds_with_start(51, 55);
		
		assert(label_90 == _("%d minute".printf(1)));
		assert(label_60 == _("%d seconds".printf(55)));
		assert(label_55 == _("%d seconds".printf(55)));
		assert(label_51 == _("%d seconds".printf(55)));
	}
}

class test_get_seconds_for_input : SimpleTestCase<test_NaturalTime> {
	public override void run(test_NaturalTime context) {
		var input_2_hours = _("%d hours".printf(2));
		var input_1_minute = _("%d minute".printf(1));
		var input_60_seconds = _("%d seconds".printf(60));

		assert(context.natural_time.get_seconds_for_input(input_2_hours) == 7200);
		assert(context.natural_time.get_seconds_for_input(input_1_minute) == 60);
		assert(context.natural_time.get_seconds_for_input(input_60_seconds) == 60);
	}
}

public static int main(string[] args) {
	GLib.Test.init(ref args);
	var root_suite = GLib.TestSuite.get_root();
	new test_NaturalTime().add_to(root_suite);
	GLib.Test.run();
	return 0;
}
