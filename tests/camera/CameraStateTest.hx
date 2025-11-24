package camera;

import utest.Test;
import utest.Assert;

// Import from src/camera/ (different source path)
import camera.CameraState;
import camera.CameraState.Orbit;
import camera.CameraStateTools;

/**
 * Tests for CameraState - 3D orbit camera data structure
 *
 * TDD: Write tests first, then implement CameraState
 */
class CameraStateTest extends Test {

    /**
     * Test: Orbit state can be created with initial values
     */
    public function testOrbitStateInitialization() {
        var target = new h3d.Vector(0, 0, 0);
        var distance = 5.0;
        var yaw = 45.0;
        var pitch = -45.0;

        var state = CameraStateTools.createOrbit(target, distance, yaw, pitch);

        switch(state) {
            case Orbit(t, d, y, p):
                Assert.equals(target.x, t.x);
                Assert.equals(target.y, t.y);
                Assert.equals(target.z, t.z);
                Assert.equals(distance, d);
                Assert.equals(yaw, y);
                Assert.equals(pitch, p);
            default:
                Assert.fail("Should be Orbit variant");
        }
    }

    /**
     * Test: Position computation from orbit state (spherical to cartesian)
     */
    public function testComputePosition() {
        var target = new h3d.Vector(0, 0, 0);
        var distance = 5.0;
        var yaw = 0.0;  // Looking from +Z
        var pitch = 0.0; // Horizontal

        var state = CameraStateTools.createOrbit(target, distance, yaw, pitch);
        var pos = CameraStateTools.computePosition(state);

        // At yaw=0, pitch=0: camera should be at (0, 0, distance)
        Assert.floatEquals(0.0, pos.x, 0.01);
        Assert.floatEquals(0.0, pos.y, 0.01);
        Assert.isTrue(Math.abs(pos.z - distance) < 0.01);
    }

    /**
     * Test: Position computation with yaw rotation
     */
    public function testComputePositionWithYaw() {
        var target = new h3d.Vector(0, 0, 0);
        var distance = 5.0;
        var yaw = 90.0;  // Rotate 90° around Y axis
        var pitch = 0.0;

        var state = CameraStateTools.createOrbit(target, distance, yaw, pitch);
        var pos = CameraStateTools.computePosition(state);

        // At yaw=90°, pitch=0: camera should be at (distance, 0, 0)
        Assert.isTrue(Math.abs(pos.x - distance) < 0.01);
        Assert.floatEquals(0.0, pos.y, 0.01);
        Assert.floatEquals(0.0, pos.z, 0.01);
    }

    /**
     * Test: Position computation with pitch (vertical angle)
     */
    public function testComputePositionWithPitch() {
        var target = new h3d.Vector(0, 0, 0);
        var distance = 5.0;
        var yaw = 0.0;
        var pitch = -45.0;  // Look down 45°

        var state = CameraStateTools.createOrbit(target, distance, yaw, pitch);
        var pos = CameraStateTools.computePosition(state);

        // Camera should be above and behind target
        Assert.isTrue(pos.y > 0.0); // Above
        Assert.isTrue(pos.z > 0.0); // Behind

        // Distance from target should be ~5.0
        var actualDist = Math.sqrt(pos.x * pos.x + pos.y * pos.y + pos.z * pos.z);
        Assert.isTrue(Math.abs(actualDist - distance) < 0.01);
    }

    /**
     * Test: Target offset - camera orbits around non-zero point
     */
    public function testTargetOffset() {
        var target = new h3d.Vector(10, 5, -3);
        var distance = 2.0;
        var yaw = 0.0;
        var pitch = 0.0;

        var state = CameraStateTools.createOrbit(target, distance, yaw, pitch);
        var pos = CameraStateTools.computePosition(state);

        // Camera should be 'distance' away from target
        var dx = pos.x - target.x;
        var dy = pos.y - target.y;
        var dz = pos.z - target.z;
        var actualDist = Math.sqrt(dx * dx + dy * dy + dz * dz);

        Assert.isTrue(Math.abs(actualDist - distance) < 0.01);
    }

    /**
     * Test: Update yaw (horizontal rotation)
     */
    public function testUpdateYaw() {
        var state = CameraStateTools.createOrbit(
            new h3d.Vector(0, 0, 0),
            5.0,
            45.0,
            -30.0
        );

        var newState = CameraStateTools.updateYaw(state, 90.0);

        switch(newState) {
            case Orbit(t, d, y, p):
                Assert.equals(90.0, y);
                Assert.equals(-30.0, p); // Pitch unchanged
                Assert.equals(5.0, d);   // Distance unchanged
            default:
                Assert.fail("Should be Orbit variant");
        }
    }

    /**
     * Test: Update pitch (vertical angle)
     */
    public function testUpdatePitch() {
        var state = CameraStateTools.createOrbit(
            new h3d.Vector(0, 0, 0),
            5.0,
            45.0,
            -30.0
        );

        var newState = CameraStateTools.updatePitch(state, -60.0);

        switch(newState) {
            case Orbit(t, d, y, p):
                Assert.equals(45.0, y); // Yaw unchanged
                Assert.equals(-60.0, p);
                Assert.equals(5.0, d);
            default:
                Assert.fail("Should be Orbit variant");
        }
    }

    /**
     * Test: Update distance (zoom)
     */
    public function testUpdateDistance() {
        var state = CameraStateTools.createOrbit(
            new h3d.Vector(0, 0, 0),
            5.0,
            45.0,
            -30.0
        );

        var newState = CameraStateTools.updateDistance(state, 10.0);

        switch(newState) {
            case Orbit(t, d, y, p):
                Assert.equals(45.0, y);
                Assert.equals(-30.0, p);
                Assert.equals(10.0, d);
            default:
                Assert.fail("Should be Orbit variant");
        }
    }

    /**
     * Test: Update target (pan)
     */
    public function testUpdateTarget() {
        var state = CameraStateTools.createOrbit(
            new h3d.Vector(0, 0, 0),
            5.0,
            45.0,
            -30.0
        );

        var newTarget = new h3d.Vector(2, 1, -1);
        var newState = CameraStateTools.updateTarget(state, newTarget);

        switch(newState) {
            case Orbit(t, d, y, p):
                Assert.equals(2.0, t.x);
                Assert.equals(1.0, t.y);
                Assert.equals(-1.0, t.z);
                Assert.equals(45.0, y);
                Assert.equals(-30.0, p);
                Assert.equals(5.0, d);
            default:
                Assert.fail("Should be Orbit variant");
        }
    }
}
