# AxiumSL Specification v1 (Draft)

*(Denne fil er et levende dokument – første fokus er MVP med HXSL som primær backend. WGSL og andre backends kommer i senere faser.)*

---

## 0. Formål

AxiumSL er et shader-/SDF-/CSG-orienteret DSL og IR-lag til AxiumSystem/AxiumForge, designet til:

1. At være **en abstraktion over konkrete shader-sprog** (først HXSL, senere WGSL, GLSL, SPIR-V, m.fl.)
2. At beskrive **SDF/CSG-scener, materialer og raymarching-pipelines** på en engine-agnostisk måde
3. At kunne **serialiseres i JDA/JDW** som både tekst (source) og struktureret IR (AST)
4. At være **venligt for AI-generering og -mutation**, men samtidig kunne udvikles til **stærk type-sikkerhed** via Haxe AST/macro integration

---

## 1. Roadmap & udviklingsfaser

### Fase 0 – Pragmatisk HXSL-first (MVP)

* AxiumSL defineres som **"light DSL" tæt på HXSL**:

  * Fokus på: uniforms, functions, SDF helper-fns, material-fns, main-raymarch
  * Ingen fuld typesystem-checker endnu – rely på HXSL compiler til typefejl
* Pipeline:

  * `AxiumSL Source` → simpel parser → `AxiumSL IR` → **HXSL generator** → Heaps/HL runtime
* Begrænsning: Kun fragment-shaders / raymarching og simple materials.

### Fase 1 – Stabil IR + JDW integration

* AxiumSL IR stabiliseres som Haxe-typer/enum-strukturer
* JDA/JDW får felt til at gemme:

  * `axiumsl.source` (tekst)
  * `axiumsl.ir` (serialiseret AST)
  * `backends.hxsl` (genereret eller håndskrevet)
* AI/Editor kan arbejde direkte på IR.

### Fase 2 – Typesikker AxiumSL + Haxe AST

* Haxe macros bruges til at:

  * Parse AxiumSL ved compile-time
  * Validere typer
  * Generere HXSL/WGSL/GLSL
* Mulighed for EDSL i Haxe (AxiumSL som Haxe-API i stedet for/ud over tekst-DSL).

### Fase 3 – Multi-backend (WGSL, GLSL, SPIR-V)

* AxiumSL IR → generators for:

  * WGSL (WebGPU)
  * GLSL 330/ES
  * SPIR-V (via tooling)
* AxiumSystem kan targette flere engines/runtimes.

---

## 2. Overordnet arkitektur

AxiumSL består af:

1. **Source DSL** (menneskeligt læsbart, AI-venligt)
2. **IR/AST** (Haxe-typer, kan serialiseres til JDA)
3. **Backends** (HXSL først; WGSL/GLSL senere)

I JDW/JDA vil en shader typisk se sådan ud:

```jsonc
{
  "shader": {
    "name": "bobling_hull",

    "semantic_model": {
      "type": "sdf_surface",
      "operations": ["csg", "raymarch", "material", "lighting_pbr"]
    },

    "axiumsl": {
      "version": "1.0.0-mvp",
      "source": "shader BoblingHull { ... }"
    },

    "ir": {
      "format": "axiumsl_ir_v1",
      "ast": { /* serialiseret AST */ }
    },

    "backends": {
      "primary": "hxsl",
      "hxsl": "shaders/bobling_hull.hxsl"
    }
  }
}
```

---

## 3. MVP: AxiumSL syntaks (HXSL-nær)

### 3.1 Grundidé

MVP’en skal være:

* **Nemt at skrive og læse** for dig og AI
* **Let at mape til HXSL**
* Fokus på **SDF/CSG math + material + raymarch-loop**

Vi starter med én shader-type: `sdf_raymarch`.

### 3.2 Eksempel – komplet MVP-shader

