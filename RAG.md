
# RAG/DocsLog – AxiumForge (Heaps/HXSL)

Formål: Emneinddelt indeks med target/intent, så AI kan slå viden op før nye søgninger. Tilføj nye fund under den relevante kategori med et kort “target + resultat”.

## 1) Editor Runtime (Heaps/HXSL)
- **Target/Intent**: Bygge/porte AxiumForge Editor til Heaps; raymarching, scene graph, JDW/JDA integration.
- **Lokale**: `docs/axiumeditor_heaps_HXSL.md`
- **Eksterne**: Heaps/Haxe docs https://heaps.io/documentation, Heaps repo + HXSL eksempler https://github.com/HeapsIO/heaps/tree/master/hxsl
- **Søgninger/Findings**:
  - 2025-11-24 – Heaps h3d.Vector API (https://heaps.io/api/h3d/Vector.html) – Used for CameraState spherical coordinate math
  - 2025-11-24 – Heaps h3d.Camera API (https://heaps.io/api/h3d/Camera.html) – Pending for VP1 Phase 1.3 camera integration
  - 2025-11-24 – utest framework (https://lib.haxe.org/p/utest/) – Migrated from haxe.unit (not in Haxe 4), TDD infrastructure for VP1
  - 2025-11-24 – Heaps h2d.Interactive (.haxelib/heaps/2,1,0/h2d/Interactive.hx) – Mouse/keyboard input handling with callbacks (onMove, onPush, onRelease, onWheel)
  - 2025-11-24 – Heaps hxd.Event (.haxelib/heaps/2,1,0/hxd/Event.hx) – Input event types (EPush, ERelease, EMove, EWheel), properties: relX/relY, button (0=left, 1=middle, 2=right), wheelDelta

## 2) AxiumSL (DSL + IR)
- **Target/Intent**: Spec + minimal syntaks (v0.1) og roadmap til HXSL-first shader DSL.
- **Lokale**: `docs/AxiumSLang.md`, `docs/axslv01.md`
- **Eksterne**: Haxe https://haxe.org, Heaps/HXSL refs som ovenfor.
- **Søgninger/Findings**: _(tilføj: dato – link/noter)_

## 3) JDW/JDA World Standard
- **Target/Intent**: JSON standard for 2D/3D SDF/CSG worlds med cascading defaults og JDA assets.
- **Lokale**: `docs/shared/Standards/jdw_sdf_csg_world_standard_v_0.md` (symlink til shared AXIUMDOCS)
- **Eksterne**: _(tilføj relevante artikler/blogs om SDF/CSG world formats)_
- **Søgninger/Findings**:
  - 2025-11-24 – VP5 Phase 5.1 Complete – JDA 3D JSON parser implementation (77/77 tests passing)
  - 2025-11-24 – JDA structure: jda_version, id, type, param_schema, sdf_tree (recursive: primitive/op/modifier/reference), materials, variants, attach_points, depends
  - 2025-11-24 – Enum-based SDF tree: SdfNode (Primitive, Operation, Modifier, Reference) prevents invalid structures
  - 2025-11-24 – Test assets working: sphere_basic, rounded_box (CSG smooth_union), pillar_repeat (modifier repeat)

## 4) Projekt/Proces
- **Target/Intent**: VP/TDD-planer, milepæle, progress board.
- **Lokale**: `docs/project/axiumforge_editor_project.md`, `docs/project/axsl_project.md`, `docs/project/progress.md`
- **Eksterne**: _(tilføj evt. proces-/DDD-kilder)_
- **Søgninger/Findings**:
  - 2025-11-24 – VP1 Phase 1.1 Complete – CameraState TDD implementation (31/31 tests passing), immutable state pattern with enum + tools class
  - 2025-11-24 – VP1 Phase 1.2 Complete – CameraController (rotate/zoom/pan methods), 8 tests, 47 total assertions passing
  - 2025-11-24 – VP1 Phase 1.3 Complete – Main.hx integration with h2d.Interactive input, MMB/wheel/Shift controls, runtime verified
  - 2025-11-24 – 🎉 VP1 COMPLETE – Interactive 3D SDF viewer with Blender-style orbit camera, TDD workflow, immutable architecture
  - 2025-11-24 – **Priority Shift**: VP2/VP3 deferred, VP5 (JDA/JDW Loader) is CORE system (DevOps: jump phases, function over quality)
  - 2025-11-24 – 🎉 VP5 Phase 5.1 COMPLETE – JDA 3D JSON Parser (10 tests, 30 assertions, 100% passing), recursive SDF tree parsing, type-safe enum design
  - 2025-11-24 – 🎉 VP5 Phase 5.2 COMPLETE – SDF Evaluator/HXSL Code Generator (9 tests, 17 assertions), primitives/CSG/modifiers all working
  - 2025-11-24 – 🎉 VP5 Phase 5.4 COMPLETE – Integration with Main.hx, complete pipeline working: JDA JSON → Parser → SDF Tree → Code Gen → Rendering!
  - 2025-11-24 – **VP5 CORE COMPLETE** – 94/94 tests passing, JDA assets loading and rendering dynamically, sphere from JDA file replacing hardcoded box
  - 2025-11-24 – 🎉 VP6 Phase 6.1 COMPLETE – Asset Selector UI with runtime shader switching (3 pre-compiled shaders), no recompile needed for asset changes
  - 2025-11-24 – **CLI Shader Compiler System** – tools/Jda2Hxsl.hx (single/batch mode), compile-shaders.sh script, statement-based code generation (no inline lambdas)
  - 2025-11-24 – **Code Generation Strategy** – Unique variable naming (box_q0, smu_a0, rep_p0), statements array for complex operations, flat HXSL output
  - 2025-11-25 – 🎉 VP6 Phase 6.2 COMPLETE – Inspector Panel with dynamic metadata display, handles both float and vec3 parameters/variants, full JDA parsing

## 5) HXSL/Heaps Noter
- **Target/Intent**: Pipeline-noter, reference-links for HXSL/Heaps brugt af projekterne.
- **Lokale**: `docs/hxsl.md`
- **Eksterne**: Heaps.io, Heaps GitHub HXSL map: https://github.com/HeapsIO/heaps/tree/master/hxsl
- **Søgninger/Findings**:
  - 2025-11-24 – HXSL inline lambdas NOT supported – `(function() {...})()` syntax causes "Unsupported expression" error, must use statement-based generation
  - 2025-11-24 – HXSL @param fields require type-specific casting – Cannot access via Dynamic or Reflect.setField, must cast to specific shader class
  - 2025-11-24 – Heaps h2d UI z-order – Children rendered in add order, use `addChildAt(child, 0)` to add at bottom of display list
  - 2025-11-24 – Camera orientation fix – cameraUp = (0, -1, 0) needed for correct Y-up coordinate system in HXSL raymarching shaders
  - 2025-11-25 – HashLink array parsing – Cannot directly cast JSON arrays to Array<Float>, must iterate and cast each element individually
  - 2025-11-25 – h2d.Interactive z-order input handling – Interactive elements must be below UI in z-order to allow UI to receive events first
  - 2025-11-25 – JDA vec3 parameters – Default values can be arrays (e.g., [0.6, 0.6, 0.6]), not just single floats - handle both in Inspector UI
  - 2025-11-25 – **InspectorModel typedef fix** – Changed ParamInfo.defaultValue and VariantParamInfo.value from String to Dynamic to preserve original JSON types (Float/Array). Tests expected Float but got String when typedef forced string conversion. Solution: Keep raw Dynamic values, let UI handle string conversion for display. Fixed 3 test failures → 205/205 tests passing ✅
  - 2025-11-27 – **File Picker Implementation** – hl.UI.loadFile() does NOT work on macOS (returns null, no dialog). Solution: Created FileBrowser.hx - custom Heaps UI popup with directory navigation, .json filtering, cross-platform. Also added CLI support via Sys.args() for AI/automation friendly asset loading. Both approaches working.
  - 2025-11-27 – **hl.UI limitations on macOS** – Native file dialog (hl.UI.loadFile) requires platform-specific setup/permissions on macOS. For cross-platform reliability, use custom Heaps UI components instead of relying on hl.UI file dialogs.

## Brugsmønster
- Start med relevant kategori (target) før ny søgning.
- Når du søger: tilføj kort entry under “Søgninger/Findings”: `YYYY-MM-DD – kort titel – link – 1 linje nøglelæring`.
- Hold det kortfattet; ingen duplikering af indhold, kun pointere.*** End Patch ***!
