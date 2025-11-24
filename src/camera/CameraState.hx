package camera;

/**
 * Camera state for 3D orbit camera
 *
 * Represents camera position as orbit around a target point using spherical coordinates:
 * - target: Point the camera looks at
 * - distance: How far from target
 * - yaw: Horizontal rotation (degrees, 0 = looking from +Z)
 * - pitch: Vertical angle (degrees, 0 = horizontal, negative = looking down)
 *
 * This is an immutable data structure - updates create new state.
 */
enum CameraState {
    Orbit(target: h3d.Vector, distance: Float, yaw: Float, pitch: Float);
}