```axiumsl
shader BoblingHull : sdf_raymarch {

  // uniforms (mapped til HXSL uniforms)
  uniform mat4 uCamera;
  uniform vec3 uLightDir;

  // helper SDF functions (signaturer i MVP er "løse" – HXSL tjekker typer)
  fn sdSphere(p: vec3, r: float) -> float {
    return length(p) - r;
  }

  fn sdBox(p: vec3, b: vec3) -> float {
    let d = abs(p) - b;
    return min(max(d.x, max(d.y, d.z)), 0.0) + length(max(d, 0.0));
  }

  fn map(p: vec3) -> float {
    let core = sdSphere(p, 1.0);
    let cut  = sdBox(p - vec3(0.0, -0.5, 0.0), vec3(1.0, 0.2, 1.0));
    return max(core, -cut); // subtract box from sphere (CSG)
  }

  fn shade(p: vec3, n: vec3) -> vec3 {
    let l = normalize(uLightDir);
    let diff = max(dot(n, l), 0.0);
    return vec3(0.6, 0.4, 0.8) * diff;
  }

  // entry point (raymarching pipeline)
  entry fragment mainRaymarch(uv: vec2) -> vec4 {
    // UV til ray
    let ro = vec3(0.0, 0.0, -5.0);
    let rd = normalize(vec3(uv, 1.5));

    let t = 0.0;
    let hit = false;
    let p = vec3(0.0, 0.0, 0.0);

    for i in 0..128 {
      p = ro + rd * t;
      let d = map(p);
      if (d < 0.001) {
        hit = true;
        break;
      }
      t += d;
    }

    if (!hit) {
      return vec4(0.0, 0.0, 0.0, 1.0);
    }

    // normal estimation
    let e = 0.001;
    let n = normalize(vec3(
      map(p + vec3(e, 0.0, 0.0)) - map(p - vec3(e, 0.0, 0.0)),
      map(p + vec3(0.0, e, 0.0)) - map(p - vec3(0.0, e, 0.0)),
      map(p + vec3(0.0, 0.0, e)) - map(p - vec3(0.0, 0.0, e))
    ));

    let col = shade(p, n);
    return vec4(col, 1.0);
  }
}
```

### 3.3 Syntaktisk kerne for MVP

* **Filformat**: `.axsl`
* **Top-level**:

  * `shader <Name> : <Kind> { ... }`
* **Kinds (MVP)**:

  * `sdf_raymarch` – fragment shader med raymarch loop
* **Sektioner inde i shader**:

  * `uniform` deklarationer
  * `fn` funktionsdefinitioner
  * `entry fragment <name>(...) -> vec4` – entry point (mappes til `main` i HXSL)

Bevidst begrænsninger (MVP):

* Ingen struct-deklarationer (kan komme senere)
* Ingen generics
* Ingen sammensatte shader-stages (kun fragment)

---

## 4. AxiumSL IR (v1 – MVP)

IR’en er det, der gør det muligt at udvikle sproget uden at bryde alt. Den defineres i Haxe som typer.

### 4.1 Grundtyper

```haxe
enum AxType {
  TFloat;
  TVec2;
  TVec3;
  TVec4;
  TMat3;
  TMat4;
  TBool;
}

enum AxStorageQualifier {
  QUniform;
  QVarying;
  QLocal;
}

typedef AxParam = {
  name: String,
  t: AxType
}

typedef AxUniform = {
  name: String,
  t: AxType
}
```

### 4.2 Expressions & statements (forenklet MVP)

```haxe
enum AxExpr {
  EVar(name:String);
  EFloat(v:Float);
  EVec2(x:AxExpr, y:AxExpr);
  EVec3(x:AxExpr, y:AxExpr, z:AxExpr);
  EBinOp(op:AxBinOp, left:AxExpr, right:AxExpr);
  ECall(name:String, args:Array<AxExpr>);
  EIndex(target:AxExpr, field:String); // .x, .y, .z, osv.
}

enum AxBinOp {
  Add; Sub; Mul; Div;
  Dot; Min; Max;
}

enum AxStmt {
  SLet(name:String, value:AxExpr);
  SAssign(name:String, value:AxExpr);
  SIf(cond:AxExpr, thenBlock:Array<AxStmt>, elseBlock:Array<AxStmt>);
  SFor(name:String, from:Int, to:Int, body:Array<AxStmt>);
  SReturn(expr:AxExpr);
}
```

