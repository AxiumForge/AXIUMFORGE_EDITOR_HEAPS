JDA3D SDF asset library aligned with `docs/jdw_sdf_csg_world_standard_v_0.md` (section 13). Assets use the JDA top-level shape (`jda_version`, `id`, `type`, `param_schema`, `sdf_tree`, `materials`, `variants`, `attach_points`, `depends`) so the viewer/editor can load them without extra conversion.

## Format (JDA 3D)
- `jda_version`: semantic version of the JDA schema (string).
- `id`: globally unique string, prefixed `jda.*`.
- `type`: `"sdf3d"` for all 3D assets here.
- `param_schema`: optional knobs the editor/runtime may expose. Each entry: `{type, default, min?, max?}`; types can be `float|vec2|vec3|color|bool|int`.
- `sdf_tree`: SDF/CSG AST using only `primitive`, `op`, `modifier` nodes from the JDW doc:
  - `primitive`: `{kind:"primitive", dim:"3D", shape:"sphere|box|plane|torus|capsule|cylinder|... ", params:{...}}`
  - `op`: `{kind:"op", op:"union|subtract|intersect|smooth_union|...", k? , children:[...] }`
  - `modifier`: `{kind:"modifier", modifier:"repeat|twist|bend|mirror|scale|...", params:{...}, child:{...}}`
- `materials`: optional built-in materials keyed by id (minimal PBR/Lambert fields).
- `variants`: named presets mapping parameter keys to values. Loader should merge selected variant values into the active param set before generating the SDF.
- `attach_points`: optional sockets `{position:[x,y,z], orientation:[degX,degY,degZ]}` for composition.
- `depends`: list of other `jda.*` ids if this asset references sub-assets.

## Assets
- `jda.shape.sphere_basic.json` – single sphere primitive, PBR-ish material, top/bottom attach points, variants for default/hero radius.
- `jda.shape.rounded_box.json` – smooth-union between box + sphere to mimic filleted edges, Lambert material, attach points on front/back/top, variants tweak fillet thickness.
- `jda.shape.pillar_repeat.json` – cylinder+cap union repeated on X/Z via modifier `repeat`, gray Lambert material, variants for dense/thin spacing.

## Notes for loaders/editors
- `param_schema` documents tunable fields; `variants` hold suggested parameter sets. Apply variant values into the SDF tree when generating shaders/meshes.
- `sdf_tree` sticks to the primitive/op/modifier layout defined in the JDW doc (no engine-specific extras).
- Materials are minimal; replace or override in-world as needed.
- Keep new assets in this folder with `jda.*` IDs to avoid clashes and keep paths predictable for JDW references.
