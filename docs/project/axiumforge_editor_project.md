# AxiumForge Editor - Project Plan

> **VP (Viable Product) + TDD + Domain-Driven Design**
>
> Every phase delivers a **working, usable product**. We build incrementally, test-first, with clear domain separation.

---

## 0. Philosophy & Principles

### VP (Viable Product) Paradigm

**Not just MVP** - Every phase produces a **Viable Product** that:
- ✅ Works end-to-end
- ✅ Can be used/demoed
- ✅ Builds on previous VP
- ✅ Adds meaningful capability

**Example**:
- VP0 = Working viewer (static shader)
- VP1 = VP0 + Interactive camera
- VP2 = VP1 + Hot-reload shaders
- Each VP is **shippable** and **valuable**

### TDD (Test-Driven Development)

**Red → Green → Refactor**:
1. Write test (fails)
2. Write minimal code (passes)
3. Refactor (improve)
4. Repeat

**Benefits**:
- ✅ Haxe has excellent test support
- ✅ Prevents regressions
- ✅ Forces clear interfaces
- ✅ AI can validate work automatically

### Domain-Driven Design (DDD)

**Orchestrator Pattern**:
- `Main.hx` = Orchestrator (coordinates domains)
- Each domain = Separate module/file
- Domains = Single responsibility
- Clear interfaces between domains

**KISS (Keep It Simple)**:
- Functions over classes when simpler
- Classes when state management needed
- No over-engineering
- Pragmatic choices

### AI-Friendly Architecture

- Clear file/module boundaries
- One concern per file
- Explicit interfaces
- Good naming (domain/intent obvious)
- Test files mirror implementation

---

## 1. Domain Architecture

### Core Domains

```
src/
  Main.hx                    # Orchestrator - coordinates all domains

  app/
    App.hx                   # Main application lifecycle
    Config.hx                # Configuration and settings

  camera/
    Camera.hx                # Camera state and transforms
    CameraController.hx      # Input handling → camera updates
    CameraState.hx           # Camera state types (orbit, target, etc.)

  render/
    RenderPipeline.hx        # Main render coordination
    Viewport.hx              # Viewport management

  shader/
    ShaderManager.hx         # Shader lifecycle and hot-reload
    ShaderCompiler.hx        # Compile shaders (HXSL or AxiumSL)
    ShaderRegistry.hx        # Track loaded shaders

  scene/
    SceneGraph.hx            # Scene hierarchy
    Node.hx                  # Scene node
    Transform.hx             # Transform math

  loader/
    FileLoader.hx            # Generic file loading
    JdwLoader.hx             # Load JDW documents (future)
    JdaLoader.hx             # Load JDA assets (future)

  axiumsl/
    Compiler.hx              # AxiumSL → HXSL compiler
    [... other AxiumSL modules as per axsl_project.md]

  utils/
    Math.hx                  # Math utilities
    Logger.hx                # Logging
    Result.hx                # Result<T, E> type

tests/
  [mirrors src/ structure]
  TestMain.hx                # Test runner
```

### Orchestrator Pattern

**Main.hx** coordinates:
```haxe
class Main extends hxd.App {
  var camera: CameraController;
  var renderPipeline: RenderPipeline;
  var shaderManager: ShaderManager;
  var scene: SceneGraph;

  override function init() {
    // Initialize domains
    camera = new CameraController(s3d.camera);
    shaderManager = new ShaderManager();
    renderPipeline = new RenderPipeline(s2d, s3d);
    scene = new SceneGraph();

    // Wire them together
    renderPipeline.setShader(shaderManager.getCurrentShader());
    renderPipeline.setCamera(camera.getState());
  }

  override function update(dt: Float) {
    // Update domains
    camera.update(dt);
    shaderManager.update(dt);

    // Sync state
    renderPipeline.updateCamera(camera.getState());
  }
}
```

**Key principle**: Main doesn't implement logic, it **coordinates**.

---

## 2. Viable Product Phases

### VP0: Static Viewer (CURRENT STATE) ✅

**Status**: Already complete!

**Capabilities**:
- ✅ Heaps app runs
- ✅ Fullscreen SDF raymarch shader
- ✅ Static camera
- ✅ Renders sphere

