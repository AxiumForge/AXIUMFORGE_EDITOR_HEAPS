# CLI Tools - JDA Shader Compiler

CLI-baseret shader compilation pipeline for AxiumForge Editor.

## Overview

```
JDA JSON → Jda2Hxsl Compiler → HXSL Shader → Heaps Rendering
```

## Tools

### 1. Jda2Hxsl - Shader Compiler

Kompilerer JDA 3D assets til HXSL shader classes.

**Single file mode:**
```bash
haxe --run tools.Jda2Hxsl <input.json> <ShaderClassName> [outputDir]

# Example:
haxe --run tools.Jda2Hxsl assets/jda3d/jda.shape.sphere_basic.json MySphereShader src/generated
```

**Batch mode:**
```bash
haxe --run tools.Jda2Hxsl --batch <inputDir> <outputDir>

# Example:
haxe --run tools.Jda2Hxsl --batch assets/jda3d src/generated
```

**Features:**
- ✅ Ingen inline lambdas (HXSL compatible)
- ✅ Flat code generation med unikke variable navne
- ✅ Auto-genererer class names fra filnavne
- ✅ Indbygget error handling og validation

### 2. compile-shaders.sh - Batch Compiler Script

Wrapper script til nem batch compilation.

**Basic usage:**
```bash
./compile-shaders.sh                # Compile all JDA assets
./compile-shaders.sh --clean       # Remove generated shaders
./compile-shaders.sh --watch       # Watch mode (requires fswatch)
./compile-shaders.sh --help        # Show help
```

**Output:**
- Generated shaders gemmes i: `src/generated/`
- Colored terminal output
- Success/failure summary

## Generated Shader Structure

**Input JDA:**
```json
{
  "jda_version": "1.0",
  "id": "jda.shape.sphere_basic",
  "type": "jda3d",
  "sdf_tree": {
    "kind": "primitive",
    "dim": "3d",
    "shape": "sphere",
    "params": {"radius": 1.0}
  }
}
```

**Output HXSL:**
```haxe
class SphereBasicShader extends hxsl.Shader {
    static var SRC = {
        @:import h3d.shader.Base2d;

        @param var cameraPos : Vec3;
        @param var cameraTarget : Vec3;
        @param var cameraUp : Vec3;
        @param var aspectRatio : Float;
        @param var fov : Float;

        function sdf(p: Vec3): Float {
            return length(p) - 1.0;
        }

        function fragment() {
            // Full raymarching code...
        }
    };

    public function new() {
        super();
        cameraUp = new h3d.Vector(0, -1, 0);  // Correct orientation
        fov = 1.0;
    }
}
```

## Code Generation Features

### Primitives
- Sphere, Box, Cylinder, Capsule, Torus, Plane
- Flat variable declarations (no inline lambdas)
- Unique variable names: `box_q0`, `cyl_d1`, etc.

### CSG Operations
- Union, Subtract, Intersect
- SmoothUnion, SmoothSubtract, SmoothIntersect
- Statement-based generation: `smu_a0`, `smu_b0`, `smu_h0`

### Modifiers
- Repeat: Domain repetition (`rep_p0`)
- Elongate: Space stretching (`elo_p0`)
- Twist: Rotation around Y (`twi_c0`, `twi_s0`, `twi_p0`)
- Bend: Bending transformation (`ben_c0`, `ben_s0`, `ben_p0`)
- Round: Edge rounding (inline)
- Onion: Hollowing (inline)

## Workflow

### 1. Create JDA Asset
```bash
# Edit or create JDA file
vim assets/jda3d/jda.shape.my_asset.json
```

### 2. Compile Shaders
```bash
# Batch compile all assets
./compile-shaders.sh

# Output:
# ✓ Loaded JDA document: jda.shape.my_asset
# ✓ Generated HXSL code
# ✓ Saved: src/generated/MyAssetShader.hx
# ✅ Success: 3/3
```

### 3. Use in Main.hx
```haxe
// Import generated shader
import MyAssetShader;

// Use in app
var shader = new MyAssetShader();
shader.cameraPos = s3d.camera.pos;
shader.cameraTarget = s3d.camera.target;
shader.aspectRatio = engine.width / engine.height;
```

