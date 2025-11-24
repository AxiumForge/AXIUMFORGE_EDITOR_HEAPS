JDA2D SDF assets following the JDA top-level shape from `docs/jdw_sdf_csg_world_standard_v_0.md` (type `sdf2d`).

## Format (JDA 2D)
- `jda_version`: JDA schema version string.
- `id`: globally unique string, prefixed `jda.sdf2d.*`.
- `type`: `"sdf2d"` for all assets here.
- `param_schema`: optional exposed params `{type, default, min?, max?}`; common types `float|vec2|color|bool|int`.
- `sdf_tree`: JDW-compatible AST with `primitive|op|modifier` nodes:
  - `primitive`: `{kind:"primitive", dim:"2D", shape:"circle|rect|segment|...", params:{...}}`
  - `op`: `{kind:"op", op:"union|subtract|intersect|smooth_union|...", k?, children:[...] }`
  - `modifier`: `{kind:"modifier", modifier:"repeat|twist|mirror|scale|...", params:{...}, child:{...}}`
- `materials`: optional (often empty for masks/height fields).
- `variants`: presets that override params; merge into active param set before evaluating SDF.
- `attach_points` and `depends`: rarely used for 2D, but kept for compatibility.

## Assets
- `jda.sdf2d.grass_pattern.json` – repeat modifier over a circle primitive to create a tiled mask/height texture. Variants adjust cell size and radius.

## Usage
- Refer to these IDs from JDW materials or nodes via `assets.sdf2d` and override parameters/variants in-world if needed.
- Keep new 2D assets in this folder with the `jda.sdf2d.*` prefix to stay consistent with the standard and avoid clashes with 3D assets.
