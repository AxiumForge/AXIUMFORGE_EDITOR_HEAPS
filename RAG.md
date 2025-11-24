
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
- **Lokale**: `docs/jdw_sdf_csg_world_standard_v_0.md`
- **Eksterne**: _(tilføj relevante artikler/blogs om SDF/CSG world formats)_
- **Søgninger/Findings**: _(tilføj: dato – link/noter)_

## 4) Projekt/Proces
- **Target/Intent**: VP/TDD-planer, milepæle, progress board.
- **Lokale**: `docs/project/axiumforge_editor_project.md`, `docs/project/axsl_project.md`, `docs/project/progress.md`
- **Eksterne**: _(tilføj evt. proces-/DDD-kilder)_
- **Søgninger/Findings**:
  - 2025-11-24 – VP1 Phase 1.1 Complete – CameraState TDD implementation (31/31 tests passing), immutable state pattern with enum + tools class

## 5) HXSL/Heaps Noter
- **Target/Intent**: Pipeline-noter, reference-links for HXSL/Heaps brugt af projekterne.
- **Lokale**: `docs/hxsl.md`
- **Eksterne**: Heaps.io, Heaps GitHub HXSL map: https://github.com/HeapsIO/heaps/tree/master/hxsl
- **Søgninger/Findings**: _(tilføj: dato – link/noter)_

## Brugsmønster
- Start med relevant kategori (target) før ny søgning.
- Når du søger: tilføj kort entry under “Søgninger/Findings”: `YYYY-MM-DD – kort titel – link – 1 linje nøglelæring`.
- Hold det kortfattet; ingen duplikering af indhold, kun pointere.*** End Patch ***!
