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

public int main(string[] args) {
	GLib.Test.init(ref args);
	GLib.TestSuite.get_root().add_suite(
		new ExampleTestSuite().get_g_test_suite()
	);
	GLib.Test.run();
	return 0;
}
