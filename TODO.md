# TODO - AxiumForge Editor & AxiumSL

> **Working Memory** - Current focus and active tasks
>
> **Workflow**: Work from this file → Mark done → Update CHANGELOG + project docs → Clear and add new tasks

---

## 🎯 Current Focus

**Active VP**: VP6 - Editor UI (Phase 6.3 ready!)
**Goal**: Complete Scene Graph Panel now that JDW loader is working
**Timeline**: Function over quality - first iteration
**Approach**: Heaps h2d UI + Domain-Driven Design (ui/ domain)
**Achievement**: 🎉 VP5 COMPLETE! All phases done (5.1, 5.2, 5.3, 5.4) ✅
**Foundation**: VP5 100% complete - JDA + JDW loading both working perfectly (205/205 tests passing!)
**Next**: VP6 Phase 6.3 (Scene Graph Panel) - display worlds/layers/nodes from JDW

---

## VP0: Static Viewer ✅ COMPLETED

**Status**: Baseline working product established

### Completed Features:
- [x] Heaps app skeleton (`Main.hx`)
- [x] Fullscreen SDF raymarch shader (`RaymarchShader.hx`)
- [x] Pure SDF sphere rendering (no meshes!)
- [x] Static camera system
- [x] Build system (`build.hxml`, `watch.sh`)
- [x] Project compiles successfully
- [x] HashLink runtime installed
- [x] Heaps 2.1.0 + hlsdl dependencies

**Deliverable**: ✅ Working 3D SDF viewer with static camera

---

## VP1: Interactive Viewer ✅ COMPLETED (2025-11-24)

**Goal**: VP0 + Interactive camera controls (orbit, zoom, pan)

**Status**: 100% Complete - All phases delivered!

### Domain: `camera/` (TDD Workflow)

#### Phase 1.1: CameraState - Data Structure ✅
- [x] **Test**: `tests/camera/CameraStateTest.hx` (9 tests, 31 assertions)
  - [x] Test orbit state initialization
  - [x] Test position computation from spherical coords
  - [x] Test yaw/pitch/distance updates
  - [x] Test target positioning
- [x] **Implement**: `src/camera/CameraState.hx` + `src/camera/CameraStateTools.hx`
  - [x] Define `CameraState` enum with `Orbit` variant
  - [x] Implement `computePosition()` - spherical to cartesian
  - [x] Implement state update methods (immutable)
  - [x] Implement helper functions (addYaw, addPitch, multiplyDistance, panTarget)
- [x] **Validate**: All CameraState tests pass ✅

#### Phase 1.2: CameraController - Input Handling ✅
- [x] **Test**: `tests/camera/CameraControllerTest.hx` (8 tests, 16 assertions)
  - [x] Test rotation updates yaw/pitch
  - [x] Test zoom updates distance
  - [x] Test pan updates target
  - [x] Test pitch clamping (-85° to +85°) - gimbal lock prevention
  - [x] Test distance clamping (min/max)
  - [x] Test sensitivity configuration
- [x] **Implement**: `src/camera/CameraController.hx`
  - [x] Stateful controller class
  - [x] Implement `rotate(deltaX, deltaY)` method
  - [x] Implement `zoom(wheelDelta)` method
  - [x] Implement `pan(deltaRight, deltaUp)` method
  - [x] Apply constraints (pitch clamp, distance clamp)
- [x] **Validate**: All CameraController tests pass ✅

#### Phase 1.3: Integration ✅
- [x] **Update**: `src/Main.hx`
  - [x] Import CameraController + CameraState modules
  - [x] Initialize controller in `init()` with starting state
  - [x] Wire h2d.Interactive for fullscreen input
  - [x] Handle mouse events (onPush, onRelease, onMove, onWheel)
  - [x] Handle keyboard events (Shift key tracking)
  - [x] Apply camera state to `s3d.camera` each frame
  - [x] Update shader uniforms with camera state
