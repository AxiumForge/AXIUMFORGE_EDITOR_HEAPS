# AxiumForgeEditor-HX (Heaps) – Canvas

Dette dokument er **Haxe/Heaps/HXSL-versionen** af Axium/AxiumForgeEditor‑designet. Det svarer 1:1 til Rust/Bevy‑udgaven, men mappet til **Heaps + HXSL + Haxe** og den samme JDW/JDA‑standard.

Målet er, at du kan give dette til en AI‑koder og sige: *"Byg AxiumEditor i Heaps ud fra dette"*.

---

## 1. Formål & Scope

- **Editor for JDW/JDA**

  - Læs, vis og redigér JDW‑verdener (worlds, layers, nodes, materials, shaders, assets, raymarch, theme).
  - Integrér JDA assets (sdf3d‑creatures, props osv.) i JDW‑nodes.

- **Runtime oven på Heaps**

  - Heaps scene graph (h3d/h2d) = runtime.
  - HXSL raymarching for SDF/CSG preview (fullscreen pass).
  - 2D-SDF → textures/masks på 3D‑SDF i materialer.

- **Heimdal/Axium integration**

  - CLI‑kommandoer (`jdw.view`, `jdw.validate`, `jdw.export`, `jdw.play`) håndteres via Heimdal.
  - Hot‑reload af JDW ved filændringer.

---

## 2. Tech Stack & Modul‑layout

### 2.1 Tech stack

- Sprog: **Haxe**
- Engine: **Heaps** (`h3d`/`h2d`, assets, input)
- UI: Heaps UI (h2d + widgets/flow) eller HeapsUI
- Shaders: **HXSL** (fullscreen raymarch pass)
- Data: **JDW** (JSON/JSONC) + **JDA** (JSON)

### 2.2 Moduler/pakker

```text
axium_editor_hx/
  src/
    axium/jdw/            # JDW datamodel, json parser/validator
    axium/jda/            # JDA datamodel, loader
    axium/runtime/heaps/  # JDW→Heaps scene + raymarch backend
    axium/editor/heaps/   # Editor-UI og tools
```

- **axium.jdw**

  - Haxe typer for hele JDW‑specen.
  - Loader for `.jdw.json` og `.jsonc`.
  - Validator for id’er, referencer, cascading defaults.

- **axium.jda**

  - Typer for JDA: schema, sdf_tree, variants, attach_points, depends.

- **axium.runtime.heaps**

  - Service der loader JDW, bygger h3d scene objects og kører raymarch‑pass.

- **axium.editor.heaps**

  - Editor UI (scenegraph, inspector, asset browser, SDF‑tree editor, export/bake panel).

---

## 3. JDW → Heaps Runtime Arkitektur

### 3.1 Ressourcer og objekter

**Resources / singletons**

- `JdwDocumentRes { doc, path, generation }`
- `JdaRegistryRes { jdas }`
- `JdwThemeState { effective_theme }`

**Scene-objekter / komponentdata**

- `JdwWorldTag { worldId }` knyttet til et `h3d.scene.Object`
- `JdwLayerTag { layerId, dim }`
- `JdwNodeTag { nodeId, layerId }`
- `JdwTransform` → mappet til `h3d.Matrix`/`h3d.scene.Object` transform
- `JdwMaterialRef { id }`
- `JdwShaderRef { id }`
- `JdwRaymarchOverride { params }`
- `JdwSource` (inline_sdf / jda / mesh)

### 3.2 Build‑pipeline (systemgraph)

1. **Load JDW**
2. **Resolve cascading defaults**
3. **Build Heaps scene**
4. **Runtime sync (editor)**
5. **Hot‑reload**

---

## 4. Raymarching Backend i Heaps

- Fullscreen render pass i HXSL.
- Input: kamera uniforms, globale/default raymarch settings.
- SDF/CSG‑data pakkes i buffers (UBO/SSBO‑agtigt via `h3d.Buffer`).

Eksempel HXSL‑strukturer:

```hxsl
struct SdfPrimitive {
    int kind;
    int dim;
    int paramsOffset;
    int _pad;
}
```

2D-SDF kan bruges som textures eller genereret HXSL‑kode.

---

## 5. Editor UI Struktur (Heaps)

### 5.1 Layout

- **Venstre:** Scenegraph panel (h2d list/tree)
- **Midten:** Viewport (h3d render til RT + vis i h2d.Bitmap)
- **Højre:** Inspector & asset-browser
- **Bund:** Log/validator & CLI-output

### 5.2 Scenegraph Panel

- Worlds → Layers → Nodes
- Select, toggle visibility, context menu for add/duplicate/delete

### 5.3 Inspector

- Node: id, name, layer, enabled
- Transform
- Material
- Shader override
- Raymarch override
- Source (inline SDF, JDA, mesh)

### 5.4 SDF‑tree Editor

- Tree view af primitives/ops/modifiers
- Drag’n’drop, property panel, presets

### 5.5 Asset‑Browser

- Materials, shaders, JDA, textures, SDF2D

### 5.6 Validator & Log

- Viser JDW‑issues og CLI output

---

