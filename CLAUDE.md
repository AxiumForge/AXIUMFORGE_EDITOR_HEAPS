# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**AxiumForge Editor (Heaps)** is a runtime 3D/2D viewer and editor for JDW (JSON Description of Worlds) and JDA (JSON Description of Assets) files. It's built with Haxe and the Heaps game engine, using HXSL for raymarching SDF/CSG content.

This project exists because SDF assets cannot be viewed in traditional editors - a running system is required. The first MVP targets the simplest possible implementation using Heaps and HashLink.

## Tech Stack

- **Language**: Haxe
- **Engine**: Heaps 2.1.0 (h3d for 3D, h2d for 2D/UI)
- **Shaders**: HXSL (Heaps' shader language) for fullscreen raymarching
- **Runtime**: HashLink (hl) for desktop, with potential JS/WebGL support
- **Data Formats**: JDW (world descriptions) and JDA (asset descriptions) in JSON/JSONC
- **Dependencies**: format library (via haxelib)

## Development Commands

### Build & Run

Since no build files exist yet, typical Heaps/Haxe workflow will be:

```bash
# Compile for HashLink (desktop runtime)
haxe -main Main -lib heaps -hl output.hl

# Run with HashLink
hl output.hl

# Compile for JavaScript/WebGL
haxe -main Main -lib heaps -js output.js

# Format code (if formatter is configured)
haxelib run formatter -s src/
```

**Note**: HashLink (hl) is not currently installed. Install via: `brew install hashlink` (macOS) or from https://hashlink.haxe.org

### Project Structure (Planned)

The codebase will follow this module layout:

```
axium_editor_hx/
  src/
    axium/jdw/            # JDW data model, JSON parser/validator
    axium/jda/            # JDA data model, asset loader
    axium/runtime/heaps/  # JDW → Heaps scene + raymarch backend
    axium/editor/heaps/   # Editor UI and tools
```

## Architecture

### Core Components

1. **axium.jdw** - JDW Document System
   - Haxe types for the complete JDW specification
   - Loader for `.jdw.json` and `.jsonc` files
   - Validator for IDs, references, and cascading defaults

2. **axium.jda** - JDA Asset System
   - Types for JDA schema: sdf_tree, variants, attach_points, dependencies
   - Asset loader and registry

3. **axium.runtime.heaps** - Runtime Layer
   - Loads JDW documents and builds h3d scene objects
   - Manages raymarching passes via HXSL
   - Scene component tags: `JdwWorldTag`, `JdwLayerTag`, `JdwNodeTag`, `JdwTransform`

4. **axium.editor.heaps** - Editor Interface
   - Scenegraph panel (Worlds → Layers → Nodes)
   - Inspector (node properties, transforms, materials)
   - Asset browser (materials, shaders, JDA, textures)
   - SDF tree editor
   - Validator and log output

### Raymarching Backend

- Fullscreen HXSL render pass for SDF/CSG visualization
- Input: camera uniforms, global/default raymarch settings
- SDF/CSG data packed into buffers (using `h3d.Buffer` as UBO/SSBO-like structures)
- 2D-SDF can be used as textures or generated HXSL code

### Build Pipeline

1. Load JDW document
2. Resolve cascading defaults
3. Build Heaps scene graph
4. Sync runtime (editor mode)
5. Hot-reload on file changes

## Development Phases

### Phase 1 - AxiumViewer MVP (Current Target)

**Goal**: Single program that loads one JDA 3D asset, displays it in a Heaps window, and provides Blender/Godot-style camera controls.

**Features**:
- Heaps app skeleton (`AxiumViewerMvp` main class)
- Minimal JDA loader (read one asset, compute bounds)
- Camera setup with smart initial positioning:
  - Target: `(0,0,0)` or asset center
  - Distance: computed from bounding box (e.g., radius × 2)
  - Initial angles: yaw=45°, pitch=-45°
  - Guarantees asset is visible on open
- Orbit camera controls:
  - MMB drag: rotate (yaw/pitch with clamping)
  - Mouse wheel: zoom (adjust distance)
  - Shift+MMB: pan (move target in camera's local XZ plane)
- Rendering: Simple placeholder mesh or JDA→Mesh conversion (raymarching deferred to later phase)

### Phase 2 - JDA Gallery & Basic JDW Integration

- Multiple JDA assets selectable via UI
- Simple h2d overlay for asset switching
- First JDW document referencing JDA nodes
- Auto-computed camera start position per asset

### Phase 3 - JDW World Viewer

- Full JDW document reading and validation
- Complete scene graph building (worlds/layers/nodes)
- Camera presets from JDW
- Orbit controls around selected nodes

### Phase 4 - Editor UI

- Full scenegraph panel with tree view
- Inspector for editing properties
- SDF tree editor (text/structure initially)
- JDW hot-reload and save functionality

### Phase 5 - Raymarching, Baking & Tools

- Full HXSL raymarching backend
- SDF→Mesh export (marching cubes/dual contouring)
- Pipelines: image→SDF2D, SDF2D→SDF3D, SDF3D→JDA
- Theme system with live updates

## Important Notes

- **Language**: User instructions and communication are in Danish; all code, comments, and repository text must be in English
- **Documentation**: Update CHANGELOG and TODO as work progresses (these files don't exist yet but should be created)
- **Coordinate System**: Heaps uses Y-up by default
- **JDW/JDA Standard**: Full specification linked in `docs/jdw_sdf_csg_world_standard_v_0.md` (symlink to external repo)

## Asset Library

**Codex has created a complete example ecosystem in `assets/`:**

### JDA Assets (Digital Assets)

**3D SDF Assets** (`assets/jda3d/`):
- `jda.shape.sphere_basic.json` - Basic SDF sphere with param schema, variants, attach points
- `jda.shape.rounded_box.json` - Rounded box (filleted cube)
- `jda.shape.pillar_repeat.json` - Repeated pillar using domain repetition

**2D SDF Assets** (`assets/jda2d/`):
- `jda.sdf2d.grass_pattern.json` - 2D SDF pattern for material overlays

### JDW Worlds

**Complete World Example** (`assets/jdw/world/`):
- `world.demo_axium.json` - Full JDW document with:
  - Ground plane (inline SDF)
  - Hero node (references JDA asset)
  - Materials with 2D SDF overlays
  - Cascading defaults demonstration
  - References all JDA3D and JDA2D assets

### AxiumSL Shaders

**Working AxiumSL Example** (`assets/axsl/examples/`):
- `sdf_raymarch_basic.axsl` - AxiumSL source with CSG (sphere with box subtraction)
- `sdf_raymarch_basic.hxsl` - Compiled HXSL output (reference implementation)

**These assets demonstrate:**
- ✅ Complete JDW/JDA workflow
- ✅ SDF primitives and CSG operations
- ✅ Material system with 2D SDF overlays
- ✅ AxiumSL → HXSL compilation example
- ✅ Ready-to-use test cases for VP5 (JDW Loader)

## References

- Main design doc: `docs/axiumeditor_heaps_HXSL.md` (comprehensive 1:1 mapping from Rust/Bevy version)
- Project start guide: `start_mvp.md` (Phase 1 requirements in Danish)
- **Project Management**:
  - `docs/project/axiumforge_editor_project.md` - VP development approach
  - `docs/project/axsl_project.md` - AxiumSL compiler implementation plan
  - `docs/project/progress.md` - Progress tracking
  - `TODO.md` - **TRUTH in the moment** (working memory)
- **Specifications**:
  - `docs/jdw_sdf_csg_world_standard_v_0.md` - JDW/JDA standard
  - `docs/AxiumSLang.md` - AxiumSL specification
  - `docs/axslv01.md` - AxiumSL v0.1 MVP grammar
- Heaps documentation: https://heaps.io/documentation/
- Heaps API: https://heaps.io/api/
- HXSL shader reference: Available in Heaps h3d/hxsl module

## Development Principles

- **Haxe as Meta Language**: Leverage multi-target (HL, Python, JS, C++). Targets can be combined in tool design.
- **AI-First Paradigm**: Think of future AI developers using these systems. RAG-friendly documentation.
- **TODO.md = TRUTH**: Always work from TODO.md (working memory). It's not redundancy - it's focus.
  - Workflow: Project docs → TODO.md → Work → Mark done → Update CHANGELOG/docs → Clear → New tasks
  - TODO.md protects against crashes and context loss
- In @RAG.md is indexed docs references and everytime you make a new docs search you add the search to the RAG.md with target link remote or local a like
- screenshots by @screenshot.sh to @sc/
- Shared docs is now in @docs/shared