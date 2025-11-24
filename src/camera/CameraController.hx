package camera;

/**
 * Interactive 3D orbit camera controller
 *
 * Handles user input and updates CameraState accordingly.
 * Provides methods for rotation, zoom, and pan operations.
 *
 * Usage:
 * ```haxe
 * var controller = new CameraController(initialState);
 * controller.rotate(deltaX, deltaY);  // Update based on mouse drag
 * controller.zoom(wheelDelta);        // Update based on mouse wheel
 * var state = controller.getState();  // Get current camera state
 * ```
 */
class CameraController {
    var state: CameraState;
    var rotationSensitivity: Float;
    var zoomSensitivity: Float;
    var panSensitivity: Float;

    /**
     * Create a new camera controller
     *
     * @param initialState Starting camera state
     * @param sensitivity Overall sensitivity multiplier for all operations (default 0.5)
     */
    public function new(initialState: CameraState, sensitivity: Float = 0.5) {
        this.state = initialState;
        this.rotationSensitivity = sensitivity;
        this.zoomSensitivity = 0.1; // Fixed zoom sensitivity
        this.panSensitivity = 0.01; // Fixed pan sensitivity
    }

    /**
     * Get current camera state
     */
    public function getState(): CameraState {
        return state;
    }

    /**
     * Rotate camera (orbit around target)
     *
     * @param deltaX Horizontal mouse delta (affects yaw)
     * @param deltaY Vertical mouse delta (affects pitch)
     */
    public function rotate(deltaX: Float, deltaY: Float): Void {
        state = CameraStateTools.addYaw(state, deltaX * rotationSensitivity);
        state = CameraStateTools.addPitch(state, deltaY * rotationSensitivity);
    }

    /**
     * Zoom camera (change distance from target)
     *
     * @param wheelDelta Mouse wheel delta (positive = zoom out, negative = zoom in)
     */
    public function zoom(wheelDelta: Float): Void {
        // Convert wheel delta to zoom factor
        // Negative delta = zoom in (multiply by < 1.0)
        // Positive delta = zoom out (multiply by > 1.0)
        var factor = 1.0 + (wheelDelta * zoomSensitivity);
        state = CameraStateTools.multiplyDistance(state, factor);
    }

    /**
     * Pan camera (move target point)
     *
     * @param deltaRight Movement in camera's right direction
     * @param deltaUp Movement in camera's up direction (world Y)
     */
    public function pan(deltaRight: Float, deltaUp: Float): Void {
        state = CameraStateTools.panTarget(state, deltaRight * panSensitivity, deltaUp * panSensitivity);
    }

    /**
     * Reset camera to a new state
     *
     * @param newState New camera state
     */
    public function setState(newState: CameraState): Void {
        state = newState;
    }
}
