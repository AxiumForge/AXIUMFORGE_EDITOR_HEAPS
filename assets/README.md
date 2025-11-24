AxiumSystem asset library, structured per `docs/jdw_sdf_csg_world_standard_v_0.md` section 13 (JDA). Each subfolder keeps a clear asset type to mirror the JDW/JDA separation:

- `jda3d/` – 3D SDF/CSG assets (type `sdf3d`).
- `jda2d/` – 2D SDF assets usable as overlays/masks (type `sdf2d`).
- `jds3d/` – reserved for serialized JDW scenes/worlds once we start exporting.
- `jdw/` – JDW documents/examples (worlds, layers, nodes).
- `axsl/` – Axium shader assets (to be handled separately after SDF/JDA).

Add new assets as standalone JDA JSON files under the matching folder. Keep IDs namespaced as `jda.*` so JDW `assets` blocks can reference them directly without extra mapping.
