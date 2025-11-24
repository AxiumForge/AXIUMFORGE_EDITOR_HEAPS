# TODO - AxiumForge Editor & AxiumSL

> **Working Memory** - Current focus and active tasks
>
> **Workflow**: Work from this file → Mark done → Update CHANGELOG + project docs → Clear and add new tasks

---

## 🎯 Current Focus

**Active VP**: VP1 - Interactive Viewer
**Goal**: Add camera controller with orbit/zoom/pan controls
**Timeline**: 1 week
**Approach**: TDD + Domain-Driven Design

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

## VP1: Interactive Viewer 🔨 IN PROGRESS

**Goal**: VP0 + Interactive camera controls (orbit, zoom, pan)

**Status**: Ready to implement (0%)

### Domain: `camera/` (TDD Workflow)

#### Phase 1.1: CameraState - Data Structure
- [ ] **Test**: `tests/camera/CameraStateTest.hx`
  - [ ] Test orbit state initialization
  - [ ] Test position computation from spherical coords
  - [ ] Test yaw/pitch/distance updates
  - [ ] Test target positioning
- [ ] **Implement**: `src/camera/CameraState.hx`
  - [ ] Define `CameraState` enum with `Orbit` variant
  - [ ] Implement `computePosition()` - spherical to cartesian
  - [ ] Implement state update methods
- [ ] **Validate**: All CameraState tests pass ✅

#### Phase 1.2: CameraController - Input Handling
- [ ] **Test**: `tests/camera/CameraControllerTest.hx`
  - [ ] Test MMB drag updates yaw/pitch
  - [ ] Test mouse wheel updates distance
  - [ ] Test Shift+MMB drag updates target
  - [ ] Test pitch clamping (-85° to -5°)
  - [ ] Test distance clamping (min/max)
- [ ] **Implement**: `src/camera/CameraController.hx`
  - [ ] Setup input event handling (Heaps event system)
  - [ ] Implement orbit rotation (MMB drag → yaw/pitch)
  - [ ] Implement zoom (wheel → distance)
  - [ ] Implement pan (Shift+MMB → target)
  - [ ] Apply constraints (pitch clamp, distance clamp)
- [ ] **Validate**: All CameraController tests pass ✅

#### Phase 1.3: Integration
- [ ] **Update**: `src/Main.hx`
  - [ ] Import CameraController
  - [ ] Initialize controller in `init()`
  - [ ] Wire input events to controller
  - [ ] Call `controller.update(dt)` in update loop
  - [ ] Apply camera state to `s3d.camera`
  - [ ] Update shader uniforms with camera state
- [ ] **Test**: Manual validation
  - [ ] Compile: `haxe build.hxml`
  - [ ] Run: `hl bin/viewer.hl`
  - [ ] Test orbit (MMB drag)
  - [ ] Test zoom (wheel)
  - [ ] Test pan (Shift+MMB)
  - [ ] Verify smooth, responsive controls
- [ ] **Validate**: VP1 deliverable works end-to-end ✅

### VP1 Success Criteria:
- ✅ All tests pass (`haxe tests/build.hxml`)
- ✅ App compiles without errors
- ✅ Camera responds to mouse input smoothly
- ✅ Controls feel natural (Blender-style)
- ✅ Existing features still work (no regressions)

---

## VP2: Hot-Reload Shader System 📋 PLANNED

**Goal**: VP1 + Load shaders from files, hot-reload on changes

**Status**: Not started (planned after VP1)

### Tasks (High-Level):
- [ ] Create `shader/` domain
- [ ] Implement `ShaderManager.hx` (load, reload, watch files)
- [ ] Implement error handling (graceful fallback)
- [ ] Integrate with Main.hx
- [ ] Move RaymarchShader to external file
- [ ] Test hot-reload workflow

**Deliverable**: Live shader development environment

---

## VP3-6: Future VPs 📋 PLANNED

### VP3: AxiumSL Compiler (4-6 weeks)
- AxiumSL → HXSL compilation
- See: `docs/project/axsl_project.md`

### VP4: Scene System (2-3 weeks)
- Multi-object scenes
- Scene graph with hierarchy

### VP5: JDW/JDA Loader (3-4 weeks)
- Load world/asset files
- Standards compliance

### VP6: Editor UI (4-6 weeks)
- Scene graph panel
- Inspector panel
- Full editor interface

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

### Now (This Session):
1. ✅ Updated TODO.md with VP approach
2. ⏳ **Start VP1 Phase 1.1** (when approved)
   - Create `src/camera/` and `tests/camera/` directories
   - Write CameraState tests
   - Implement CameraState
3. Continue through VP1 phases sequentially

### After VP1 Complete:
1. Update CHANGELOG.md with VP1 completion
2. Update `docs/project/progress.md`
3. Clear completed VP1 tasks from TODO.md
4. Add VP2 detailed tasks to TODO.md

---

## Important Notes

### Development Principles:
- **VP (Viable Product)**: Every phase delivers working product
- **TDD**: Test first, implement, refactor
- **DDD**: Clear domain separation (orchestrator pattern)
- **KISS**: Simple over complex, functions over classes when stateless
- **AI-First**: Clear structure for future AI developers

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

## Ready to Start VP1? 🚀

**Next task**: Create camera domain directories and write first tests

**Command to begin**: "Start VP1 Phase 1.1"

**ETA**: 2-3 days for VP1 complete implementation
