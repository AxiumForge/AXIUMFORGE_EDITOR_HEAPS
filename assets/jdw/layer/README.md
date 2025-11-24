Layer definition snippet for reference/testing. Layers bind dimension, visibility, render order, and optional raymarch overrides. In a full JDW file, layers live inside `worlds[].layers`, but this folder keeps small examples for quick reuse.

Key fields:
- `id`: unique per document.
- `dim`: `"2D"` or `"3D"`.
- `visible`: boolean.
- `render_order`: integer sort key.
- `raymarch`: optional partial overrides.
- `nodes`: list of node ids assigned to this layer.

Example: `layer.main_3d.json` shows a simple 3D layer.