- [x] **Fixes Applied**:
  - [x] LMB + RMB support (not just MMB) - touchpad friendly!
  - [x] Box SDF instead of sphere - rotation visible
  - [x] Pitch range: -85° to +85° (170°) - gimbal lock avoided
- [x] **Test**: Manual validation
  - [x] Compile: `haxe build.hxml` ✅
  - [x] Run: `hl bin/viewer.hl` ✅
  - [x] Test orbit (drag) ✅
  - [x] Test zoom (2-finger scroll) ✅
  - [x] Test pan (Shift+drag) ✅
  - [x] Verify smooth, responsive controls ✅
- [x] **Validate**: VP1 deliverable works end-to-end ✅

### VP1 Success Criteria: ✅ ALL MET
- ✅ All tests pass (17 tests, 47 assertions, 0 failures)
- ✅ App compiles without errors
- ✅ Camera responds to mouse/touchpad input smoothly
- ✅ Controls feel natural (Blender-style orbit)
- ✅ 170° vertical rotation (gimbal lock avoided)
- ✅ Infinite horizontal rotation
- ✅ Existing features still work (no regressions)

**Deliverable**: ✅ Working interactive 3D SDF viewer with full orbit camera

---

## VP5: JDA/JDW Loader System ✅ COMPLETE (2025-11-25)

**Goal**: VP1 + Load and display JDA/JDW assets (CORE FUNCTIONALITY)

**Status**: All phases complete - JDW loader working perfectly!

**Why VP5 First?**:
- JDA/JDW loading is THE central system
- We already have 3 JDA 3D assets + 1 JDA 2D + 1 JDW world ready
- Rendering improvements (VP2/VP3) are secondary until this works
- DevOps principle: Jump phases to deliver core functionality first

### Domain: `loader/` (TDD Workflow)

#### Phase 5.1: JDA 3D JSON Parser ✅ COMPLETE (2025-11-24)
- [x] **Test**: `tests/loader/Jda3dLoaderTest.hx` (10 tests, 30 assertions)
  - [x] Test load basic sphere JDA (`jda.shape.sphere_basic.json`)
  - [x] Test parse metadata (jda_version, id, type)
  - [x] Test parse param_schema section
  - [x] Test parse sdf_tree structure (Primitive, Operation, Modifier)
  - [x] Test validate required fields
  - [x] Test CSG operations (smooth_union in rounded_box)
  - [x] Test modifiers (repeat in pillar_repeat)
  - [x] Test materials parsing
  - [x] Test variants parsing
  - [x] Test validation errors
- [x] **Implement**: `src/loader/Jda3dTypes.hx`
  - [x] Define `Jda3dDocument` typedef (metadata, paramSchema, sdfTree, materials, variants, attachPoints, depends)
  - [x] Define `SdfNode` enum (Primitive, Operation, Modifier, Reference)
  - [x] Define `PrimitiveShape` enum (Sphere, Box, Cylinder, Capsule, Torus, Plane)
  - [x] Define `CsgOperation` enum (Union, Subtract, Intersect, SmoothUnion, SmoothSubtract, SmoothIntersect)
  - [x] Define `ModifierType` enum (Repeat, Elongate, Twist, Bend, Round, Onion)
  - [x] Define `Dimension` enum (Dim2D, Dim3D)
  - [x] Define helper typedefs (ParamDefinition, Material, AttachPoint)
- [x] **Implement**: `src/loader/Jda3dLoader.hx`
  - [x] `loadFromFile(path: String): Jda3dDocument`
  - [x] `loadFromString(json: String): Jda3dDocument`
  - [x] JSON parsing with recursive SDF tree traversal
  - [x] Validation (required fields, type checks, error messages)
  - [x] Parse all sections (metadata, param_schema, sdf_tree, materials, variants, attach_points, depends)
- [x] **Validate**: All Jda3dLoader tests pass ✅ (77/77 assertions, 27/27 tests, 0 failures)