**Files**:
- `src/Main.hx`
- `src/RaymarchShader.hx`
- `build.hxml`

**This is our baseline VP.**

---

### VP1: Interactive Viewer ⏱️ 1 week

**Goal**: VP0 + Interactive camera controls

**New Capabilities**:
- User can orbit camera (MMB drag)
- User can zoom (mouse wheel)
- User can pan (Shift+MMB drag)
- Camera state is smooth and intuitive

**Deliverable**: Usable 3D viewer with Blender-style controls

#### VP1 Implementation Plan (TDD)

**Domain**: `camera/`

**Test-first workflow**:

1. **Test: CameraState**
   ```haxe
   // tests/camera/CameraStateTest.hx
   function testOrbitStateInitialization() {
     var state = CameraState.orbit(target, distance, yaw, pitch);
     assertEquals(state.target, target);
     assertEquals(state.distance, distance);
   }

   function testComputePosition() {
     var state = CameraState.orbit(Vec3.zero(), 5.0, 0, -45);
     var pos = state.computePosition();
     // Assert position is correct based on spherical coords
   }
   ```

2. **Implement: CameraState.hx**
   ```haxe
   // src/camera/CameraState.hx
   enum CameraState {
     Orbit(target:Vec3, distance:Float, yaw:Float, pitch:Float);
   }

   class CameraStateTools {
     public static function computePosition(state:CameraState):Vec3 {
       return switch(state) {
         case Orbit(target, distance, yaw, pitch):
           // Compute position from spherical coordinates
           // ...
       }
     }
   }
   ```

3. **Test: CameraController input handling**
   ```haxe
   // tests/camera/CameraControllerTest.hx
   function testOrbitOnMouseDrag() {
     var controller = new CameraController();
     controller.onMouseDown(MouseButton.Middle, 100, 100);
     controller.onMouseMove(110, 105);

     var newState = controller.getState();
     // Assert yaw/pitch changed correctly
   }
   ```

4. **Implement: CameraController.hx**
   ```haxe
   // src/camera/CameraController.hx
   class CameraController {
     var state: CameraState;
     var isDragging: Bool = false;
     var lastMouseX: Float;
     var lastMouseY: Float;

     public function update(dt: Float) {
       // Handle input events
       // Update camera state
     }

     public function getState():CameraState {
       return state;
     }

     public function applyToCamera(camera: h3d.Camera) {
       var pos = state.computePosition();
       camera.pos.set(pos.x, pos.y, pos.z);
       camera.target.set(state.target.x, state.target.y, state.target.z);
     }
   }
   ```

5. **Integrate in Main.hx**
   ```haxe
   // src/Main.hx
   override function init() {
     cameraController = new CameraController(s3d.camera);
     // Wire input events
   }

   override function update(dt: Float) {
     cameraController.update(dt);
     cameraController.applyToCamera(s3d.camera);

     // Update shader with new camera
     raymarchShader.cameraPos = s3d.camera.pos;
     raymarchShader.cameraTarget = s3d.camera.target;
   }
   ```

**Validation**:
- Run viewer, camera responds to mouse input smoothly
- All tests pass: `haxe tests/build.hxml`

**VP1 Done**: We have an interactive 3D viewer! ✅

---

### VP2: Hot-Reload Shader System ⏱️ 1 week

**Goal**: VP1 + Load shaders from files, hot-reload on changes

**New Capabilities**:
- Load HXSL shaders from files
- Watch shader files for changes
- Hot-reload shaders without restarting app
- Handle shader compilation errors gracefully

**Deliverable**: Live shader development environment

#### VP2 Implementation Plan (TDD)

**Domain**: `shader/`

**Test-first workflow**:

1. **Test: ShaderManager**
   ```haxe
   // tests/shader/ShaderManagerTest.hx
   function testLoadShader() {
     var manager = new ShaderManager();
     var result = manager.loadShader("test_shader.hxsl");

     assertTrue(result.isOk());
     assertNotNull(manager.getCurrentShader());
   }

   function testReloadShader() {
     var manager = new ShaderManager();
     manager.loadShader("test.hxsl");
     var shader1 = manager.getCurrentShader();

     // Simulate file change
     manager.reloadShader();
     var shader2 = manager.getCurrentShader();

     assertNotEquals(shader1, shader2);
   }
   ```

