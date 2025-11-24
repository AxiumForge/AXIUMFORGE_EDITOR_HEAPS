import utest.Runner;
import utest.ui.Report;
import camera.CameraStateTest;
import camera.CameraControllerTest;
import loader.Jda3dLoaderTest;
import loader.SdfEvaluatorTest;
import loader.JdwLoaderTest;

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

        // Loader tests
        runner.addCase(new Jda3dLoaderTest());
        runner.addCase(new SdfEvaluatorTest());
        runner.addCase(new JdwLoaderTest());

        // Run all tests
        Report.create(runner);
        runner.run();
    }
}