### 4. Build & Run
```bash
haxe build.hxml
hl bin/viewer.hl
```

## Development Workflow

### Watch Mode (recommended)
```bash
# Terminal 1: Watch assets and auto-recompile
./compile-shaders.sh --watch

# Terminal 2: Watch app and auto-rebuild
./watch.sh
```

### Manual Workflow
```bash
# 1. Edit JDA asset
vim assets/jda3d/jda.shape.sphere_basic.json

# 2. Compile shaders
./compile-shaders.sh

# 3. Build app
haxe build.hxml

# 4. Run
hl bin/viewer.hl
```

## File Naming Convention

JDA filenames automatically map to class names:

| JDA Filename | Generated Class Name |
|---|---|
| `jda.shape.sphere_basic.json` | `SphereBasicShader` |
| `jda.shape.rounded_box.json` | `RoundedBoxShader` |
| `jda.shape.pillar_repeat.json` | `PillarRepeatShader` |
| `jda.shape.my_custom_asset.json` | `MyCustomAssetShader` |

Algorithm:
1. Ta sidste del efter sidste `.` (e.g., "sphere_basic")
2. Split på `_`
3. Capitalize hver ord
4. Join og tilføj "Shader" suffix

## Troubleshooting

### Compilation Errors

**Error: "Unsupported expression" (inline lambda)**
- Cause: Old generated shader with inline lambdas
- Fix: Run `./compile-shaders.sh --clean && ./compile-shaders.sh`

**Error: "SphereShader does not have field cameraPos"**
- Cause: Trying to access shader params via Dynamic or Reflect
- Fix: Use type-specific casting (see Main.hx updateShaderCamera)

**Error: "Camera upside down / light from below"**
- Cause: Wrong cameraUp vector
- Fix: Shaders now auto-generate with `cameraUp = (0, -1, 0)`

### Build Issues

**Generated shaders not found:**
```bash
# Check if directory exists
ls src/generated/

# Recompile
./compile-shaders.sh
```

**Old shaders cached:**
```bash
# Clean and rebuild
./compile-shaders.sh --clean
haxe build.hxml
```

## Technical Details

### No Inline Lambdas

**Problem:**
```haxe
// HXSL doesn't support this:
return (function() {
    var q = abs(p) - vec3(0.6);
    return length(max(q, vec3(0.0)));
})();
```

**Solution:**
```haxe
// Generate flat code:
var box_q0 = abs(p) - vec3(0.6);
return length(max(box_q0, vec3(0.0)));
```

### Unique Variable Names

Variables use prefixes + counter for uniqueness:
- `box_q0`, `box_q1` - Box primitive temp variables
- `cyl_d0`, `cyl_d1` - Cylinder distance
- `smu_a0`, `smu_b0`, `smu_h0` - Smooth union temps
- `rep_p0` - Repeat modifier position
- `twi_c0`, `twi_s0`, `twi_p0` - Twist cos/sin/position

### Statement-Based Generation

Complex operations build statement list:
```haxe
statements.push('var smu_a0 = ...;');
statements.push('var smu_b0 = ...;');
statements.push('var smu_h0 = clamp(...);');
return 'mix(smu_b0, smu_a0, smu_h0) - ...';
```

Final output:
```haxe
function sdf(p: Vec3): Float {
    var smu_a0 = ...;
    var smu_b0 = ...;
    var smu_h0 = clamp(...);
    return mix(smu_b0, smu_a0, smu_h0) - ...;
}
```

## Future Enhancements

- [ ] Watch mode med fswatch integration
- [ ] Parallel compilation for større asset libraries
- [ ] Incremental compilation (only changed files)
- [ ] Shader optimization pass (dead code elimination)
- [ ] JDW scene graph compilation
- [ ] Material system integration
- [ ] Custom HXSL template support

## See Also

- `docs/jdw_sdf_csg_world_standard_v_0.md` - JDA/JDW specification
- `CLAUDE.md` - Project overview
- `TODO.md` - Development roadmap
