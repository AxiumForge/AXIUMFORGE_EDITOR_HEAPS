# AxiumSL v0.1 – MVP Syntax & Grammar Draft

> Fokus: *Minimal, brugbar* version af AxiumSL, der kan parses til IR og targette HXSL som første backend.

---

## 1. Designmål for v0.1

* ✂ **Bevidst lille**: kun det, der er nødvendigt for SDF/raymarch-MVP.
* 🎯 **HXSL-first**: alle konstrukter skal være nemme at mappe til HXSL.
* 🧠 **AI-venlig**: simpel, stabil syntaks uden for meget “fluff”.
* 🔁 **IR-først**: alt i syntaksen skal kunne mappes direkte til AxiumSL IR (AxType, AxExpr, AxStmt, AxShader).

Begrænsninger (med vilje):

* Kun **én shader-kind**: `sdf_raymarch` fragment shader.
* Kun **float + vec2/vec3/vec4 + bool** som typer.
* Ingen `struct`, ingen `samplers`, ingen `textures` (kommer senere).

---

## 2. Filformat og top-level struktur

* Filendelse: `.axsl`
* En fil indeholder **præcis én shader** i v0.1.

### 2.1 Grundform

```axsl
shader <Identifier> : <ShaderKind> {
    <ShaderBody>
}
```

Hvor:

* `<Identifier>` = shader-navn (f.eks. `BoblingHull`)
* `<ShaderKind>` = `sdf_raymarch` i v0.1
* `<ShaderBody>` = sekvens af deklarationer:

  * `uniform`-deklarationer
  * funktionsdeklarationer `fn`
  * en `entry`-funktion (fragment entry point)

### 2.2 Eksempel

```axsl
shader BoblingHull : sdf_raymarch {
  uniform mat4 uCamera;
  uniform vec3 uLightDir;

  fn sdSphere(p: vec3, r: float) -> float {
    return length(p) - r;
  }

  fn map(p: vec3) -> float {
    let d = sdSphere(p, 1.0);
    return d;
  }

  entry fragment mainRaymarch(uv: vec2) -> vec4 {
    let ro = vec3(0.0, 0.0, -5.0);
    let rd = normalize(vec3(uv, 1.5));
    let t = 0.0;
    let hit = false;
    let p = vec3(0.0, 0.0, 0.0);

    for i in 0..64 {
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

    let col = vec3(1.0, 1.0, 1.0);
    return vec4(col, 1.0);
  }
}
```

---

## 3. Typer og identifier-regler

### 3.1 Primitive typer

Tilladte typer i v0.1:

* `float`
* `bool`
* `vec2`
* `vec3`
* `vec4`
* `mat3`
* `mat4`

(Alle mappes 1:1 til HXSL-typer: `Float`, `Vec2`, `Vec3`, `Vec4`, `Mat3`, `Mat4`, `Bool`)

### 3.2 Identifiers

```ebnf
Identifier = Letter , { Letter | Digit | "_" } ;
Letter     = "A".."Z" | "a".."z" ;
Digit      = "0".."9" ;
```

* Case-sensitive.
* Må ikke kollidere med reserverede ord.

### 3.3 Reserverede ord

```text
shader, uniform, fn, entry, fragment,
let, return, if, else, for, break,
true, false,
float, bool, vec2, vec3, vec4, mat3, mat4,
length, normalize, dot, min, max, abs
```

(OBS: sidste gruppe er “built-in function names” – ikke syntaktisk reserveret, men bør behandles særskilt i IR/typecheck.)

---

## 4. Formelle grammatik-fragmenter (v0.1 EBNF)

> Dette er *strammet men ikke fuldkommen* – nok til at implementere en parser.

### 4.1 Shader

```ebnf
Shader       = "shader" , Identifier , ":" , ShaderKind , "{" , { Decl } , "}" ;

ShaderKind   = "sdf_raymarch" ;

Decl         = UniformDecl
             | FuncDecl
             | EntryDecl
             ;
```

### 4.2 Uniform-deklaration

```ebnf
UniformDecl  = "uniform" , Type , Identifier , ";" ;
```

Eksempler:

* `uniform vec3 uLightDir;`
* `uniform mat4 uCamera;`

### 4.3 Funktionsdeklaration

```ebnf
FuncDecl     = "fn" , Identifier , "(" , [ ParamList ] , ")" , "->" , Type , Block ;

ParamList    = Param , { "," , Param } ;
Param        = Identifier , ":" , Type ;

Block        = "{" , { Stmt } , "}" ;
```

Eksempel:

```axsl
fn map(p: vec3) -> float {
  let d = sdSphere(p, 1.0);
  return d;
}
```

### 4.4 Entry-deklaration (fragment)