2. **Implement: ShaderManager.hx**
   ```haxe
   // src/shader/ShaderManager.hx
   class ShaderManager {
     var currentShader: Null<hxsl.Shader>;
     var currentPath: Null<String>;
     var fileWatcher: FileWatcher;

     public function loadShader(path: String):Result<hxsl.Shader, String> {
       try {
         // Load and compile shader
         var source = sys.io.File.getContent(path);
         var shader = compileHxsl(source);
         currentShader = shader;
         currentPath = path;

         // Start watching file
         fileWatcher.watch(path, onFileChanged);

         return Ok(shader);
       } catch(e: Dynamic) {
         return Err("Failed to load shader: " + e);
       }
     }

     function onFileChanged() {
       trace("Shader file changed, reloading...");
       reloadShader();
     }

     public function reloadShader() {
       if (currentPath != null) {
         loadShader(currentPath);
       }
     }
   }
   ```

3. **Test: Error handling**
   ```haxe
   function testInvalidShaderHandling() {
     var manager = new ShaderManager();
     var result = manager.loadShader("invalid.hxsl");

     assertTrue(result.isErr());
     // App should not crash
   }
   ```

4. **Implement: Error reporting**
   ```haxe
   public function loadShader(path: String):Result<hxsl.Shader, String> {
     try {
       var source = sys.io.File.getContent(path);
       var shader = compileHxsl(source);
       return Ok(shader);
     } catch(e: hxsl.CompileError) {
       Logger.error("Shader compilation error: " + e.message);
       return Err(e.message);
     } catch(e: Dynamic) {
       Logger.error("Shader load error: " + e);
       return Err(Std.string(e));
     }
   }
   ```

5. **Integrate in Main.hx**
   ```haxe
   override function init() {
     shaderManager = new ShaderManager();

     switch(shaderManager.loadShader("shaders/raymarch.hxsl")) {
       case Ok(shader):
         bitmap.addShader(shader);
       case Err(msg):
         trace("Failed to load shader: " + msg);
         // Fallback to default shader
     }
   }

   override function update(dt: Float) {
     shaderManager.update(dt); // Checks for hot-reload
   }
   ```

**Validation**:
- Edit shader file, see changes in real-time
- Invalid shader shows error but app continues
- All tests pass

**VP2 Done**: Live shader development works! ✅

---

### VP3: AxiumSL Compiler ⏱️ 4-6 weeks

**Goal**: VP2 + Compile `.axsl` shaders to HXSL

**New Capabilities**:
- Write shaders in AxiumSL DSL
- Compiler translates `.axsl` → `.hxsl`
- Hot-reload works with `.axsl` files
- Example shaders demonstrate SDF/CSG features

**Deliverable**: Custom shader language for SDF development

**Implementation**: Follow `docs/project/axsl_project.md` phases 0-6

**Integration point**: ShaderManager supports both `.hxsl` and `.axsl` files:

```haxe
public function loadShader(path: String):Result<hxsl.Shader, String> {
  if (path.endsWith(".axsl")) {
    // Compile AxiumSL → HXSL first
    var compiler = new axiumsl.Compiler();
    var hxslSource = compiler.compile(sys.io.File.getContent(path));
    return compileHxsl(hxslSource);
  } else {
    // Load HXSL directly
    return compileHxsl(sys.io.File.getContent(path));
  }
}
```

**Validation**:
- Write `.axsl` shader, loads and renders correctly
- AxiumSL compiler tests all pass
- Examples work (sphere, CSG, complex scenes)

**VP3 Done**: Custom shader language works! ✅

---

### VP4: Scene System ⏱️ 2-3 weeks

**Goal**: VP3 + Load and manage multiple objects/nodes

**New Capabilities**:
- Scene graph with hierarchy
- Multiple SDF objects in scene
- Transform system (position, rotation, scale)
- Select and focus on objects

**Deliverable**: Multi-object scene viewer

