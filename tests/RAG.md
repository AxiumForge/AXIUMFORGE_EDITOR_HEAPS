# RAG.md - Documentation Search Index

Auto-generated index of external documentation searches and references.
This file helps AI assistants and developers quickly find relevant documentation.

**Last updated**: 2025-11-24

---

## Heaps Engine (https://heaps.io)

### API References
- [h3d.Vector](https://heaps.io/api/h3d/Vector.html) - 3D vector math and transforms
  - **Used in**: `src/camera/CameraState.hx`, `src/camera/CameraStateTools.hx`
  - **Purpose**: Camera target position, position computation
  - **Date**: 2025-11-24

- [hxd.App](https://heaps.io/api/hxd/App.html) - Main application class
  - **Used in**: `src/Main.hx`
  - **Purpose**: Application skeleton, window setup, render loop
  - **Date**: 2025-11-24

- [h3d.shader.Base2d](https://heaps.io/api/h3d/shader/Base2d.html) - 2D shader base class
  - **Used in**: `src/RaymarchShader.hx`
  - **Purpose**: HXSL fullscreen shader for SDF raymarching
  - **Date**: 2025-11-24

- [h2d.Bitmap](https://heaps.io/api/h2d/Bitmap.html) - 2D bitmap rendering
  - **Used in**: `src/Main.hx`
  - **Purpose**: Fullscreen quad for shader rendering
  - **Date**: 2025-11-24

- [h3d.Camera](https://heaps.io/api/h3d/Camera.html) - Camera transforms and projection
  - **Status**: Pending for VP1 Phase 1.3
  - **Purpose**: Integration with CameraState system
  - **Date**: 2025-11-24

- [hxd.Window](https://heaps.io/api/hxd/Window.html) - Window management
  - **Used in**: `src/Main.hx`
  - **Purpose**: Window title, resolution setup
  - **Date**: 2025-11-24

### Guides & Documentation
- [HXSL Shader Language](https://heaps.io/documentation/hxsl.html) - Heaps shader language
  - **Used in**: `src/RaymarchShader.hx`
  - **Purpose**: SDF raymarching shader implementation
  - **Date**: 2025-11-24

- [Getting Started](https://heaps.io/documentation/installation.html) - Heaps setup guide
  - **Used in**: Project setup, HashLink installation
  - **Date**: 2025-11-24

---

## Haxe Standard Library (https://api.haxe.org)

### Core Types
- [Math](https://api.haxe.org/Math.html) - Mathematical functions
  - **Used in**: `src/camera/CameraStateTools.hx`
  - **Purpose**: Trigonometry (sin, cos) for spherical coordinate conversion
  - **Date**: 2025-11-24

### Future References
- [haxe.Json](https://api.haxe.org/Json.html) - JSON parsing
  - **Status**: Pending for VP5 (JDW/JDA Loader)
  - **Purpose**: Parse .jdw.json and .jda.json asset files
  - **Date**: 2025-11-24

---

## Testing Frameworks

### utest (https://lib.haxe.org/p/utest/)
- [utest Library](https://lib.haxe.org/p/utest/) - Unit testing framework for Haxe
  - **Used in**: `tests/TestMain.hx`, `tests/camera/CameraStateTest.hx`
  - **Purpose**: TDD test infrastructure (replaced haxe.unit, not available in Haxe 4)
  - **Date**: 2025-11-24
  - **Migration**: haxe.unit → utest (TestCase → Test, assertEquals → Assert.equals)

- [utest.Test](https://github.com/haxe-utest/utest) - Base test class
  - **Used in**: `tests/camera/CameraStateTest.hx`
  - **Purpose**: Test case base class
  - **Date**: 2025-11-24

- [utest.Assert](https://github.com/haxe-utest/utest) - Assertion methods
  - **Used in**: All test files
  - **Purpose**: Test assertions (equals, isTrue, floatEquals)
  - **Date**: 2025-11-24

---

## Project-Specific Documentation

### Local References
- `docs/project/axiumforge_editor_project.md` - VP development plan
  - **Purpose**: 7-phase VP roadmap, TDD workflow, DDD architecture
  - **Date**: 2025-11-24

- `docs/jdw_sdf_csg_world_standard_v_0.md` - JDW/JDA specification (symlink)
  - **Purpose**: World and asset description format (JSON-based)
  - **Status**: Pending for VP5 (JDW Loader)

- `docs/AxiumSLang.md` - AxiumSL shader DSL specification
  - **Purpose**: Custom shader language with EBNF grammar
  - **Status**: Pending for VP3 (AxiumSL Compiler)

- `CLAUDE.md` - Project instructions for Claude Code
  - **Purpose**: Tech stack, architecture, development workflow
  - **Date**: 2025-11-24

- `CHANGELOG.md` - Project changelog
  - **Purpose**: Track all notable changes (Keep a Changelog format)
  - **Date**: 2025-11-24 (VP1 Phase 1.1 complete)

- `TODO.md` - Working memory (TRUTH in the moment)
  - **Purpose**: Current tasks, crash protection, focus management
  - **Date**: 2025-11-24

---

## External Tools & Dependencies

### HashLink Runtime (https://hashlink.haxe.org)
- [HashLink](https://hashlink.haxe.org) - Native runtime for Haxe
  - **Used in**: Build system (`-hl` target)
  - **Purpose**: Desktop runtime for AxiumForge Editor
  - **Installation**: `brew install hashlink`
  - **Date**: 2025-11-24

### Haxelib Package Manager
- [hlsdl](https://lib.haxe.org/p/hlsdl/) - SDL bindings for HashLink
  - **Used in**: Graphics output
  - **Purpose**: SDL graphics backend for Heaps on HashLink
  - **Date**: 2025-11-24

---

## Search History & Context

### VP1 Camera System (2025-11-24)
- **Goal**: Implement 3D orbit camera with Blender-style controls
- **Researched**:
  - Spherical coordinate systems (yaw/pitch/distance)
  - h3d.Vector API for camera position math
  - Immutable state patterns in Haxe (enum + tools class)
  - utest framework migration from haxe.unit
- **Result**: Phase 1.1 complete (CameraState + tests, 31/31 passing)

---

## Notes

- **Auto-update**: This file is updated whenever WebSearch or WebFetch tools are used
- **Format**: `[Title](URL)` for remote links, `path/to/file` for local docs
- **Status tags**: "Used in", "Pending for", "Status" indicate implementation state
- **Dates**: ISO format (YYYY-MM-DD) tracks when reference was added/used
