import camera.CameraState;
import camera.CameraStateTools;
import camera.CameraController;
import ui.AssetSelector;
import ui.Inspector;
import ui.InspectorModel;
import loader.Jda3dLoader;

// Import generated shaders from CLI compilation
import SphereBasicShader;
import RoundedBoxShader;
import PillarRepeatShader;

class Main extends hxd.App {
    var currentShader:Dynamic;  // Can be any of the 3 shaders - using Dynamic for direct property access
    var bitmap:h2d.Bitmap;
    var interactive:h2d.Interactive;
    var assetSelector:AssetSelector;
    var inspector:Inspector;
    var currentAssetPath:String;

    // Generated shaders (compiled from JDA assets via CLI)
    var sphereShader:SphereBasicShader;
    var roundedBoxShader:RoundedBoxShader;
    var pillarRepeatShader:PillarRepeatShader;

    // Camera system
    var cameraController:CameraController;

    // Input state
    var isDragging:Bool = false;
    var isShiftPressed:Bool = false;
    var lastMouseX:Float = 0;
    var lastMouseY:Float = 0;

    override function init() {
        // Initialize all 3 generated shaders (from CLI compilation)
        sphereShader = new SphereBasicShader();
        roundedBoxShader = new RoundedBoxShader();
        pillarRepeatShader = new PillarRepeatShader();

        // Start with sphere
        currentShader = sphereShader;
        trace("Initialized with SphereShader");

        // Create fullscreen bitmap with current shader
        bitmap = new h2d.Bitmap(h2d.Tile.fromColor(0x000000, engine.width, engine.height));
        bitmap.addShader(currentShader);
        s2d.addChildAt(bitmap, 0);  // Add at the bottom

        // Initialize camera controller with starting orbit state
        var initialState = CameraStateTools.createOrbit(
            new h3d.Vector(0, 0, 0),  // Target at origin
            5.0,                       // Distance from target
            45.0,                      // Yaw (45° around Y axis)
            -30.0                      // Pitch (looking down 30°)
        );
        cameraController = new CameraController(initialState);

        // Setup h3d camera from initial state
        updateCameraFromState();

        // Initialize shader camera
        updateShaderCamera(currentShader);

        // Setup fullscreen interactive for input (behind UI elements)
        interactive = new h2d.Interactive(engine.width, engine.height);
        s2d.addChildAt(interactive, 1);  // Add after bitmap but before UI
        interactive.enableRightButton = true;  // Enable middle mouse button

        interactive.onPush = function(e:hxd.Event) {
            if (e.button == 0 || e.button == 1) {  // Left or Middle mouse button
                isDragging = true;
                lastMouseX = e.relX;
                lastMouseY = e.relY;
            }
        };

        interactive.onRelease = function(e:hxd.Event) {
            if (e.button == 0 || e.button == 1) {  // LMB or MMB release
                isDragging = false;
            }
        };

        interactive.onMove = function(e:hxd.Event) {
            if (isDragging) {
                var deltaX = e.relX - lastMouseX;
                var deltaY = e.relY - lastMouseY;

                if (isShiftPressed) {
                    // Shift+MMB: Pan
                    cameraController.pan(deltaX, -deltaY);  // Invert Y for natural feel
                } else {
                    // MMB: Rotate
                    cameraController.rotate(deltaX, deltaY);
                }

                lastMouseX = e.relX;
                lastMouseY = e.relY;

                updateCameraFromState();
            }
        };

        interactive.onWheel = function(e:hxd.Event) {
            // Mouse wheel: Zoom
            cameraController.zoom(e.wheelDelta);
            updateCameraFromState();
        };

        interactive.onKeyDown = function(e:hxd.Event) {
            if (e.keyCode == hxd.Key.SHIFT) {
                isShiftPressed = true;
            }
        };

        interactive.onKeyUp = function(e:hxd.Event) {
            if (e.keyCode == hxd.Key.SHIFT) {
                isShiftPressed = false;
            }
        };

        // ===== VP6: Asset Selector UI =====
        assetSelector = new AssetSelector(s2d, function(assetName:String) {
            switchShader(assetName);
        });
        assetSelector.setPos(10, 10);
        // ===== End VP6 =====

        // ===== VP6 Phase 6.2: Inspector Panel =====
        inspector = new Inspector(s2d, engine.height);
        inspector.positionRight(engine.width);

        // Load initial asset data for inspector
        currentAssetPath = "assets/jda3d/jda.shape.sphere_basic.json";
        updateInspector(currentAssetPath);
        // ===== End VP6.2 =====
    }

