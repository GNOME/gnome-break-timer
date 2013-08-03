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

class ExampleTestSuite : SimpleTestSuite {
	public ExampleTestSuite() {
		this.add_test(new ExampleTestCase());
	}

	public class ExampleTestCase : SimpleTestCase {
		public override void run() {
			assert(true);
		}
	}
}

public static int main(string[] args) {
	GLib.Test.init(ref args);
	var root_suite = GLib.TestSuite.get_root();
	new ExampleTestSuite().add_to(root_suite);
	GLib.Test.run();
	return 0;
}