```ebnf
EntryDecl    = "entry" , "fragment" , Identifier ,
               "(" , [ ParamList ] , ")" , "->" , Type , Block ;
```

* I v0.1 kræver vi `Type = vec4` for fragment-entry (return color).

Eksempel:

```axsl
entry fragment mainRaymarch(uv: vec2) -> vec4 {
  ...
}
```

---

## 5. Statements (Stmt) – v0.1 subset

```ebnf
Stmt         = LetStmt
             | AssignStmt
             | ReturnStmt
             | IfStmt
             | ForStmt
             | BreakStmt
             | ExprStmt
             ;

LetStmt      = "let" , Identifier , "=" , Expr , ";" ;
AssignStmt   = Identifier , "=" , Expr , ";" ;
ReturnStmt   = "return" , Expr , ";" ;
BreakStmt    = "break" , ";" ;

ExprStmt     = Expr , ";" ;
```

### 5.1 If / Else

```ebnf
IfStmt       = "if" , "(" , Expr , ")" , Block , [ "else" , Block ] ;
```

### 5.2 For-loop (enkel integer-range)

```ebnf
ForStmt      = "for" , Identifier , "in" , IntLiteral , ".." , IntLiteral , Block ;
```

Eksempel:

```axsl
for i in 0..64 {
  let d = map(p);
  if (d < 0.001) {
    hit = true;
    break;
  }
  t += d;
}
```

---

## 6. Expressions (Expr) – v0.1 subset

```ebnf
Expr         = LogicOrExpr ;

LogicOrExpr  = LogicAndExpr , { "||" , LogicAndExpr } ;
LogicAndExpr = EqualityExpr , { "&&" , EqualityExpr } ;
EqualityExpr = RelExpr , { ("==" | "!=") , RelExpr } ;
RelExpr      = AddExpr , { ("<" | ">" | "<=" | ">=") , AddExpr } ;
AddExpr      = MulExpr , { ("+" | "-") , MulExpr } ;
MulExpr      = UnaryExpr , { ("*" | "/") , UnaryExpr } ;

UnaryExpr    = [ ("-" | "+") ] , PrimaryExpr ;

PrimaryExpr  = Literal
             | Identifier
             | CallExpr
             | SwizzleExpr
             | "(" , Expr , ")"
             ;
```

### 6.1 Literals

```ebnf
Literal      = FloatLiteral
             | BoolLiteral
             | VecCtor
             ;

FloatLiteral = Digit , { Digit } , [ "." , { Digit } ] ;
BoolLiteral  = "true" | "false" ;
```

### 6.2 Vector constructors (MVP)

```ebnf
VecCtor      = "vec2" , "(" , Expr , "," , Expr , ")"
             | "vec3" , "(" , Expr , "," , Expr , "," , Expr , ")"
             | "vec4" , "(" , Expr , "," , Expr , "," , Expr , "," , Expr , ")"
             ;
```

Eksempler:

```axsl
let a = vec3(0.0, 1.0, 0.0);
let u = vec2(uv.x, uv.y);
```

### 6.3 Funktionskald

```ebnf
CallExpr     = Identifier , "(" , [ ArgList ] , ")" ;
ArgList      = Expr , { "," , Expr } ;
```

Eksempler:

```axsl
let d = sdSphere(p, 1.0);
let n = normalize(v);
let len = length(p);
```

### 6.4 Swizzles / feltadgang (simplificeret)

```ebnf
SwizzleExpr  = Identifier , "." , SwizzleMask ;
SwizzleMask  = ("x" | "y" | "z" | "w") , { "x" | "y" | "z" | "w" } ;
```

Eksempler:

```axsl
let x = p.x;
let xy = uv.xy;
```

---

## 7. Mapping til AxiumSL IR og HXSL (v0.1)

### 7.1 IR mapping (skitse)

* `shader` → `AxShader` med:

  * `name`
  * `kind = SdfRaymarchFragment`
  * `uniforms` (liste af `AxUniform`)
  * `functions` (liste af `AxFunction`)
  * `entry` (en særlig `AxFunction`)

* `fn` → `AxFunction`

* `entry fragment` → `AxFunction` + flag `isEntry = true`

* Statements → `AxStmt`

* Expressions → `AxExpr`

### 7.2 HXSL mapping (principper)

* Top-level shader kan oversættes til en HXSL fragment shader-fil.
* Uniforms:

```axsl
uniform vec3 uLightDir;
```

→ HXSL (konceptuelt):

```hxsl
var uLightDir : Vec3;
```

* Entry fragment-funktion bliver `main`/`fragment` i HXSL:

```axsl
entry fragment mainRaymarch(uv: vec2) -> vec4 { ... }
```

→ HXSL fragment entry (pseudo):