#### Phase 5.2: SDF Evaluation (Code Generation) ✅ COMPLETE (2025-11-24)
- [x] **Test**: `tests/loader/SdfEvaluatorTest.hx` (9 tests, 17 assertions)
  - [x] Test sphere primitive → HXSL code (generates `length(p) - radius`)
  - [x] Test box primitive → HXSL code (generates box SDF formula)
  - [x] Test CSG union → HXSL code (uses `min()`)
  - [x] Test CSG subtract → HXSL code (uses `max(a, -b)`)
  - [x] Test CSG smooth union (smooth min with k parameter)
  - [x] Test repeat modifier (domain repetition with `mod()`)
  - [x] Test complete shader class generation
  - [x] Test generated code syntax validation
- [x] **Implement**: `src/loader/SdfEvaluator.hx`
  - [x] `generateShaderClass(sdfTree, className)` - Complete HXSL shader class
  - [x] `generateSdfFunction(sdfTree, functionName)` - SDF distance function
  - [x] Primitive code generation (Sphere, Box, Cylinder, Capsule, Torus, Plane)
  - [x] CSG operation code generation (Union, Subtract, Intersect, SmoothUnion, SmoothSubtract, SmoothIntersect)
  - [x] Modifier code generation (Repeat, Elongate, Twist, Bend, Round, Onion)
  - [x] Recursive tree traversal with proper variable scoping
  - [x] Inline lambda expressions for complex operations
- [x] **Validate**: All tests pass ✅ (94/94 assertions, 35/35 tests, 0 failures)

#### Phase 5.3: JDW Scene Loader ✅ COMPLETE (2025-11-27)
- [x] **Test**: `tests/loader/JdwLoaderTest.hx` (14 tests, all passing!)
  - [x] Test load world document
  - [x] Test parse scene graph (worlds → layers → nodes)
  - [x] Test resolve JDA asset references
  - [x] Test cascading defaults (materials, settings)
  - [x] Test metadata (title, author, description)
  - [x] Test units (world_unit, reference_scales)
  - [x] Test globals (space, raymarch settings)
  - [x] Test materials (lambert/pbr, base color, 2D SDF overlays)
  - [x] Test asset registry (JDA and 2D SDF paths)
  - [x] Test layers (3D dimension, visibility, render order)
  - [x] Test nodes (transforms, inline_sdf, jda references)
- [x] **Implement**: `src/loader/JdwTypes.hx`
  - [x] Define `JdwDocument` typedef
  - [x] Define `JdwWorld`, `JdwLayer`, `JdwNode` typedefs
  - [x] Define `Transform3D` typedef
  - [x] Define `NodeSource` enum (InlineSdf, JdaReference)
- [x] **Implement**: `src/loader/JdwLoader.hx`
  - [x] Load JDW JSON (loadFromFile, loadFromString)
  - [x] Parse scene hierarchy (worlds → layers → nodes)
  - [x] Resolve asset references (JDA + 2D SDF assets)
  - [x] Parse materials with PBR properties
  - [x] Parse inline SDF nodes (reuses Jda3dLoader.parseSdfTree)
  - [x] Parse JDA reference nodes with variant + param overrides
- [x] **Validate**: All JDW loader tests pass ✅ (14 tests, 205/205 total assertions passing!)

#### Phase 5.4: Integration with Main.hx ✅ COMPLETE (2025-11-24)
- [x] **Update**: `src/Main.hx`
  - [x] Load JDA file from `assets/jda3d/jda.shape.sphere_basic.json`
  - [x] Generate HXSL shader code from SDF tree using `SdfEvaluator.generateShaderClass()`
  - [x] Write generated shader to file `src/GeneratedShader.hx`
  - [x] Replace hardcoded RaymarchShader with GeneratedShader (JDA-loaded asset)
  - [x] Verify rendering works ✅
