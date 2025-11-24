Node definition snippet for reference/testing. Nodes hold transform, material, and a source (`inline_sdf` or `jda`) plus optional raymarch overrides. In full JDW files, nodes live inside `worlds[].nodes`.

Key fields:
- `id`: unique per document.
- `layer`: layer id this node belongs to.
- `transform`: `position`, `rotation_euler`, `scale`, `space`.
- `material`: material id (global/world-local).
- `source`: one of:
  - `inline_sdf` with `sdf_tree` (primitive/op/modifier)
  - `jda` with `ref`, optional `variant`, `param_overrides`
- `raymarch`: optional partial overrides.

Examples: `node.ground.json` (inline plane) and `node.hero.json` (uses `jda.shape.rounded_box`).