```hxsl
function fragment() {
  var uv: Vec2 = ...; // afhænger af pipeline
  var col: Vec4 = mainRaymarch(uv);
  outColor = col;
}
```

(Det præcise HXSL-output afhænger af Heaps’ pipeline, men dette er nok til at definere generatorens ansvar.)

---

## 8. v0.1 Scope-opsummering

AxiumSL v0.1 specificerer:

1. **En lille, fokuseret syntaks** til SDF-raymarch fragment shaders.
2. **Formelle grammatikfragmenter (EBNF)** for:

   * Shader-top-level
   * Uniforms
   * Funktioner
   * Entry fragment
   * Statements (let, assign, if/else, for, return, break)
   * Expressions (arithmetik, logik, kald, vector constructors, swizzles)
3. **Typeunivers** begrænset til float/bool/vec2/vec3/vec4/mat3/mat4.
4. **Tydelig mapping** til AxiumSL IR og videre til HXSL.

Alt yderligere (structs, teksturer, flere shader-kinds, WGSL backend, typechecking, macros) tilhører **v0.2+** og kan bygges ovenpå denne kerne uden at ændre fundamentet.

---

## 9. Future Extensions (Ikke en del af v0.1 scope)

Følgende elementer er **bevidst udeladt** af v0.1, men er planlagt/overvejet til kommende versioner. De dokumenteres her, så IR og sproget kan designes **fremtidssikret**:

### 9.1 Udvidet type-system i IR

I stedet for kun:

```haxe
enum AxType {
  TFloat;
  TVec2; TVec3; TVec4;
  TMat3; TMat4;
  TBool;
}
```

overvejes følgende udvidelse:

```haxe
enum AxType {
  TFloat;
  TVec2; TVec3; TVec4;
  TMat3; TMat4;
  TBool;

  // Fremtidige additions
  TSampler2D; // textures
  TBuffer(t:AxType); // SSBO/UBO-lignende buffers
  TStruct(name:String, fields:Array<{ name:String, t:AxType }>);
}
```

Disse typer vil være nødvendige for:

* Tekstur-baserede materialer
* Uniform/storage buffers
* Mere komplekse material- og scene-beskrivelser

### 9.2 Uniform metadata til WGSL/GLSL/SPIR-V

For at understøtte WGSL/SPIR-V/GLSL binding layouts kan `AxUniform` udvides med metadata:

```haxe
typedef AxUniform = {
  name: String,
  t: AxType,
  metadata: Null<{
    binding: Null<Int>,   // WGSL/SPIR-V binding
    location: Null<Int>,  // GLSL location
    set: Null<Int>        // Vulkan descriptor set
  }>
}
```

I v0.1 **ignoreres metadata** af HXSL-backenden, men felterne kan bruges senere af WGSL/SPIR-V/GLSL backends uden at ændre IR-strukturen.

### 9.3 SDF/CSG-specifik IR

Da AxiumSL er stærkt fokuseret på SDF/CSG, overvejes et dedikeret IR-lag ovenpå almindelige `AxExpr`:

```haxe
enum AxSDFPrimitive {
  Sphere(radius: AxExpr);
  Box(size: AxExpr);
  Plane(normal: AxExpr, height: AxExpr);
  // ... flere primitives
}

enum AxCSGOp {
  Union(a: AxExpr, b: AxExpr);
  Subtract(a: AxExpr, b: AxExpr);
  Intersect(a: AxExpr, b: AxExpr);
  SmoothUnion(a: AxExpr, b: AxExpr, k: Float);
}
```

Dette vil gøre det nemmere for:

* AI at generere **valid SDF/CSG kode**
* Editor-tools at manipulere scener på højt niveau
* Backends at optimere SDF/CSG strukturer specifikt

I v0.1 er SDF/CSG stadig blot almindelige funktioner/udtryk i AxSL-koden, men denne udvidelse kan introduceres som et ekstra “semantic layer” ovenpå IR’en.

### 9.4 Semantic Model-udvidelser

Ud over den simple `semantic_model` i AxiumSL v1-dokumentet kan shaders annoteres med mere domæneviden, f.eks.:

```jsonc
"semantic_model": {
  "type": "sdf_surface",
  "operations": ["csg", "raymarch", "material", "lighting_pbr"],
  "sdf_primitives": ["sphere", "box", "plane"],
  "csg_ops": ["subtract", "union"],
  "material_model": "pbr",
  "coordinate_space": "world" // eller "object", "camera"
}
```

Dette påvirker **ikke** selve AxiumSL v0.1 syntaksen, men bruges i JDW/JDA-laget til:

* bedre tooling og visualisering
* AI-guidance (hvilke operationer er forventede/gyldige?)
* fremtidige optimeringer og engine-mapping.