- [x] **Test**: Manual validation
  - [x] Compile and run ✅
  - [x] Verify sphere renders correctly ✅ (radius 1.0 from JDA file)
  - [x] Camera controls still work ✅ (orbit, zoom, pan)
  - [x] No regressions ✅
- [ ] **Iterate**: Load other assets (future enhancement)
  - [ ] Test `jda.shape.rounded_box.json` (CSG smooth_union)
  - [ ] Test `jda.shape.pillar_repeat.json` (repeat modifier)
  - [ ] Test JDW world file (Phase 5.3 required)
- [x] **Validate**: VP5 deliverable works end-to-end ✅

**Complete Pipeline Working:**
```
JDA JSON → Jda3dLoader → SDF Tree → SdfEvaluator → HXSL Code → GeneratedShader → Rendering!
```

### VP5 Success Criteria:
- [x] All tests pass (JDA loader, SDF evaluator, JDW loader) ✅ (205/205 assertions passing!)
- [x] App loads JDA 3D asset from file ✅ (`jda.shape.sphere_basic.json`)
- [x] Renders loaded asset correctly (not hardcoded geometry) ✅ (sphere from JDA, not hardcoded box!)
- [x] Can switch between different JDA assets ✅ (VP6 Phase 6.1 - Asset Selector UI)
- [x] JDW scene graph loads ✅ (Phase 5.3 - Complete! All 14 tests passing!)
- [x] Existing features still work (camera, no regressions) ✅

**Core Goals Achieved:**
- ✅ JDA 3D JSON Parser (Phase 5.1)
- ✅ HXSL Code Generator (Phase 5.2)
- ✅ JDW Scene Loader (Phase 5.3) - **COMPLETE! 2025-11-27** ✅
- ✅ Integration & Rendering (Phase 5.4)

**Deliverable**: Load and display JDA/JDW assets (function over quality!)

**Test Assets Available**:
- `assets/jda3d/jda.shape.sphere_basic.json`
- `assets/jda3d/jda.shape.rounded_box.json`
- `assets/jda3d/jda.shape.pillar_repeat.json`
- `assets/jda2d/jda2d.mask.vignette_radial.json`
- `assets/jdw/world/world.demo_axium.json`

---

## VP2: Hot-Reload Shader System 📋 DEFERRED (after VP5)

**Goal**: VP1 + Load shaders from files, hot-reload on changes

**Status**: Deferred - Nice to have, but VP5 is core priority

### Tasks (High-Level):
- [ ] Create `shader/` domain
- [ ] Implement `ShaderManager.hx` (load, reload, watch files)
- [ ] Implement error handling (graceful fallback)
- [ ] Integrate with Main.hx
- [ ] Move RaymarchShader to external file
- [ ] Test hot-reload workflow

**Deliverable**: Live shader development environment

---

## VP3: AxiumSL Compiler 📋 DEFERRED (after VP5)

**Goal**: AxiumSL DSL → HXSL compilation

**Status**: Deferred - Nice to have, but VP5 is core priority

**Reference**: See `docs/project/axsl_project.md` for full implementation plan

---

## VP6: Editor UI 🎯 ACTIVE

**Goal**: VP5 + UI panels for asset browsing, selection, and inspection

**Status**: Phase 6.1 ✅ Complete, Phase 6.2 ✅ Complete, Phase 6.3 📋 Planned

**Why VP6 Now?**:
- VP5 works but requires hardcoded asset path
- Need UI to make JDA loading accessible
- Function over quality - simple panels first

### Domain: `ui/` (Heaps h2d UI)

#### Phase 6.1: Asset Selector Panel ✅ COMPLETE (2025-11-24)
- [x] **Design**: Asset selector UI layout
  - [x] Top panel with asset list/dropdown
  - [x] "Load Asset" button (integrated as clickable items)
  - [x] Display current loaded asset name
  - [x] Simple text-based UI (h2d.Text, h2d.Interactive)