    /**
     * Switch shader at runtime (no recompile needed!)
     */
    function switchShader(assetName:String) {
        trace('Switching to: $assetName');

        // Remove old shader
        bitmap.remove();

        // Select new shader and asset path
        var assetPath:String;
        currentShader = switch(assetName) {
            case "Sphere":
                assetPath = "assets/jda3d/jda.shape.sphere_basic.json";
                sphereShader;
            case "Rounded Box":
                assetPath = "assets/jda3d/jda.shape.rounded_box.json";
                roundedBoxShader;
            case "Pillar Repeat":
                assetPath = "assets/jda3d/jda.shape.pillar_repeat.json";
                pillarRepeatShader;
            default:
                assetPath = "assets/jda3d/jda.shape.sphere_basic.json";
                sphereShader;
        };

        // Create new bitmap with new shader at index 0 (bottom of z-order)
        bitmap = new h2d.Bitmap(h2d.Tile.fromColor(0x000000, engine.width, engine.height));
        bitmap.addShader(currentShader);
        s2d.addChildAt(bitmap, 0);  // Add at the back so UI stays on top

        // Update camera uniforms for new shader
        updateShaderCamera(currentShader);

        // Update inspector with new asset data
        currentAssetPath = assetPath;
        updateInspector(currentAssetPath);

        trace('✓ Switched to $assetName - NO RECOMPILE NEEDED!');
    }

    /**
     * Update inspector panel with asset data from JDA file
     */
    function updateInspector(assetPath:String) {
        try {
            var doc = Jda3dLoader.loadFromFile(assetPath);
            var data = InspectorModel.fromJdaDocument(doc);
            inspector.updateData(data);
        } catch (e:Dynamic) {
            trace('Warning: Could not load asset for inspector: $e');
        }
    }

    /**
     * Update h3d.Camera position and target from CameraState
     */
    function updateCameraFromState() {
        var state = cameraController.getState();
        var target = CameraStateTools.getTarget(state);
        var pos = CameraStateTools.computePosition(state);

        s3d.camera.pos.set(pos.x, pos.y, pos.z);
        s3d.camera.target.set(target.x, target.y, target.z);
    }

    /**
     * Update shader camera uniforms (works for all shader types)
     */
    function updateShaderCamera(shader:Dynamic) {
        // HXSL shaders require type-specific casting to access @param fields
        if (Std.isOfType(shader, SphereBasicShader)) {
            var s = cast(shader, SphereBasicShader);
            s.cameraPos = s3d.camera.pos;
            s.cameraTarget = s3d.camera.target;
            s.aspectRatio = engine.width / engine.height;
        } else if (Std.isOfType(shader, RoundedBoxShader)) {
            var s = cast(shader, RoundedBoxShader);
            s.cameraPos = s3d.camera.pos;
            s.cameraTarget = s3d.camera.target;
            s.aspectRatio = engine.width / engine.height;
        } else if (Std.isOfType(shader, PillarRepeatShader)) {
            var s = cast(shader, PillarRepeatShader);
            s.cameraPos = s3d.camera.pos;
            s.cameraTarget = s3d.camera.target;
            s.aspectRatio = engine.width / engine.height;
        }
    }

    override function update(dt:Float) {
        // Update current shader parameters each frame
        updateShaderCamera(currentShader);
    }

    static function main() {
        new Main();
    }
}
