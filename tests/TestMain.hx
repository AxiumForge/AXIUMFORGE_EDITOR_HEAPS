import utest.Runner;
import utest.ui.Report;
import camera.CameraStateTest;
import camera.CameraControllerTest;

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
        runner.addCase(new CameraControllerTest());

        // Run all tests
        Report.create(runner);
        runner.run();
    }
}
