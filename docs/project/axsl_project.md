# AxiumSL Implementation Project

> **AI:DevOps Workflow** - AI handles implementation, we both handle operations and validation.

---

## 0. Executive Summary

**Goal**: Implement AxiumSL v0.1 - a minimal shader DSL for SDF/CSG raymarching that compiles to HXSL.

**Timeline**: 4-6 weeks (depending on complexity)

**Success Criteria**:
- ✅ Parser converts `.axsl` source to IR
- ✅ IR serializes to/from JSON
- ✅ HXSL generator produces valid Heaps-compatible shaders
- ✅ Integration with existing Heaps viewer works
- ✅ At least 3 working example shaders (sphere, CSG, complex scene)

**Dependencies**:
- Existing: `src/Main.hx`, `src/RaymarchShader.hx`, `build.hxml`
- New: `src/axiumsl/` package for parser/IR/backend

---

## 1. Project Structure

```
src/
  axiumsl/
    parser/
      Lexer.hx           # Tokenizer
      Parser.hx          # EBNF → AST
      Token.hx           # Token types
      Ast.hx             # AST node types
    ir/
      Types.hx           # AxType, AxExpr, AxStmt, etc.
      Shader.hx          # AxShader, AxFunction, AxUniform
      Builder.hx         # AST → IR converter
      Validator.hx       # IR validation
    backend/
      Hxsl.hx            # IR → HXSL generator
      Template.hx        # Code generation helpers
    Compiler.hx          # Main entry point: .axsl → .hxsl
    Error.hx             # Error types and reporting

examples/
  shaders/
    sphere.axsl          # Simple sphere SDF
    csg_demo.axsl        # CSG operations demo
    bobling.axsl         # Complex creature shader

tests/
  axiumsl/
    ParserTest.hx        # Parser unit tests
    IRTest.hx            # IR construction tests
    HxslGenTest.hx       # HXSL generation tests
    IntegrationTest.hx   # End-to-end tests

docs/
  project/
    axsl_project.md      # This file
    progress.md          # Weekly progress tracking
```

---

## 2. Implementation Phases

### Phase 0: Foundation & Setup ⏱️ 3-5 days

**Goal**: Set up project structure and core type definitions.

#### Tasks:

- [ ] **0.1** Create directory structure
  - `src/axiumsl/parser/`, `src/axiumsl/ir/`, `src/axiumsl/backend/`
  - `examples/shaders/`, `tests/axiumsl/`
  - **Owner**: AI
  - **Validation**: Directory tree matches structure above

- [ ] **0.2** Define core IR types in `src/axiumsl/ir/Types.hx`
  - Implement `AxType` enum (TFloat, TVec2, TVec3, TVec4, TMat3, TMat4, TBool)
  - Implement `AxExpr` enum (as per spec section 4.2 in AxiumSLang.md)
  - Implement `AxStmt` enum (SLet, SAssign, SReturn, SIf, SFor, SBreak)
  - Implement `AxBinOp`, `AxUnaryOp` enums
  - **Owner**: AI
  - **Validation**: Types compile, match spec exactly
  - **Reference**: `docs/AxiumSLang.md` section 4.1-4.3

- [ ] **0.3** Define shader structures in `src/axiumsl/ir/Shader.hx`
  - `AxUniform`, `AxParam`, `AxFunction`, `AxShader` typedefs
  - `AxShaderKind` enum (SdfRaymarchFragment for v0.1)
  - **Owner**: AI
  - **Validation**: Types match spec, can instantiate test shader
  - **Reference**: `docs/AxiumSLang.md` section 4.3

- [ ] **0.4** Create error handling system in `src/axiumsl/Error.hx`
  - `AxError` enum (ParseError, TypeError, IRError, BackendError)
  - `ErrorReporter` class with line/column info
  - Pretty-print error messages
  - **Owner**: AI
  - **Validation**: Can create and format error messages