## 6. JDW Runtime & CLI (Heaps‑version)

JDW runtime‑blokken styrer hot‑reload, debug‑flags og entry world. Heimdal CLI bruger editoren headless eller normal.

---

## 7. Exports, Baking & Pipelines

- **SDF → Mesh** via marching cubes / dual contouring.
- **Texture baking** via raymarch eller offscreen passes.
- **Pipelines:** image→SDF2D, SDF2D→SDF3D, SDF3D→JDA.

---

## 8. Theming & Texture‑Policy

- Theme panel
- Material integration med theme‑farver
- Live updates via uniforms

---

## 9. Samlet Workflow

1. Åbn JDW
2. Byg scene
3. Preview i raymarch
4. Edit i UI
5. Rebuild scene
6. Debug overlays
7. Export mesh/texture
8. Brug assets i andre engines

---

## 10. Faser / Roadmap

Faserne er parallelle med Rust‑udgaven men mappet til Heaps. Start med en **MVP viewer**.

### Fase 1 – AxiumViewer MVP (JDA 3D viewer)

**Mål:** Ét lille program der kan:

- loade en **JDA3D asset** (hardcoded path i første iteration),
- vise den i et Heaps‑vindue,
- styres med mus/tastatur,
- starte i et fast, fornuftigt kamera‑view.

**Features:**

1. **Heaps app skeleton**

   - `AxiumViewerMvp` main.
   - Init `h3d.Engine`, `h2d.Scene`, `h3d.scene.Scene` + egen `CameraController`.

2. **JDA loader (minimal)**

   - `axium.jda` med kun det nødvendige til at læse én asset og finde dens root/bounds.
   - Antag at asset er centreret omkring `(0,0,0)` eller beregn bounding box.

3. **Kamera setup**

   - Koordinatsystem: Heaps standard (Y op).
   - Startposition fx:
     - `target = Vec3(0,0,0)`
     - `distance = r` (beregnet ud fra bounding box, fx radius * 2)
     - `yaw = 45°`, `pitch = -45°`
   - Kamera placeres ved:
     - `position = target + rot(yaw, pitch) * distance`
     - `cam.setPosition(position); cam.lookAt(target, Vec3(0,1,0))`
   - Garanterer at asset **altid er i view ved open**.

4. **Kamera controls (Blender/Godot‑style)**

   - Orbit omkring `target`:
     - MMB drag: ændrer yaw/pitch.
     - `pitch` clamped (fx mellem -85° og -5°).
   - Zoom:
     - Mouse wheel → ændrer `distance` (clamp min/max).
   - Pan:
     - Shift + MMB drag: flytter `target` i kameraets lokale X/Z‑plan.
   - Evt. WASD/EQ som ekstra fly‑mode senere.

5. **Input mapping**

   - Brug Heaps input (`hxd.App.events`) til mouse motion + wheel + modifiers.
   - Resource `CameraOrbitState { yaw, pitch, distance, target }` opdateres hver frame.

6. **Rendering**

   - I Fase 1 kan asset være:
     - en simpel placeholder mesh (box/sphere) eller
     - en konverteret JDA→Mesh (meget simpel pipeline).
   - Raymarch/HXSL kan vente til senere fase.

---

### Fase 2 – JDA‑gallery & basic JDW integration

**Mål:**

- Flere JDA assets kan vælges.
- Simpelt UI‑overlay til at skifte asset.
- Første JDW‑kobling (fx et JDW‑document der refererer én JDA‑node).

**Features:**

- Asset‑liste (hardcoded JSON eller lille config).
- UI panel (h2d/HeapsUI) med liste/dropdown.
- Reload af asset uden at lukke app.
- Start‑kamera genereres for den valgte asset på samme måde som i Fase 1.

---

### Fase 3 – JDW World Viewer

**Mål:**

- AxiumViewer bliver til en **JDW world viewer**.
- Læser et komplet JDW‑document og bygger en Heaps‑scene.

**Features:**

- `axium.jdw` implementeret (read/validate).
- `axium.runtime.heaps` genererer scene objects for worlds/layers/nodes.
- Kamera kan:
  - hoppe mellem predefined kamera‑presets (fra JDW),
  - stadig orbit’e omkring valgt node (som i Fase 1).

---

### Fase 4 – Editor-UI (AxiumEditor-HX)

**Mål:**

- Gå fra viewer til egentlig editor.

**Features:**

- Scenegraph panel (worlds → layers → nodes).
- Inspector for transform/material/source.
- Minimal SDF‑tree editor (tekst/struktur først, senere visuel).
- JDW hot‑reload + save.

---

### Fase 5 – Raymarching, Baking & Tools

**Mål:**

- Full SDF/CSG raymarch backend.
- Bage mesh/tekster.
- Avancerede pipelines.

**Features:**

- HXSL fullscreen raymarch.
- SDF→Mesh eksport.
- Pipelines (image→SDF2D, SDF2D→SDF3D, SDF3D→JDA).

---

Det giver den samme **stramme start** som Rust‑versionen: Fase 1 er kun "én JDA asset + godt kamera" – resten kan bygges ovenpå uden at ændre grundstrukturen.