- [x] **Implement**: `src/ui/AssetSelector.hx`
  - [x] `AssetSelector` class extending h2d.Object
  - [x] List available JDA files from `assets/jda3d/`
  - [x] Button list for selection (3 assets: Sphere, Rounded Box, Pillar Repeat)
  - [x] Callback when asset selected
  - [x] Hover effects for buttons
- [x] **Pre-generate Static Shaders**: `src/GenerateAllShaders.hx`
  - [x] Generate SphereShader.hx, RoundedBoxShader.hx, PillarRepeatShader.hx
  - [x] Workaround for HXSL compile-time limitation
  - [x] Enables runtime shader swapping without recompile
- [x] **Integrate**: `src/Main.hx`
  - [x] Initialize all 3 pre-compiled shaders at startup
  - [x] Add AssetSelector panel to s2d
  - [x] Handle asset selection callback
  - [x] Implement `switchShader()` - runtime shader swapping
  - [x] Update camera uniforms for new shader
- [x] **Fixes Applied**:
  - [x] Fixed HXSL inline lambda issues (manual code flattening)
  - [x] Fixed shader parameter access (Reflect.setField → direct property access via Dynamic)
  - [x] Fixed z-order issue (bitmap covering UI - now adds at index 0)
  - [x] Changed currentShader type from hxsl.Shader to Dynamic for property access
- [x] **Test**: Manual validation
  - [x] UI appears correctly ✅
  - [x] Can select different assets ✅
  - [x] Sphere → Rounded Box → Pillar Repeat switching works ✅
  - [x] Camera controls still work ✅
- [x] **Validate**: Phase 6.1 deliverable works ✅

#### Phase 6.2: Inspector Panel ✅ COMPLETE (2025-11-25)
- [x] **Design**: Inspector UI layout
  - [x] Right-side panel (positioned at right edge, 280px width)
  - [x] Display asset metadata (id, type, version)
  - [x] Display param_schema values with type, default, min, max
  - [x] Display materials with PBR properties (model, color RGB, roughness, metallic)
  - [x] Display variants with parameter overrides
  - [x] Display attach points with positions
  - [x] Read-only for now (editing comes later)
- [x] **Implement**: `src/ui/Inspector.hx`
  - [x] `Inspector` class extending h2d.Object
  - [x] `updateAssetInfo(doc)` - Populate panel with JDA metadata
  - [x] Parse and display all JDA document sections
  - [x] Dynamic parameter handling (float and vec3 types)
  - [x] Formatted text with section headers (=== Metadata ===, etc.)
  - [x] Semi-transparent background (0x1a1a1a, 0.95 alpha)
- [x] **Integrate**: Add to Main.hx alongside asset selector
  - [x] Initialize Inspector at (screenWidth - 290, 10)
  - [x] Call `updateAssetInfo()` on asset selection
  - [x] Pass full Jda3dDocument to inspector
- [x] **Fixes Applied**:
  - [x] Handle vec3 parameters (defaults can be [r,g,b] arrays)
  - [x] Proper JSON array parsing for HashLink (iterate, cast elements)
  - [x] Dynamic type checking for float vs vec3 parameters
- [x] **Test**: Manual validation
  - [x] Inspector appears at right side ✅
  - [x] Shows correct metadata for sphere_basic ✅
  - [x] Shows parameters (radius with min/max) ✅
  - [x] Shows materials (PBR color, roughness, metallic) ✅
  - [x] Shows variants (hero, default) ✅
  - [x] Shows attach points (bottom, top) ✅
  - [x] Updates when switching assets ✅
- [x] **Validate**: Inspector shows correct asset data ✅

#### Phase 6.3: Scene Graph Panel 📋 PLANNED
- [ ] **Requires**: VP5 Phase 5.3 (JDW Scene Loader)
- [ ] Tree view of worlds/layers/nodes
- [ ] Node selection
- [ ] Hierarchy display