- [ ] **0.5** Setup test framework
  - Add test library to `build.hxml` (use haxe.unit or utest)
  - Create `tests/TestMain.hx` entry point
  - Create `tests/axiumsl/TestHelper.hx` with common utilities
  - **Owner**: AI
  - **Validation**: `haxe tests/build.hxml` runs successfully

**Phase 0 Milestone**: ✅ Foundation compiles, types defined, test framework ready

---

### Phase 1: Lexer & Parser ⏱️ 7-10 days

**Goal**: Convert `.axsl` source text to AST.

#### Tasks:

- [ ] **1.1** Implement Lexer in `src/axiumsl/parser/Lexer.hx`
  - Define `Token` type in `src/axiumsl/parser/Token.hx`
  - Tokenize keywords (shader, uniform, fn, entry, fragment, let, return, if, else, for, break)
  - Tokenize types (float, bool, vec2, vec3, vec4, mat3, mat4)
  - Tokenize literals (float, bool, identifiers)
  - Tokenize operators (+, -, *, /, ==, !=, <, >, <=, >=, &&, ||, !)
  - Tokenize punctuation ({, }, (, ), ;, :, ,, ., ..)
  - Handle whitespace and comments (// single-line)
  - **Owner**: AI
  - **Validation**: Unit tests tokenize example shaders correctly
  - **Reference**: `docs/axslv01.md` section 3.3, 6

- [ ] **1.2** Define AST node types in `src/axiumsl/parser/Ast.hx`
  - `AstShader`, `AstFunction`, `AstUniform` typedefs
  - `AstStmt`, `AstExpr` enums (match grammar)
  - Include source position info (line, column) in all nodes
  - **Owner**: AI
  - **Validation**: AST types are complete and cover all grammar rules
  - **Reference**: `docs/axslv01.md` section 4

- [ ] **1.3** Implement Parser in `src/axiumsl/parser/Parser.hx`
  - Recursive descent parser following EBNF grammar
  - Parse shader declaration (section 4.1)
  - Parse uniform declarations (section 4.2)
  - Parse function declarations (section 4.3)
  - Parse entry declarations (section 4.4)
  - Parse statements (section 5)
  - Parse expressions with correct precedence (section 6)
  - **Owner**: AI
  - **Validation**: Parse `examples/shaders/sphere.axsl` successfully
  - **Reference**: `docs/axslv01.md` section 4-6

- [ ] **1.4** Implement error recovery in Parser
  - Graceful handling of syntax errors
  - Continue parsing to find multiple errors
  - Provide helpful error messages with line/column
  - **Owner**: AI
  - **Validation**: Parsing invalid shader reports clear errors

- [ ] **1.5** Write parser tests in `tests/axiumsl/ParserTest.hx`
  - Test each grammar rule independently
  - Test error cases
  - Test example shaders from spec
  - **Owner**: AI
  - **Validation**: All tests pass (`haxe tests/build.hxml`)

**Phase 1 Milestone**: ✅ Parser converts .axsl to AST with good error messages

---

### Phase 2: IR Construction ⏱️ 5-7 days

**Goal**: Convert AST to validated IR that can be serialized to JSON.

#### Tasks:

- [ ] **2.1** Implement AST → IR converter in `src/axiumsl/ir/Builder.hx`
  - `build(ast: AstShader): AxShader` main entry point
  - Convert AST types to AxType
  - Convert AST expressions to AxExpr
  - Convert AST statements to AxStmt
  - Build AxFunction from AstFunction
  - Build complete AxShader
  - **Owner**: AI
  - **Validation**: AST from phase 1 converts to IR
  - **Reference**: `docs/AxiumSLang.md` section 4, `docs/axslv01.md` section 7.1

- [ ] **2.2** Implement IR validation in `src/axiumsl/ir/Validator.hx`
  - Check that uniforms are declared before use
  - Check that functions are declared before called
  - Check that variables are declared before use
  - Verify entry function exists and has correct signature
  - Basic type compatibility checks (optional for v0.1)
  - **Owner**: AI
  - **Validation**: Validator catches common errors in test cases

- [ ] **2.3** Implement JSON serialization for IR
  - `AxShader.toJson(): Dynamic` method
  - `AxShader.fromJson(json: Dynamic): AxShader` method
  - Handle all IR types (AxExpr, AxStmt, AxFunction, etc.)
  - **Owner**: AI
  - **Validation**: Serialize → Deserialize roundtrip preserves IR
  - **Reference**: This enables JDW integration later

- [ ] **2.4** Write IR tests in `tests/axiumsl/IRTest.hx`
  - Test AST → IR conversion
  - Test IR validation
  - Test JSON serialization/deserialization
  - Test error cases
  - **Owner**: AI
  - **Validation**: All tests pass

**Phase 2 Milestone**: ✅ AST converts to validated IR, IR serializes to JSON

---

### Phase 3: HXSL Backend ⏱️ 7-10 days

**Goal**: Generate valid HXSL code from IR.

#### Tasks:

- [ ] **3.1** Implement HXSL code generator in `src/axiumsl/backend/Hxsl.hx`
  - `generate(shader: AxShader): String` main entry point
  - Generate HXSL class structure
  - Convert AxType to HXSL types (Float, Vec2, Vec3, Vec4, Mat3, Mat4, Bool)
  - Generate uniform declarations (@param var)
  - Generate helper functions
  - Generate entry fragment function
  - **Owner**: AI
  - **Validation**: Generated code compiles with Heaps HXSL compiler
  - **Reference**: `docs/axslv01.md` section 7.2, existing `src/RaymarchShader.hx`

- [ ] **3.2** Implement expression code generation
  - Binary operators (+, -, *, /, <, >, ==, !=, &&, ||)
  - Unary operators (-, +, !)
  - Function calls (length, normalize, etc.)
  - Vector constructors (vec2, vec3, vec4)
  - Swizzles (.x, .xy, .xyz, etc.)
  - Variable references
  - **Owner**: AI
  - **Validation**: All expression types generate valid HXSL

- [ ] **3.3** Implement statement code generation
  - Let declarations (var in HXSL)
  - Assignments
  - Return statements
  - If/else blocks
  - For loops (translate range loops to HXSL for)
  - Break statements
  - **Owner**: AI
  - **Validation**: All statement types generate valid HXSL

- [ ] **3.4** Create code generation templates in `src/axiumsl/backend/Template.hx`
  - HXSL shader class template
  - Fragment entry wrapper
  - Common helper utilities
  - **Owner**: AI
  - **Validation**: Templates generate clean, readable HXSL

- [ ] **3.5** Test HXSL generation in `tests/axiumsl/HxslGenTest.hx`
  - Test each IR construct generates correct HXSL
  - Test complete shader examples
  - Verify generated HXSL compiles with Heaps
  - **Owner**: AI
  - **Validation**: All tests pass, generated shaders work in Heaps

**Phase 3 Milestone**: ✅ IR generates valid HXSL that compiles and runs in Heaps

---

### Phase 4: Compiler Integration ⏱️ 3-5 days

**Goal**: Create end-to-end compiler and integrate with Heaps viewer.

#### Tasks:

- [ ] **4.1** Implement main compiler in `src/axiumsl/Compiler.hx`
  - `compile(source: String): Result<String, Array<AxError>>` method
  - Pipeline: source → Lexer → Parser → AST → Builder → IR → Validator → HXSL Generator
  - Collect and report errors from each stage
  - **Owner**: AI
  - **Validation**: Compiles example shaders end-to-end

- [ ] **4.2** Create example shaders in `examples/shaders/`
  - `sphere.axsl` - Simple SDF sphere (from spec)
  - `csg_demo.axsl` - CSG operations (union, subtract, smooth_union)
  - `bobling.axsl` - Complex creature shader (multiple primitives)
  - **Owner**: AI
  - **Validation**: All examples compile successfully
  - **Reference**: `docs/axslv01.md` section 3.2, `docs/AxiumSLang.md` section 3.2

- [ ] **4.3** Integrate AxiumSL compiler with Heaps viewer
  - Modify `src/Main.hx` to load `.axsl` files
  - Compile to HXSL at runtime
  - Replace current `RaymarchShader.hx` with compiled shader
  - Handle compilation errors gracefully (show in console)
  - **Owner**: AI (with human validation)
  - **Validation**: Viewer loads and renders .axsl shaders
  - **Reference**: Existing `src/Main.hx`, `src/RaymarchShader.hx`

- [ ] **4.4** Add hot-reload support (optional but nice)
  - Watch `examples/shaders/*.axsl` for changes
  - Recompile and reload shader on file save
  - Integrate with existing `watch.sh` script
  - **Owner**: AI
  - **Validation**: Editing .axsl file updates viewer in real-time

**Phase 4 Milestone**: ✅ End-to-end pipeline works, viewer renders AxiumSL shaders

---

### Phase 5: JDW/JDA Integration ⏱️ 3-5 days

**Goal**: Integrate AxiumSL with JDW/JDA specification.

#### Tasks:

- [ ] **5.1** Update JDW spec with AxiumSL fields
  - Add `axiumsl` section to shader definition
  - Add `axiumsl.source`, `axiumsl.ir`, `backends.hxsl` fields
  - Document in `docs/jdw_sdf_csg_world_standard_v_0.md` (or create addendum)
  - **Owner**: AI (with human approval)
  - **Validation**: Spec is clear and complete
  - **Reference**: `docs/AxiumSLang.md` section 2

- [ ] **5.2** Implement JDW serialization
  - Serialize AxShader to JDW shader format
  - Include source, IR (JSON), and generated HXSL
  - Add semantic_model metadata
  - **Owner**: AI
  - **Validation**: Serialized format matches updated spec

- [ ] **5.3** Implement JDW deserialization
  - Load shader from JDW format
  - Support loading from source, IR, or HXSL backend
  - Validate and report errors
  - **Owner**: AI
  - **Validation**: Can load and compile shaders from JDW files

- [ ] **5.4** Create JDW example with AxiumSL shader
  - Complete JDW document with AxiumSL-based shader
  - Include world, layer, node with inline shader
  - Save to `examples/jdw/axiumsl_demo.jdw.json`
  - **Owner**: AI
  - **Validation**: Example loads in viewer (future feature)

**Phase 5 Milestone**: ✅ AxiumSL integrates with JDW/JDA format

---

### Phase 6: Testing & Polish ⏱️ 5-7 days

**Goal**: Comprehensive testing, documentation, and polish.

#### Tasks:

- [ ] **6.1** Write integration tests in `tests/axiumsl/IntegrationTest.hx`
  - End-to-end: .axsl → HXSL → Heaps rendering
  - Test all example shaders
  - Test error handling and reporting
  - Performance benchmarks (compilation time)
  - **Owner**: AI
  - **Validation**: All integration tests pass

- [ ] **6.2** Create developer documentation
  - `docs/axiumsl_guide.md` - How to write AxiumSL shaders
  - `docs/axiumsl_api.md` - Compiler API documentation
  - Code examples and tutorials
  - **Owner**: AI (with human review)
  - **Validation**: Documentation is clear and complete

- [ ] **6.3** Create example gallery
  - 5-10 example shaders demonstrating features
  - Screenshots/GIFs of rendered output
  - Annotated source code
  - Save to `examples/gallery/`
  - **Owner**: AI + Human (screenshots)
  - **Validation**: Gallery is impressive and educational

- [ ] **6.4** Performance optimization
  - Profile parser/compiler performance
  - Optimize hot paths if needed
  - Implement caching for compiled shaders
  - **Owner**: AI
  - **Validation**: Compilation time < 100ms for typical shaders

- [ ] **6.5** Code review and cleanup
  - Review all generated code for quality
  - Add missing comments and documentation
  - Ensure code style is consistent
  - Fix any TODOs or FIXMEs
  - **Owner**: Human + AI
  - **Validation**: Code is clean and maintainable

**Phase 6 Milestone**: ✅ Project is tested, documented, and production-ready

---

## 3. AI:DevOps Workflow

### AI Responsibilities (Development):
1. **Write code** based on specs and tasks
2. **Write tests** for all implemented features
3. **Generate documentation** and examples
4. **Fix bugs** identified during validation

### Human Responsibilities (Operations):
1. **Review** AI-generated code and approve/request changes
2. **Validate** that implementations match specs
3. **Test** generated shaders in Heaps viewer
4. **Make decisions** on architecture and design questions
5. **Update** project documentation and progress

### Workflow Pattern:

```
1. Human assigns task (e.g., "Implement Phase 1.1 - Lexer")
   ↓
2. AI implements task + writes tests
   ↓
3. AI reports completion with summary
   ↓
4. Human validates (runs tests, checks code)
   ↓
5. If OK: Mark task complete ✅
   If NOT: AI fixes issues, goto step 3
   ↓
6. Move to next task
```

### Communication Protocol:

**When AI completes a task:**
```markdown
✅ Task X.Y Complete: [Task Name]

**Changes:**
- Created: [files]
- Modified: [files]

**How to validate:**
1. Run: `haxe build.hxml` (should compile)
2. Run: `haxe tests/build.hxml` (should pass)
3. Check: [specific validation steps]

**Notes:**
- [Any important information]
- [Decisions made]
- [Questions for human]
```

**When human validates:**
```markdown
✅ Task X.Y Validated

[or]

❌ Task X.Y Needs Fixes:
- Issue: [description]
- Expected: [what should happen]
- Actual: [what happens]
```

---

## 4. Dependencies & Prerequisites

**Before starting:**
- ✅ Haxe compiler installed
- ✅ Heaps library (2.1.0) installed
- ✅ HashLink runtime installed
- ✅ Existing viewer working (src/Main.hx compiles and runs)
- ✅ Specs finalized (docs/AxiumSLang.md, docs/axslv01.md)

**External dependencies:**
- None! AxiumSL is self-contained within the Haxe/Heaps ecosystem

---

## 5. Risk Management

### Potential Issues:

1. **HXSL compatibility**
   - Risk: Generated HXSL may not compile
   - Mitigation: Study existing `RaymarchShader.hx`, test incrementally

2. **Parser complexity**
   - Risk: Grammar is complex, parser bugs likely
   - Mitigation: Comprehensive unit tests, test-driven development

3. **Performance**
   - Risk: Runtime compilation may be slow
   - Mitigation: Profile early, implement caching

4. **Scope creep**
   - Risk: Temptation to add features beyond v0.1
   - Mitigation: Stick to spec, defer features to v0.2+

---

## 6. Success Metrics

**Phase 0-3**: Technical foundation
- ✅ All tests pass
- ✅ Code compiles without warnings
- ✅ IR matches spec exactly

**Phase 4**: Integration success
- ✅ At least 3 example shaders work in viewer
- ✅ Generated HXSL matches quality of hand-written shaders
- ✅ Compilation time < 100ms per shader

**Phase 5**: Ecosystem integration
- ✅ JDW format includes AxiumSL shaders
- ✅ Can serialize/deserialize complete shader definitions

**Phase 6**: Production readiness
- ✅ Documentation complete
- ✅ Example gallery impressive
- ✅ Code is maintainable and well-commented
- ✅ No known critical bugs

---

## 7. Next Steps

**To start implementation:**

1. **Human**: Review this document, approve phases
2. **AI**: Begin Phase 0, Task 0.1 (Create directory structure)
3. **Human**: Create `docs/project/progress.md` for weekly tracking
4. **AI + Human**: Work through phases sequentially

**Ready to begin?** 🚀

Let's start with Phase 0, Task 0.1 when you give the go-ahead!
