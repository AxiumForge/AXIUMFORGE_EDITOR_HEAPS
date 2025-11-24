# Changelog

All notable changes to AxiumForge Editor (Heaps) will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Phase 1 - MVP Viewer (In Progress)

#### Added (2025-11-24)
- **Project Setup**
  - Created `src/` directory structure
  - Build configuration (`build.hxml`) for HashLink compilation
  - Binary output directory (`bin/`)
  - Watch script (`watch.sh`) for development workflow

- **Dependencies**
  - Heaps 2.1.0 game engine (verified via haxelib)
  - HashLink 1.15.0 runtime (installed via brew)
  - hlsdl 1.15.0 for SDL graphics output

- **Core Application**
  - `Main.hx`: Heaps app skeleton extending `hxd.App`
  - Fullscreen rendering via `h2d.Bitmap` with custom shader
  - Window setup (1280x720, "Axium Viewer MVP" title)
  - Camera system with position and target (static for now)

- **SDF Raymarching Shader** (`RaymarchShader.hx`)
  - Pure HXSL shader extending `h3d.shader.Base2d`
  - Real SDF raymarching implementation (sphere tracing)
  - SDF sphere primitive: `length(p) - 1.0`
  - Ray direction calculation from camera parameters
  - Surface normal computation via gradient (central difference method)
  - Simple directional lighting (diffuse + ambient)
  - Sky background with gradient
  - **No meshes, no vertices - 100% shader-based rendering!**

- **Documentation & Project Management**
  - Project documentation (CLAUDE.md, TODO.md, CHANGELOG.md)
  - Initial project structure planning
  - JDW/JDA specification (v0.1) for world/asset description
  - AxiumSL specification (v0.1) - shader DSL with EBNF grammar
  - **VP (Viable Product) Development Approach**
    - `docs/project/axiumforge_editor_project.md` - Main project plan
    - `docs/project/axsl_project.md` - AxiumSL compiler implementation plan
    - `docs/project/progress.md` - VP progress tracking
  - **Working Memory System**
    - TODO.md as working memory/focus document
    - Workflow: TODO → work → mark done → update docs → clear → new tasks
  - **AI-First Architecture**
    - TDD (Test-Driven Development) workflow
    - DDD (Domain-Driven Design) with Orchestrator pattern
    - KISS principle (simple over complex)
    - Clear domain separation for future AI developers

- **Asset Library** (Codex contributions)
  - **JDA3D Assets** (`assets/jda3d/`)
    - `jda.shape.sphere_basic.json` - Basic SDF sphere with param schema, variants, attach points
    - `jda.shape.rounded_box.json` - Rounded box (filleted cube)
    - `jda.shape.pillar_repeat.json` - Repeated pillar with domain repetition
  - **JDA2D Assets** (`assets/jda2d/`)
    - `jda.sdf2d.grass_pattern.json` - 2D SDF pattern for material overlays
  - **JDW World Examples** (`assets/jdw/`)
    - `world.demo_axium.json` - Complete JDW document demonstrating:
      - Inline SDF (ground plane)
      - JDA asset references (hero node)
      - Materials with 2D SDF overlays
      - Cascading defaults
  - **AxiumSL Examples** (`assets/axsl/`)
    - `sdf_raymarch_basic.axsl` - AxiumSL source with CSG operations
    - `sdf_raymarch_basic.hxsl` - Compiled HXSL output (reference implementation)
  - **Value**: Complete end-to-end examples ready for testing VP5 (JDW Loader) and AxiumSL compiler validation

#### Verified
- **Build System**: Project compiles successfully with `haxe build.hxml`
- **Binary Output**: `bin/viewer.hl` generated correctly (1280x720 window)
- **Dependencies**: All Haxe libraries resolved (heaps, hlsdl)
- **Shader Compilation**: HXSL shader compiles without errors

- **VP1 Camera System** (Phase 1.1 Complete ✅ 2025-11-24)
  - **Test Framework**: utest-based TDD infrastructure
    - `tests/TestMain.hx` - Test runner
    - `tests/build.hxml` - Test compilation config
    - `tests/camera/CameraStateTest.hx` - 9 comprehensive test cases (31 assertions, 100% passing)
  - **CameraState Data Structure** (`src/camera/CameraState.hx`)
    - Immutable enum-based state: `Orbit(target, distance, yaw, pitch)`
    - Spherical coordinates for 3D orbit camera
    - Pure functional design (no side effects)
  - **CameraStateTools Utilities** (`src/camera/CameraStateTools.hx`)
    - `computePosition()` - Spherical to cartesian conversion
    - State accessors: `getTarget()`, `getDistance()`, `getYaw()`, `getPitch()`
    - State updates: `updateYaw()`, `updatePitch()`, `updateDistance()`, `updateTarget()`
    - Interactive helpers: `addYaw()`, `addPitch()` (with clamping), `multiplyDistance()`, `panTarget()`
    - All functions pure (return new state, no mutation)
  - **Test Coverage**: Position computation, yaw/pitch rotation, distance zoom, target pan, state updates

#### In Progress
- VP1 Phase 1.2: CameraController input handling (MMB drag, wheel zoom, Shift+MMB pan)
- Runtime testing (`hl bin/viewer.hl` execution)

#### Next Steps (Remaining for MVP)
- Mouse and keyboard input handling for camera controls
- Interactive camera manipulation (MMB orbit, wheel zoom, Shift+MMB pan)
- Runtime execution testing and validation
- Optional: Ground plane/grid for spatial reference

#### Future Enhancements (Phase 2+)
- Additional SDF primitives (box, torus, capsule, cylinder)
- SDF CSG operations (union, subtraction, intersection, smooth blend)
- Multiple SDF shapes in single scene
- JDA asset loading system

---

## Future Phases

### Phase 2 - JDA Gallery
- Multiple JDA assets selectable via UI
- Asset switching without closing app
- Smart camera positioning per asset

### Phase 3 - JDW World Viewer
- Full JDW document reading and validation
- Complete scene graph (worlds/layers/nodes)
- Camera presets from JDW

### Phase 4 - Editor UI
- Scenegraph panel with tree view
- Inspector for editing properties
- JDW hot-reload and save

### Phase 5 - Raymarching & Tools
- Full HXSL raymarching backend
- SDF�Mesh export
- Baking pipelines