### VP6 Success Criteria:
- [x] Asset selector UI working ✅
- [x] Can switch between JDA assets via UI ✅
- [x] Inspector shows asset metadata ✅
- [x] No hardcoded asset paths (user chooses via UI) ✅
- [x] Existing features still work (camera, rendering) ✅
- [ ] Scene graph panel (Phase 6.3 - requires JDW loader)

**Deliverable**: Simple editor UI for asset browsing and loading

---

## VP4: Scene System 📋 PLANNED

### VP4: Scene System (2-3 weeks)
- Multi-object scenes
- Scene graph with hierarchy
- Requires: VP5 Phase 5.3 (JDW Scene Loader)

---

## AxiumSL Compiler Development 📋 PARALLEL TRACK

**Status**: Specifications complete, implementation not started

**Can start**: After VP1 or in parallel (independent track)

**Pipeline**: `.axsl` source → **Parser** → IR → **HXSL Generator** → `.hxsl` output

### Phase 0: Foundation (3-5 days)
- [ ] Create directory structure
  - [ ] `src/axiumsl/parser/`
  - [ ] `src/axiumsl/ir/`
  - [ ] `src/axiumsl/backend/`
  - [ ] `tests/axiumsl/`
  - [ ] `examples/shaders/`
- [ ] Define core IR types (`src/axiumsl/ir/Types.hx`)
  - [ ] `AxType` enum (TFloat, TVec2, TVec3, TVec4, TMat3, TMat4, TBool)
  - [ ] `AxExpr` enum (expressions)
  - [ ] `AxStmt` enum (statements)
  - [ ] `AxBinOp`, `AxUnaryOp` enums
- [ ] Define shader structures (`src/axiumsl/ir/Shader.hx`)
  - [ ] `AxUniform`, `AxParam`, `AxFunction` typedefs
  - [ ] `AxShader` typedef
  - [ ] `AxShaderKind` enum
- [ ] Create error handling (`src/axiumsl/Error.hx`)
  - [ ] `AxError` enum
  - [ ] `ErrorReporter` class
- [ ] Setup test framework
  - [ ] Test build config
  - [ ] Test runner
  - [ ] Test utilities