### 4.3 Funktioner og shaders

```haxe
typedef AxFunction = {
  name: String,
  params: Array<AxParam>,
  returnType: AxType,
  body: Array<AxStmt>
}

enum AxShaderKind {
  SdfRaymarchFragment;
}

typedef AxShader = {
  name: String,
  kind: AxShaderKind,
  uniforms: Array<AxUniform>,
  functions: Array<AxFunction>,
  entry: AxFunction
}
```

Det er denne `AxShader`, som både kan:

* serialiseres til JSON som `axiumsl.ir.ast`
* bruges som input til backend generators (HXSL/WGSL/GLSL)

---

## 5. HXSL backend (MVP-target)

### 5.1 Strategi

HXSL-generator tager `AxShader` og genererer en HXSL-kildefil:

* AxiumSL-typer → HXSL-typer (1:1 i MVP)
* `entry fragment` → `pixel`/`fragment` entry i HXSL
* uniforms → HXSL `var` med `uniform`
* funktioner → direkte HXSL `function`/`inline` function

### 5.2 Simpel mapping-tabel (MVP)

| AxType | HXSL type |
| ------ | --------- |
| TFloat | `Float`   |
| TVec2  | `Vec2`    |
| TVec3  | `Vec3`    |
| TVec4  | `Vec4`    |
| TMat3  | `Mat3`    |
| TMat4  | `Mat4`    |
| TBool  | `Bool`    |

Expressions konverteres til HXSL:

* `EBinOp(Add, a, b)` → `(${a} + ${b})`
* `ECall("length", [v])` → `length(v)`
* osv.

---

## 6. Udviklingsretning mod WGSL og stærkere DSL

### 6.1 WGSL backend

Når HXSL-backenden er stabil:

* Udvid IR, så den kan udtrykke forskelle mellem HXSL og WGSL hvis nødvendigt
* Lav en WGSL-generator der:

  * Mapper typer til WGSL (`vec3<f32>`, osv.)
  * Laver eksplicitte bindings/layout (MVP kan hardcode bindinger)

### 6.2 Strammere typer & Haxe AST

Efter MVP:

* Tilføj typechecker der går IR’en igennem og validerer:

  * Funktionskald
  * Binære operatorer
  * Sammenhæng mellem uniforms/parametre og brug
* Lav Haxe macros der:

  * Loader `.axsl` ved compile-time
  * Parse → IR → Validate → Gen HXSL/WGSL
  * Fail’er med pæne compile-time fejlbeskeder

### 6.3 Integration med scripting DSL

Et parallelt (eller overlay) sprog som `AxiumScript` kan:

* Beskrive SDF/CSG-scener i højere niveau syntax
* Kompileres til AxiumSL IR
* Lade AI og editor arbejde på højt niveau, mens shader-backends stadig går gennem AxiumSL.

---

## 7. MVP-scope opsummering

**MVP = "AxiumSL v1.0.0-mvp" med følgende:**

1. En simpel tekst-DSL:

   * `shader Name : sdf_raymarch { uniforms + fn + entry fragment }`
2. En parser der:

   * Konverterer tekst → `AxShader` IR (evt. med begrænsede typer)
3. En HXSL-backend:

   * `AxShader` → `.hxsl` fragment shader med raymarch-loop
4. JDW/JDA integration:

   * Felter til `axiumsl.source`, `axiumsl.ir`, `backends.hxsl`

Alt andet (WGSL, SPIR-V, typechecker, Haxe-macros) er **planlagt i spec’en**, men ikke krævet for at komme i gang.

---

*(Dette dokument er v1 draft og kan udvides med mere precise grammatik/EBNF, konkrete HXSL-eksempler og implementationsdetaljer for parser og generator.)*