#### VP4 Implementation Plan (TDD)

**Domain**: `scene/`

**Test-first workflow**:

1. **Test: Transform**
   ```haxe
   // tests/scene/TransformTest.hx
   function testTransformComposition() {
     var t1 = Transform.translation(1, 0, 0);
     var t2 = Transform.translation(0, 1, 0);
     var composed = t1.compose(t2);

     var point = Vec3.zero();
     var result = composed.apply(point);
     assertEquals(result, new Vec3(1, 1, 0));
   }
   ```

2. **Test: SceneNode**
   ```haxe
   function testNodeHierarchy() {
     var root = new Node("root");
     var child = new Node("child");
     root.addChild(child);

     assertEquals(child.parent, root);
     assertTrue(root.children.indexOf(child) >= 0);
   }

   function testWorldTransform() {
     var parent = new Node("parent");
     parent.transform.position.set(1, 0, 0);

     var child = new Node("child");
     child.transform.position.set(0, 1, 0);
     parent.addChild(child);

     var worldPos = child.getWorldTransform().position;
     assertEquals(worldPos, new Vec3(1, 1, 0));
   }
   ```

3. **Implement: Scene domain**
   ```haxe
   // src/scene/Transform.hx
   class Transform {
     public var position: Vec3;
     public var rotation: Quat;
     public var scale: Vec3;

     public function toMatrix():Mat4 { /* ... */ }
     public function compose(other:Transform):Transform { /* ... */ }
   }

   // src/scene/Node.hx
   class Node {
     public var name: String;
     public var transform: Transform;
     public var parent: Null<Node>;
     public var children: Array<Node>;
     public var sdfData: Null<SDFData>; // SDF primitive info

     public function addChild(child: Node) { /* ... */ }
     public function getWorldTransform():Transform { /* ... */ }
   }

   // src/scene/SceneGraph.hx
   class SceneGraph {
     var root: Node;

     public function addNode(node: Node, parent: Null<Node> = null) { /* ... */ }
     public function findNode(name: String):Null<Node> { /* ... */ }
     public function traverse(fn: Node -> Void) { /* ... */ }
   }
   ```

4. **Integrate with shader system**: Pass scene data to shader as uniforms/buffers

**Validation**:
- Create scene with multiple objects
- Objects move independently
- Scene hierarchy works correctly

**VP4 Done**: Multi-object scenes work! ✅

---

### VP5: JDW/JDA Loader ⏱️ 3-4 weeks

**Goal**: VP4 + Load worlds and assets from JSON files

**New Capabilities**:
- Load JDW world files
- Load JDA asset files
- Build scene graph from JDW
- Cascading defaults (globals → world → layer → node)

**Deliverable**: Standards-compliant world viewer

#### VP5 Implementation Plan (TDD)

**Domain**: `loader/`

**Test-first workflow**:

1. **Test: JDW parsing**
   ```haxe
   // tests/loader/JdwLoaderTest.hx
   function testParseSimpleWorld() {
     var json = '{"jdw_version": "0.1.0", "worlds": [...]}';
     var loader = new JdwLoader();
     var result = loader.parse(json);

     assertTrue(result.isOk());
     var doc = result.unwrap();
     assertEquals(doc.jdwVersion, "0.1.0");
   }

   function testCascadingDefaults() {
     // Test that node inherits from layer → world → globals
   }
   ```

2. **Implement: JDW loader**
   ```haxe
   // src/loader/JdwLoader.hx
   class JdwLoader {
     public function parse(json: String):Result<JdwDocument, String> {
       // Parse JSON
       // Validate structure
       // Build type-safe representation
     }

     public function buildScene(doc: JdwDocument):SceneGraph {
       // Convert JDW to SceneGraph
       // Resolve cascading defaults
       // Load referenced JDA assets
     }
   }
   ```

3. **Test: JDA loading**
   ```haxe
   function testLoadJdaAsset() {
     var loader = new JdaLoader();
     var result = loader.load("assets/bobling.jda.json");

     assertTrue(result.isOk());
     var asset = result.unwrap();
     assertNotNull(asset.sdfTree);
   }
   ```

