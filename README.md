# AXIUMFORGE_EDITOR_HEAPS

AxiumForge Editor (Heaps/Haxe edition) – a runtime-first viewer/editor for JDW worlds and JDA SDF assets, with HXSL raymarching and AxiumSL DSL support.

## What’s here
- Heaps app skeleton with HXSL raymarch shader MVP (`src/`, `RaymarchShader`), build config (`build.hxml`).
- JDW/JDA asset samples under `assets/`:
  - `jda3d/`, `jda2d/` – SDF assets following `docs/jdw_sdf_csg_world_standard_v_0.md`.
  - `jdw/world/` – example world with inline layers/nodes referencing local JDA assets.
  - `axsl/` – AxiumSL DSL examples and HXSL counterpart.
- Design/spec docs in `docs/`: JDW/JDA standard, AxiumSL DSL, HXSL pipeline, editor roadmap.

## Quick start
```bash
# build HashLink target
haxe build.hxml

# run (HashLink)
hl bin/viewer.hl
```

## Project structure
- `src/` – Heaps runtime, camera, shader hookup.
- `assets/` – JDA/JDW samples and AxiumSL examples.
- `docs/` – standards and design notes.
- `tests/` – pending camera tests and future loaders/parsers.

## Status
- MVP raymarching is in place; camera controls WIP.
- JDW/JDA sample content ready for loader integration.
- AxSL DSL example + matching HXSL reference added; parser/emitter pending.

## Next steps
- Finish camera orbit/zoom/pan controls and on-screen debug.
- Implement minimal JDW/JDA loaders; swap hardcoded SDF with loaded assets.
- Build AxSL → IR → HXSL pipeline and embed shaders in JDA/JDW.
- Add smoke tests for loaders and shader generation.
