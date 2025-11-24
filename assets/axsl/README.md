AxiumSL (AxSL) assets: DSL shaders that target HXSL first, per `docs/AxiumSLang.md` and `docs/axslv01.md`. This folder holds source `.axsl` files and example generated HXSL so the pipeline `AxSL source → IR → HXSL` stays visible and testable.

## Scope (v0.1 MVP)
- Single shader kind: `sdf_raymarch` (fragment).
- Types: `float|bool|vec2|vec3|vec4|mat3|mat4`.
- Sections: `uniform` declarations, `fn` helpers, `entry fragment <name>(...) -> vec4`.
- No structs/samplers/textures yet; HXSL is the primary backend.

## File layout
- `examples/` – paired `.axsl` source and `.hxsl` output to illustrate mapping.
- Future: `backends/` or `ir/` can store serialized IR once parser/emitter exists.

## JDW/JDA embedding
- JDA/JDW shader blocks can carry:
  - `axiumsl.source` (text from `.axsl`)
  - `axiumsl.ir` (serialized AST once available)
  - `backends.hxsl` (generated HXSL path)
- Keep AxSL ids/names stable so JDW/JDA can reference them without extra mapping.

## References
- Syntax/grammar: `docs/axslv01.md`
- Roadmap/IR/backends: `docs/AxiumSLang.md`
- HXSL pipeline context: `docs/hxsl.md`