4. **Integrate in Main.hx**
   ```haxe
   override function init() {
     // ... existing setup ...

     // Load world
     var jdwLoader = new JdwLoader();
     switch(jdwLoader.loadFile("worlds/demo.jdw.json")) {
       case Ok(doc):
         scene = jdwLoader.buildScene(doc);
         // Update render pipeline with scene
       case Err(msg):
         trace("Failed to load world: " + msg);
     }
   }
   ```

**Validation**:
- Load example JDW file
- Scene builds correctly
- Cascading works
- Assets load and render

**VP5 Done**: Full world loading works! ✅

---

### VP6: Editor UI ⏱️ 4-6 weeks

**Goal**: VP5 + Interactive editor interface

**New Capabilities**:
- Scene graph panel (tree view)
- Inspector panel (node properties)
- Asset browser
- Save/load workflows
- Undo/redo

**Deliverable**: Complete editor application

**Domain**: `ui/` (new)

**Implementation**: Build UI incrementally, each panel is a VP

**VP6 Done**: Full editor works! ✅

---

## 3. Development Workflow

### TDD Cycle

For **every** feature:

```
1. Write failing test
   ↓
2. Run test (RED)
   ↓
3. Write minimal code
   ↓
4. Run test (GREEN)
   ↓
5. Refactor
   ↓
6. Run test (still GREEN)
   ↓
7. Commit
```

### Test Organization

```
tests/
  TestMain.hx           # Test runner
  [domain]/
    [Module]Test.hx     # Tests mirror src/ structure
```

**Example**:
```
src/camera/CameraController.hx
  ↔
tests/camera/CameraControllerTest.hx
```

### AI:DevOps Workflow

**For each VP:**

1. **Human**: "Implement VP[N]"
2. **AI**:
   - Review domain spec
   - Write tests first
   - Implement to pass tests
   - Refactor
   - Report completion
3. **Human**:
   - Run tests: `haxe tests/build.hxml`
   - Run app: `hl bin/viewer.hl`
   - Validate VP deliverable works
   - Approve or request fixes
4. **Move to next VP**

---

## 4. File Structure Guidelines

### One Concern Per File

❌ **Bad**:
```haxe
// src/Camera.hx
class Camera {
  // Camera state
  // Input handling
  // Math utilities
  // Rendering
  // ...
}
```

✅ **Good**:
```haxe
// src/camera/CameraState.hx
enum CameraState { /* state only */ }

// src/camera/CameraController.hx
class CameraController { /* input → state updates */ }

// src/camera/CameraUtils.hx
class CameraUtils { /* math helpers */ }
```

### Prefer Functions When Stateless

❌ **Unnecessary class**:
```haxe
class MathUtils {
  public static function clamp(v:Float, min:Float, max:Float):Float { /* ... */ }
}
```

✅ **Simple function**:
```haxe
function clamp(v:Float, min:Float, max:Float):Float {
  return Math.max(min, Math.min(max, v));
}
```

### Use Classes for Stateful Logic

✅ **Good use of class**:
```haxe
class ShaderManager {
  var currentShader: Null<hxsl.Shader>;
  var fileWatcher: FileWatcher;
  var shaderCache: Map<String, hxsl.Shader>;

  public function loadShader(path: String):Result<hxsl.Shader, String> { /* ... */ }
  public function reloadShader() { /* ... */ }
}
```

---

## 5. Utilities & Common Patterns

### Result<T, E> Type

```haxe
// src/utils/Result.hx
enum Result<T, E> {
  Ok(value: T);
  Err(error: E);
}

class ResultTools {
  public static function isOk<T, E>(r: Result<T, E>):Bool {
    return switch(r) {
      case Ok(_): true;
      case Err(_): false;
    }
  }

  public static function unwrap<T, E>(r: Result<T, E>):T {
    return switch(r) {
      case Ok(v): v;
      case Err(e): throw "Unwrap called on Err: " + e;
    }
  }

  public static function map<T, U, E>(r: Result<T, E>, fn: T -> U):Result<U, E> {
    return switch(r) {
      case Ok(v): Ok(fn(v));
      case Err(e): Err(e);
    }
  }
}
```

