# Haxe Shader Language (HXSL) – SDF/CSG Pipeline Notes

> Arbejdsdokument til AxiumSystem / AxiumForge SDF+CSG pipeline i Haxe/Heaps.

---

## 1. Vigtige links

**HXSL / Heaps / Haxe**

* Haxe officielle site – [https://haxe.org](https://haxe.org)
* Heaps.io (engine + HXSL) – [https://heaps.io](https://heaps.io)
* Heaps documentation – [https://heaps.io/documentation](https://heaps.io/documentation)
* Heaps GitHub – [https://github.com/HeapsIO/heaps](https://github.com/HeapsIO/heaps)
* HXSL kildekode + eksempler – [https://github.com/HeapsIO/heaps/tree/master/hxsl](https://github.com/HeapsIO/heaps/tree/master/hxsl)

*(Tilføj flere links når du finder gode blogs, talks, examples.)*

---

## 2. Overblik: HXSL i min SDF/CSG pipeline

**Mål:**

* Én fælles *shader-DSL* for AxiumSystem, som kan:

  * Render 2D/3D SDF shapes
  * Kombinere dem via CSG (union, intersect, subtract)
  * Køre på flere backends (OpenGL, DirectX, Vulkan, WebGPU via Heaps targets)

**Grundpipeline:**

1. **jda3d.json** (Axium JDA asset)
2. → Haxe parser/loader
3. → Generation af HXSL shader-moduler (SDF ops, materialer, lights)
4. → Heaps pipeline (Shader, Pass, Material)
5. → Target backend (GL/Vulkan/…) uden at ændre JDA.

**Designprincip:**

* *JDA definerer verden i matematik og struktur.*
* *HXSL er implementeringen af den matematik på GPU’en.*

---

## 3. HXSL basics – ting jeg skal kunne uden at tænke

### 3.1 Shader typer

* **Vertex shader**

  * Input: `attribute` / `input` (position, normal, uv, color)
  * Output: `v`-struct til fragment shader
  * SDF/CSG: ofte simpel (fullscreen quad, screenspace raymarching) eller mesh-based til hybrid.

* **Fragment shader**

  * Her ligger SDF raymarching / CSG distance-funktioner
  * Her samles lys, skygger, materialer

### 3.2 HXSL syntaks nøgleord

* `var` – lokale variabler
* `var foo : Float;`
* `uniform` – værdier fra CPU (kamera, tid, matrices, SDF parametre)
* `texture` / `sampler` – teksturer
* `function` – genbrugelige funktioner (SDF primitiv, CSG op, noise, osv.)
* `struct` – grupper data (material, hit-info)

*(Tilføj små kodeeksempler senere, fx en simpel SDF sphere.)*

---

## 4. SDF/CSG i HXSL – byggesten

### 4.1 SDF primitiv-funktioner

Standard sæt, alle i **world space** (eller klart defineret space):

```glsl
function sdSphere(p:Vec3, r:Float):Float {
    return length(p) - r;
}

function sdBox(p:Vec3, b:Vec3):Float {
    var q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}
```

*(Sprog er HXSL-ish; tilpas til korrekt syntax, når du kopierer til kode.)*

### 4.2 CSG operatorer

```glsl
function opUnion(d1:Float, d2:Float):Float {
    return min(d1, d2);
}

function opIntersect(d1:Float, d2:Float):Float {
    return max(d1, d2);
}

function opSubtract(d1:Float, d2:Float):Float {
    return max(d1, -d2);
}
```

**Note:**

* CSG-træet (AST) bor i JDA (eller i Haxe-structs)
* HXSL ser kun *den genererede distance-funktion*, fx `float map(vec3 p)`.

### 4.3 Distance-funktion (scene map)

* Genereres automatisk fra JDA → Haxe → HXSL
* Struktur:

```glsl
function map(p:Vec3):Float {
    var d = sdSphere(p - vec3(0.0, 0.0, 5.0), 1.0);
    d = opUnion(d, sdBox(p - vec3(2.0, 0.0, 5.0), vec3(1.0,1.0,1.0)));
    return d;
}
```

---

## 5. Raymarching i HXSL

**Standard loop:**

* Input:

  * `ro` – ray origin (kamera)
  * `rd` – ray direction
  * uniforms: `uMaxSteps`, `uMaxDist`, `uHitEps`

```glsl
function raymarch(ro:Vec3, rd:Vec3):HitInfo {
    var t = 0.0;
    var hit = HitInfo();
    for (i in 0...MAX_STEPS) {
        var p = ro + rd * t;
        var d = map(p);
        if (d < HIT_EPS) {
            hit.t = t;
            hit.p = p;
            hit.dist = d;
            hit.hit = true;
            break;
        }
        t += d;
        if (t > MAX_DIST) break;
    }
    return hit;
}
```

*(Tilpas til korrekt HXSL syntax og Heaps constraints.)*

---

## 6. Organisering i projektet

### 6.1 Filer

Forslag til struktur i Axium/Heaps-projekt:

* `src/axium/shaders/sdf/SdfPrimitives.hxsl` – sfære, box, torus, cylinder, etc.
* `src/axium/shaders/sdf/SdfOps.hxsl` – union, intersect, subtract, smooth ops
* `src/axium/shaders/sdf/Raymarch.hxsl` – raymarch loop + normal/lighting
* `src/axium/shaders/material/StandardMaterial.hxsl` – lambert, phong, pbr-lite
* `src/axium/shaders/AxiumCommon.hxsl` – uniforms (camera, time, resolution)

### 6.2 Haxe side

* `AxSdfShaderBuilder.hx`

  * Loader JDA (`jda3d.json`)
  * Bygger CSG AST
  * Genererer HXSL shader source (eller plugger moduler sammen)
  * Registrerer shader i Heaps (h3d.shader)

* `AxSdfRenderer.hx`

  * Opret quad/fullscreen mesh
  * Sætter uniforms (kamera, tid, parametre fra JDA)
  * Kører render pass

---

## 7. Dataflow: JDA → HXSL

1. **JDA** beskriver:

   * Primitives (type, parametre, transforms)
   * CSG tree (nodetype: union/intersect/subtract)
   * Materialer (albedo, roughness, emissive, etc.)

2. **Haxe-layer**:

   * Parser JDA → interne Haxe-klasser
   * Besøger CSG-træ og genererer kildestrenge til `map(p)` eller bygger modulgraf

3. **HXSL**:

   * Får genereret `map(p)` + material lookup
   * Raymarcher + lighting kører per pixel

4. **Backend**:

   * Heaps compiler omsætter HXSL → backend GLSL/HLSL/Metal/Vulkan

---

## 8. Uniforms og parametre

Mindst disse uniforms skal være standard i alle SDF shaders:

* Kamera

  * `uCamPos : Vec3`
  * `uCamDir : Vec3`
  * `uCamRight : Vec3`
  * `uCamUp : Vec3`
  * eller view/proj-matrix, afhængig af tilgang

* Skærm

  * `uResolution : Vec2` (width, height)
  * `uTime : Float`

* SDF / JDA parametre

  * `uSceneScale : Float`
  * arrays/buffers til instance-data (hvis nødvendigt)

Hold en lille tabel over **navngivning**, så AI-coders og assets matcher:

| Koncept    | Uniformnavn   | Type  |
| ---------- | ------------- | ----- |
| Tid        | `uTime`       | Float |
| Opløsning  | `uResolution` | Vec2  |
| Kamera pos | `uCamPos`     | Vec3  |

---

## 9. Debugging & udviklings-vaner

* Start med **1 primitiv** (fx en sphere) – få den til at virke 100%.

* Tilføj CSG ét skridt ad gangen (union → subtract → intersect).

* Hav en **debug-view mode**:

  * Distance visualisering (farve = distance)
  * Step count visualization
  * Normals view

* Log genereret HXSL til en fil:

  * `generated/axium_scene_001.hxsl`
  * nemt at åbne og læse, når noget går galt

---

## 10. TODO / åbne spørgsmål

* [ ] Beslut endelig HXSL coding-style (camelCase, snake_case, osv.)
* [ ] Definér præcist JDA → CSG AST format
* [ ] Eksempelprojekt: minimal AxiumSdfViewer (Heaps HL target, hot reload)
* [ ] Undersøg bedste måde at modulere HXSL (include vs. compose via Haxe)
* [ ] Lav lille cheat-sheet med HXSL specifik syntaks (typer, loops, conditionals)

*(Udbyg dokumentet løbende mens du eksperimenterer. Dette er “single source of truth” for HXSL-delen af Axium SDF/CSG pipeline.)*