### Phase 1: Parser (AxiumSL → AST) (7-10 days)
- [ ] **Lexer/Tokenizer** (`src/axiumsl/parser/Lexer.hx`)
  - [ ] Define `Token` type (`src/axiumsl/parser/Token.hx`)
  - [ ] Tokenize keywords (shader, uniform, fn, entry, fragment, let, return, if, else, for, break)
  - [ ] Tokenize types (float, bool, vec2, vec3, vec4, mat3, mat4)
  - [ ] Tokenize literals (float, bool, identifiers)
  - [ ] Tokenize operators (+, -, *, /, ==, !=, <, >, <=, >=, &&, ||, !)
  - [ ] Tokenize punctuation ({, }, (, ), ;, :, ,, ., ..)
  - [ ] Handle whitespace and comments (//)
  - [ ] **Test**: Lexer tests (`tests/axiumsl/LexerTest.hx`)
- [ ] **AST Definitions** (`src/axiumsl/parser/Ast.hx`)
  - [ ] Define AST node types (AstShader, AstFunction, AstUniform)
  - [ ] Include source position info (line, column)
- [ ] **Parser** (`src/axiumsl/parser/Parser.hx`)
  - [ ] Recursive descent parser (EBNF grammar)
  - [ ] Parse shader declaration
  - [ ] Parse uniform declarations
  - [ ] Parse function declarations
  - [ ] Parse entry declarations
  - [ ] Parse statements (let, assign, return, if, else, for, break)
  - [ ] Parse expressions (precedence: logic → comparison → arithmetic)
  - [ ] Parse vector constructors (vec2, vec3, vec4)
  - [ ] Parse function calls
  - [ ] Parse swizzles (.x, .xy, .xyz)
  - [ ] Error recovery and reporting
  - [ ] **Test**: Parser tests (`tests/axiumsl/ParserTest.hx`)
- [ ] **Validate**: Parse example shaders from spec

### Phase 2: IR Construction (AST → IR) (5-7 days)
- [ ] **AST → IR Builder** (`src/axiumsl/ir/Builder.hx`)
  - [ ] Convert AstShader → AxShader
  - [ ] Convert AST types → AxType
  - [ ] Convert AST expressions → AxExpr
  - [ ] Convert AST statements → AxStmt
  - [ ] Build AxFunction from AstFunction
  - [ ] **Test**: Builder tests (`tests/axiumsl/BuilderTest.hx`)
- [ ] **IR Validator** (`src/axiumsl/ir/Validator.hx`)
  - [ ] Check uniforms declared before use
  - [ ] Check functions declared before called
  - [ ] Check variables declared before use
  - [ ] Verify entry function exists with correct signature
  - [ ] **Test**: Validator tests (`tests/axiumsl/ValidatorTest.hx`)
- [ ] **JSON Serialization**
  - [ ] `AxShader.toJson()` method
  - [ ] `AxShader.fromJson()` method
  - [ ] **Test**: Serialize/deserialize roundtrip

### Phase 3: HXSL Backend (IR → HXSL) (7-10 days)
- [ ] **HXSL Code Generator** (`src/axiumsl/backend/Hxsl.hx`)
  - [ ] Main entry point: `generate(shader: AxShader): String`
  - [ ] Generate HXSL class structure
  - [ ] Convert AxType → HXSL types (Float, Vec2, Vec3, Vec4, Mat3, Mat4, Bool)
  - [ ] Generate uniform declarations (@param var)
  - [ ] Generate helper functions
  - [ ] Generate entry fragment function
  - [ ] **Test**: Generator tests (`tests/axiumsl/HxslGenTest.hx`)
- [ ] **Expression Code Generation**
  - [ ] Binary operators (+, -, *, /, <, >, ==, !=, &&, ||)
  - [ ] Unary operators (-, +, !)
  - [ ] Function calls (length, normalize, dot, etc.)
  - [ ] Vector constructors (vec2(), vec3(), vec4())
  - [ ] Swizzles (.x, .xy, .xyz, .xyzw)
  - [ ] Variable references
- [ ] **Statement Code Generation**
  - [ ] Let declarations (var in HXSL)
  - [ ] Assignments
  - [ ] Return statements
  - [ ] If/else blocks
  - [ ] For loops (range → HXSL for)
  - [ ] Break statements
- [ ] **Code Templates** (`src/axiumsl/backend/Template.hx`)
  - [ ] HXSL shader class template
  - [ ] Fragment entry wrapper
- [ ] **Validate**: Generated HXSL compiles with Heaps

### Phase 4: Compiler Integration (3-5 days)
- [ ] **Main Compiler** (`src/axiumsl/Compiler.hx`)
  - [ ] Pipeline: source → Lexer → Parser → Builder → Validator → Generator
  - [ ] Error collection and reporting
  - [ ] `compile(source: String): Result<String, Array<AxError>>`
- [ ] **Example Shaders** (`examples/shaders/`)
  - [ ] `sphere.axsl` - Simple SDF sphere
  - [ ] `csg_demo.axsl` - CSG operations
  - [ ] `bobling.axsl` - Complex shader
- [ ] **Integration Tests** (`tests/axiumsl/IntegrationTest.hx`)
  - [ ] End-to-end: .axsl → HXSL → Heaps rendering

**Reference**: `docs/project/axsl_project.md` for detailed implementation plan

---

## Immediate Next Actions

### Completed (2025-11-24):
1. ✅ VP1 Phase 1.1: CameraState (TDD, 9 tests, 31 assertions)
2. ✅ VP1 Phase 1.2: CameraController (TDD, 8 tests, 16 assertions)
3. ✅ VP1 Phase 1.3: Main.hx integration (h2d.Interactive, full controls)
4. ✅ Fixes: LMB support, box SDF, gimbal lock prevention
5. ✅ Runtime validation: Smooth 170° orbit, infinite horizontal rotation
6. ✅ CHANGELOG.md updated
7. ✅ TODO.md updated

### Next: VP5 (JDA/JDW Loader) - ACTIVE

**Decision Made**: VP5 is THE core system, VP2/VP3 are deferred
**Reasoning**: JDA/JDW loading is central, rendering is secondary
**Approach**: TDD + function over quality (first iteration)
**DevOps**: Jump phases to deliver core functionality first

---

## Important Notes

### SDF Raymarching Advantages (Key Insight - 2025-11-24)

**Real-time viewport** (current):
- 1280x720 @ 60 FPS
- Interactive editing and manipulation
- Immediate feedback

**Offline high-resolution rendering** (future VP):
- 4K-10K resolution (10240x5760+)
- Render slowly frame-by-frame → export to video
- **Hyper-realistic output** with arbitrarily high quality
- No mesh artifacts, infinite detail from mathematical surfaces
- Perfect for:
  - Cinematics and animation
  - Architectural visualization
  - Product renders
  - Art/generative content

**This is the hidden power of SDF:**
- Edit in real-time (720p-1080p)
- Render offline (4K-10K) → photorealistic
- Same scene, same code, different resolution/quality trade-off
- Pure math scales infinitely (unlike meshes with fixed vertex count)

**Future VP candidate**: VP7 - Offline Renderer
- Frame sequence export
- Arbitrary resolution support
- Multi-sample anti-aliasing (4x, 8x, 16x)
- Path tracing mode (GI, caustics, etc.)
- Video composition pipeline

### Development Principles:
- **VP (Viable Product)**: Every phase delivers working product
- **TDD**: Test first, implement, refactor
- **DDD**: Clear domain separation (orchestrator pattern)
- **KISS**: Simple over complex, functions over classes when stateless
- **AI-First**: Clear structure for future AI developers
- **Math > Data**: Procedural/functional over asset-heavy

### File Structure:
```
src/
  Main.hx              # Orchestrator only
  camera/              # Camera domain (VP1)
    CameraState.hx
    CameraController.hx
  shader/              # Shader domain (VP2)
  scene/               # Scene domain (VP4)
  loader/              # Loading domain (VP5)
  axiumsl/             # AxiumSL compiler (VP3)
  utils/               # Shared utilities
```

### Testing:
- Tests mirror src/ structure
- Run tests: `haxe tests/build.hxml`
- All tests must pass before marking VP complete

### References:
- Overall plan: `docs/project/axiumforge_editor_project.md`
- AxiumSL plan: `docs/project/axsl_project.md`
- Progress tracking: `docs/project/progress.md`
- Specs: `docs/AxiumSLang.md`, `docs/axslv01.md`, `docs/jdw_sdf_csg_world_standard_v_0.md`

---

## 🎉 VP1 Complete! Now Starting VP5!

**Completed**: Interactive 3D SDF viewer with full orbit camera (2025-11-24)
- ✅ 17 tests, 47 assertions, 100% passing
- ✅ Smooth 170° vertical + infinite horizontal rotation
- ✅ Gimbal lock prevention
- ✅ Touchpad-friendly controls
- ✅ Real-time 60 FPS with pure SDF raymarching

**Active Now: VP5 - JDA/JDW Loader (CORE SYSTEM)**
- 🎯 Load JDA 3D assets from JSON
- 🎯 Generate HXSL code from SDF tree
- 🎯 Replace hardcoded box with loaded assets
- 🎯 Basic JDW scene graph support
- 🎯 Function over quality (first iteration!)

**VP2/VP3 Deferred**: Nice to have, but VP5 is the core functionality
