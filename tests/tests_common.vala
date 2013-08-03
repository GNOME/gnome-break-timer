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
		private SimpleTestCase test;

		public Adaptor(SimpleTestSuite test_suite, owned SimpleTestCase test) {
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
			this.test.run();
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

public abstract class SimpleTestCase : Object {
	public abstract void run();

	public string get_name() {
		return this.get_type().name();
	}
}