**Usage**:
```haxe
function loadShader(path: String):Result<Shader, String> {
  if (!sys.FileSystem.exists(path)) {
    return Err("File not found: " + path);
  }

  try {
    var shader = compileShader(path);
    return Ok(shader);
  } catch(e: Dynamic) {
    return Err("Compilation failed: " + e);
  }
}

// In caller:
switch(loadShader("shader.hxsl")) {
  case Ok(shader):
    useShader(shader);
  case Err(msg):
    trace("Error: " + msg);
}
```

### Logger

```haxe
// src/utils/Logger.hx
enum LogLevel {
  Debug;
  Info;
  Warn;
  Error;
}

class Logger {
  public static var level: LogLevel = Info;

  public static function debug(msg: String) {
    if (level <= Debug) trace("[DEBUG] " + msg);
  }

  public static function info(msg: String) {
    if (level <= Info) trace("[INFO] " + msg);
  }

  public static function warn(msg: String) {
    if (level <= Warn) trace("[WARN] " + msg);
  }

  public static function error(msg: String) {
    if (level <= Error) trace("[ERROR] " + msg);
  }
}
```

---

## 6. Current State → Next VP

### Right Now: VP0 ✅

**We have**:
- `src/Main.hx` - Basic app
- `src/RaymarchShader.hx` - Hardcoded shader
- Working viewer with static camera

### Next Up: VP1 🎯

**Goal**: Add camera controller

**Tasks**:
1. Create `src/camera/` domain
2. Write `CameraState` tests + implementation
3. Write `CameraController` tests + implementation
4. Integrate in `Main.hx`
5. Validate interactive controls work

**Estimated time**: 1 week

**AI can start when you say**: "Begin VP1"

---

## 7. Success Criteria Per VP

### VP Checklist

Each VP is complete when:

- ✅ **All tests pass** (`haxe tests/build.hxml`)
- ✅ **App compiles** (`haxe build.hxml`)
- ✅ **App runs** (`hl bin/viewer.hl`)
- ✅ **New feature works** (manual testing)
- ✅ **Existing features still work** (no regressions)
- ✅ **Code is clean** (domain separation maintained)
- ✅ **Docs updated** (CHANGELOG, progress tracking)

### Quality Gates

Before moving to next VP:

- 🧪 Test coverage for new domain
- 📐 Clear domain boundaries
- 📝 API documented (comments/docs)
- 🔍 Human validation complete

---

## 8. Progress Tracking

### Use Existing System

Track progress in `docs/project/progress.md`:

```markdown
## VP1: Interactive Viewer

**Started**: 2025-11-24
**Target**: 2025-12-01
**Status**: In Progress (60%)

### Completed:
- ✅ CameraState.hx + tests
- ✅ CameraController.hx + tests

### In Progress:
- 🔨 Main.hx integration

### Blocked:
- None

### Tests:
- ✅ All CameraState tests pass
- ✅ All CameraController tests pass
- ⏳ Integration tests pending
```

---

## 9. Decision Framework

### When to Use Function vs Class?

**Use function if**:
- Stateless operation
- Pure computation
- Simple utility

**Use class if**:
- Needs state management
- Lifecycle (init/update/cleanup)
- Multiple related methods

### When to Split a File?

**Split if**:
- File > 200 lines
- Multiple concerns mixed
- Hard to understand/test

**Keep together if**:
- Tightly coupled logic
- Small implementation
- Clear single purpose

### KISS Test

Before writing code, ask:
- "Is there a simpler way?"
- "Can I use a function instead?"
- "Do I really need this abstraction?"

If unsure → Choose simpler option.

---

## 10. Ready to Begin? 🚀

**Current state**: VP0 complete ✅

**Next VP**: VP1 - Interactive Viewer

**First task**: Create camera domain with TDD

**To start**: Say "Begin VP1" and AI will:
1. Create `src/camera/` and `tests/camera/` directories
2. Write CameraState tests
3. Implement CameraState
4. Write CameraController tests
5. Implement CameraController
6. Integrate in Main.hx
7. Report completion for validation

**Estimated completion**: 1 week

**Let's build a Viable Product!** ✨
