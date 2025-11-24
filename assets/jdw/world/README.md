JDW world document = top-level container (`jdw_version`, `id`, `meta`, `units`, `globals`, `worlds`). Use this when you want a complete scene/level in one file. Best practice: keep layers + nodes *inline* inside the world entry so the world file is self-contained, while assets (JDA/SDF2D) stay external and referenced by id/path.

Key fields:
- `jdw_version`: schema version string.
- `meta`: title/author/description.
- `units`: world_unit + reference_scales.
- `globals`: defaults for space/time/render/raymarch/materials/shaders/assets.
- `worlds`: array of world objects (with `layers` and `nodes` references).

Example: `world.demo_axium.json` in this folder shows a minimal but valid document using local JDA assets with layers/nodes embedded.
