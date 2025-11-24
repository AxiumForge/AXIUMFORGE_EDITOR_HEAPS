package camera;

/**
 * Utility functions for CameraState
 *
 * All functions are pure - they don't modify state, they return new state.
 */
class CameraStateTools {

    /**
     * Create an orbit camera state
     */
    public static function createOrbit(target: h3d.Vector, distance: Float, yaw: Float, pitch: Float): CameraState {
        return Orbit(target.clone(), distance, yaw, pitch);
    }

    /**
     * Compute camera position from orbit state
     *
     * Converts spherical coordinates (yaw, pitch, distance) to cartesian (x, y, z)
     * relative to target point.
     *
     * Coordinate system: Y-up (Heaps default)
     * - yaw = 0: camera at +Z looking toward target
     * - pitch = 0: camera at same height as target
     * - pitch < 0: camera above target (looking down)
     */
    public static function computePosition(state: CameraState): h3d.Vector {
        return switch(state) {
            case Orbit(target, distance, yaw, pitch):
                // Convert degrees to radians
                var yawRad = yaw * Math.PI / 180.0;
                var pitchRad = pitch * Math.PI / 180.0;

                // Spherical to cartesian conversion
                // We use pitch as elevation from horizontal plane
                var cosPitch = Math.cos(pitchRad);
                var sinPitch = Math.sin(pitchRad);

                var x = distance * cosPitch * Math.sin(yawRad);
                var y = distance * -sinPitch; // Negative because pitch < 0 = above
                var z = distance * cosPitch * Math.cos(yawRad);

                // Add target offset
                return new h3d.Vector(
                    target.x + x,
                    target.y + y,
                    target.z + z
                );
        }
    }

    /**
     * Get target point from state
     */
    public static function getTarget(state: CameraState): h3d.Vector {
        return switch(state) {
            case Orbit(target, _, _, _): target.clone();
        }
    }

    /**
     * Get distance from state
     */
    public static function getDistance(state: CameraState): Float {
        return switch(state) {
            case Orbit(_, distance, _, _): distance;
        }
    }

    /**
     * Get yaw from state
     */
    public static function getYaw(state: CameraState): Float {
        return switch(state) {
            case Orbit(_, _, yaw, _): yaw;
        }
    }

    /**
     * Get pitch from state
     */
    public static function getPitch(state: CameraState): Float {
        return switch(state) {
            case Orbit(_, _, _, pitch): pitch;
        }
    }

    /**
     * Update yaw (horizontal rotation)
     *
     * Returns new state with updated yaw, all else unchanged.
     */
    public static function updateYaw(state: CameraState, newYaw: Float): CameraState {
        return switch(state) {
            case Orbit(target, distance, _, pitch):
                Orbit(target.clone(), distance, newYaw, pitch);
        }
    }

    /**
     * Update pitch (vertical angle)
     *
     * Returns new state with updated pitch, all else unchanged.
     */
    public static function updatePitch(state: CameraState, newPitch: Float): CameraState {
        return switch(state) {
            case Orbit(target, distance, yaw, _):
                Orbit(target.clone(), distance, yaw, newPitch);
        }
    }

    /**
     * Update distance (zoom)
     *
     * Returns new state with updated distance, all else unchanged.
     */
    public static function updateDistance(state: CameraState, newDistance: Float): CameraState {
        return switch(state) {
            case Orbit(target, _, yaw, pitch):
                Orbit(target.clone(), newDistance, yaw, pitch);
        }
    }

    /**
     * Update target (pan)
     *
     * Returns new state with updated target, all else unchanged.
     */
    public static function updateTarget(state: CameraState, newTarget: h3d.Vector): CameraState {
        return switch(state) {
            case Orbit(_, distance, yaw, pitch):
                Orbit(newTarget.clone(), distance, yaw, pitch);
        }
    }

    /**
     * Add delta to yaw (for mouse drag rotation)
     */
    public static function addYaw(state: CameraState, deltaYaw: Float): CameraState {
        var currentYaw = getYaw(state);
        return updateYaw(state, currentYaw + deltaYaw);
    }

    /**
     * Add delta to pitch (for mouse drag rotation)
     *
     * Clamps pitch to safe range to prevent gimbal lock.
     * At exactly ±90°, camera is directly above/below target and rotation breaks.
     */
    public static function addPitch(state: CameraState, deltaPitch: Float, minPitch: Float = -85.0, maxPitch: Float = 85.0): CameraState {
        var currentPitch = getPitch(state);
        var newPitch = currentPitch + deltaPitch;

        // Clamp pitch to prevent gimbal lock (stay away from ±90°)
        // This allows 170° vertical rotation which is sufficient for most use cases
        newPitch = Math.max(minPitch, Math.min(maxPitch, newPitch));

        return updatePitch(state, newPitch);
    }

    /**
     * Multiply distance by factor (for zoom)
     *
     * Clamps distance to prevent camera getting too close or too far.
     */
    public static function multiplyDistance(state: CameraState, factor: Float, minDistance: Float = 0.5, maxDistance: Float = 50.0): CameraState {
        var currentDistance = getDistance(state);
        var newDistance = currentDistance * factor;

        // Clamp distance
        newDistance = Math.max(minDistance, Math.min(maxDistance, newDistance));

        return updateDistance(state, newDistance);
    }

    /**
     * Pan target in camera's local XZ plane
     *
     * Moves target based on camera's current orientation.
     * Right vector = camera's right direction
     * Up vector = camera's up direction (in world Y)
     */
    public static function panTarget(state: CameraState, deltaRight: Float, deltaUp: Float): CameraState {
        var target = getTarget(state);
        var yaw = getYaw(state);

        // Compute camera's right vector (perpendicular to forward)
        var yawRad = yaw * Math.PI / 180.0;
        var rightX = Math.cos(yawRad);
        var rightZ = -Math.sin(yawRad);

        // Move target
        var newTarget = new h3d.Vector(
            target.x + rightX * deltaRight,
            target.y + deltaUp,
            target.z + rightZ * deltaRight
        );

        return updateTarget(state, newTarget);
    }
}
