import utest.Runner;
import utest.ui.Report;
import camera.CameraStateTest;

/**
 * Test runner for AxiumForge Editor
 *
 * Run with: haxe tests/build.hxml
 */
class TestMain {
    static function main() {
        var runner = new Runner();

        // Camera tests
        runner.addCase(new CameraStateTest());

        // Run all tests
        Report.create(runner);
        runner.run();
    }
}
