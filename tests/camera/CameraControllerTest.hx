package camera;

import utest.Test;
import utest.Assert;
import camera.CameraState;
import camera.CameraState.Orbit;
import camera.CameraStateTools;
import camera.CameraController;

/**
 * Tests for CameraController - Interactive 3D orbit camera controller
 *
 * TDD: Write tests first, then implement CameraController
 */
class CameraControllerTest extends Test {

    /**
     * Test: Controller can be created with initial state
     */
    public function testControllerInitialization() {
        var initialState = CameraStateTools.createOrbit(
            new h3d.Vector(0, 0, 0),
            5.0,
            45.0,
            -30.0
        );

        var controller = new CameraController(initialState);
        var state = controller.getState();

        switch(state) {
            case Orbit(t, d, y, p):
                Assert.equals(0.0, t.x);
                Assert.equals(0.0, t.y);
                Assert.equals(0.0, t.z);
                Assert.equals(5.0, d);
                Assert.equals(45.0, y);
                Assert.equals(-30.0, p);
            default:
                Assert.fail("Should be Orbit variant");
        }
    }

    /**
     * Test: Rotate updates yaw and pitch
     */
    public function testRotate() {
        var initialState = CameraStateTools.createOrbit(
            new h3d.Vector(0, 0, 0),
            5.0,
            0.0,
            -45.0
        );

        var controller = new CameraController(initialState);
        controller.rotate(10.0, 5.0); // deltaX affects yaw, deltaY affects pitch

        var state = controller.getState();
        switch(state) {
            case Orbit(_, _, y, p):
                // Yaw should increase by deltaX
                Assert.isTrue(y > 0.0);
                // Pitch should decrease by deltaY (more negative = looking more down)
                Assert.isTrue(p < -45.0);
            default:
                Assert.fail("Should be Orbit variant");
        }
    }

    /**
     * Test: Zoom changes distance
     */
    public function testZoom() {
        var initialState = CameraStateTools.createOrbit(
            new h3d.Vector(0, 0, 0),
            10.0,
            0.0,
            -45.0
        );

        var controller = new CameraController(initialState);

        // Zoom in (negative wheel delta = closer)
        controller.zoom(-1.0);

        var state = controller.getState();
        switch(state) {
            case Orbit(_, d, _, _):
                // Distance should be less than 10.0
                Assert.isTrue(d < 10.0);
            default:
                Assert.fail("Should be Orbit variant");
        }
    }

    /**
     * Test: Zoom out increases distance
     */
    public function testZoomOut() {
        var initialState = CameraStateTools.createOrbit(
            new h3d.Vector(0, 0, 0),
            10.0,
            0.0,
            -45.0
        );

        var controller = new CameraController(initialState);

        // Zoom out (positive wheel delta = farther)
        controller.zoom(1.0);

        var state = controller.getState();
        switch(state) {
            case Orbit(_, d, _, _):
                // Distance should be more than 10.0
                Assert.isTrue(d > 10.0);
            default:
                Assert.fail("Should be Orbit variant");
        }
    }

    /**
     * Test: Pan changes target position
     */
    public function testPan() {
        var initialState = CameraStateTools.createOrbit(
            new h3d.Vector(0, 0, 0),
            10.0,
            0.0,
            -45.0
        );

        var controller = new CameraController(initialState);

        // Pan right by 2 units
        controller.pan(2.0, 0.0);

        var state = controller.getState();
        switch(state) {
            case Orbit(t, _, _, _):
                // Target should have moved (not at origin anymore)
                var movedDistance = Math.sqrt(t.x * t.x + t.y * t.y + t.z * t.z);
                Assert.isTrue(movedDistance > 0.01);
            default:
                Assert.fail("Should be Orbit variant");
        }
    }

    /**
     * Test: Pan up changes target Y
     */
    public function testPanUp() {
        var initialState = CameraStateTools.createOrbit(
            new h3d.Vector(0, 0, 0),
            10.0,
            0.0,
            -45.0
        );

        var controller = new CameraController(initialState);

        // Pan up by 3 units
        controller.pan(0.0, 3.0);

        var state = controller.getState();
        switch(state) {
            case Orbit(t, _, _, _):
                // Target Y should be positive (moved up)
                Assert.isTrue(t.y > 0.0);
            default:
                Assert.fail("Should be Orbit variant");
        }
    }

    /**
     * Test: Multiple operations accumulate correctly
     */
    public function testMultipleOperations() {
        var initialState = CameraStateTools.createOrbit(
            new h3d.Vector(0, 0, 0),
            10.0,
            0.0,
            -45.0
        );

        var controller = new CameraController(initialState);

        // Perform multiple operations
        controller.rotate(10.0, 0.0);  // Rotate yaw
        controller.zoom(-0.5);         // Zoom in a bit
        controller.pan(1.0, 1.0);      // Pan right and up

        var state = controller.getState();
        switch(state) {
            case Orbit(t, d, y, p):
                // Yaw should be positive
                Assert.isTrue(y > 0.0);
                // Distance should be less than 10.0
                Assert.isTrue(d < 10.0);
                // Target should have moved
                Assert.isTrue(t.x != 0.0 || t.y != 0.0 || t.z != 0.0);
            default:
                Assert.fail("Should be Orbit variant");
        }
    }

    /**
     * Test: Sensitivity affects rotation amount
     */
    public function testRotationSensitivity() {
        var initialState = CameraStateTools.createOrbit(
            new h3d.Vector(0, 0, 0),
            10.0,
            0.0,
            -45.0
        );

        var controller1 = new CameraController(initialState, 0.1); // Low sensitivity
        var controller2 = new CameraController(initialState, 1.0); // High sensitivity

        controller1.rotate(10.0, 0.0);
        controller2.rotate(10.0, 0.0);

        var state1 = controller1.getState();
        var state2 = controller2.getState();

        var yaw1 = CameraStateTools.getYaw(state1);
        var yaw2 = CameraStateTools.getYaw(state2);

        // High sensitivity should result in larger yaw change
        Assert.isTrue(yaw2 > yaw1);
    }
}
