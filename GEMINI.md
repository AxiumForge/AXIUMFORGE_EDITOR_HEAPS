# AXIUMFORGE_EDITOR_HEAPS - Gemini Context

This document provides an overview of the `AXIUMFORGE_EDITOR_HEAPS` project, intended for use as instructional context for Gemini.

## Project Overview

AxiumForge Editor (Heaps/Haxe edition) is a runtime-first viewer/editor designed for JDW worlds and JDA SDF assets. It incorporates HXSL raymarching and supports the AxiumSL Domain Specific Language (DSL). The project serves as a foundation for a powerful 3D editor.

## Key Technologies

*   **Heaps:** A professional 2D/3D gaming engine powered by Haxe.
*   **Haxe:** An open source high-level strictly-typed programming language.
*   **JDW (JDA World):** A standard for defining 3D worlds.
*   **JDA (JDA SDF Assets):** A standard for Signed Distance Function (SDF) assets.
*   **HXSL:** Heaps Shading Language for raymarching.
*   **AxiumSL DSL:** A Domain Specific Language for defining assets and shaders.

## Building and Running

The project can be built and run using the following commands:

```bash
# Build for HashLink target
haxe build.hxml

# Run the viewer (HashLink)
hl bin/viewer.hl
```

## Project Structure

*   `src/`: Contains the Heaps runtime, camera controls, and shader integration. This is the core application logic.
*   `assets/`: Houses JDA/JDW sample content and AxiumSL examples, used for testing and demonstrating the editor's capabilities.
    *   `jda3d/`, `jda2d/`: SDF assets following `docs/jdw_sdf_csg_world_standard_v_0.md`.
    *   `jdw/world/`: Example world files with inline layers/nodes referencing local JDA assets.
    *   `axsl/`: AxiumSL DSL examples and their HXSL counterparts.
*   `docs/`: Documentation, including standards, design notes, and project roadmap.
*   `tests/`: Contains pending camera tests and future tests for loaders and parsers.
*   `.haxelib/`: Haxe library dependencies.

## Current Status

*   **MVP Raymarching:** Basic raymarching functionality is implemented.
*   **Camera Controls:** Camera controls are currently Work In Progress (WIP).
*   **Asset Integration:** JDW/JDA sample content is ready for loader integration; hardcoded SDFs need to be replaced with loaded assets.
*   **AxiumSL DSL:** AxiumSL DSL examples and matching HXSL references are added, with parser/emitter implementation pending.

## Next Steps / Roadmap

*   **Camera Controls:** Finalize orbit, zoom, and pan camera controls, and implement on-screen debugging tools.
*   **JDW/JDA Loaders:** Implement minimal loaders for JDW/JDA assets to dynamically load content.
*   **AxiumSL Pipeline:** Build the AxiumSL -> Intermediate Representation (IR) -> HXSL pipeline to embed shaders directly into JDA/JDW assets.
*   **Smoke Tests:** Add smoke tests for the newly implemented loaders and shader generation processes.
