# REFACTOR.md

## Status

### TEST
- [X] Fix errors - ALL 205 TESTS PASSING ✅

---

## Next: File Picker Implementation

### [X] **Implement**: File Picker for Asset Selection ✅

**Intention**: Make a file picker popup/system file picker for selecting asset folders

**Implemented Solutions**:

1. **CLI Support** ✅
   ```bash
   hl output.hl path/to/asset.json
   ```
   - Reads `Sys.args()` in `Main.main()`
   - Loads asset from command line argument
   - Auto-switches to correct shader

2. **In-App File Browser Popup** ✅
   - `src/ui/FileBrowser.hx` - Cross-platform popup overlay
   - Directory navigation (up/down)
   - Filters for .json files
   - Click-to-select functionality
   - AI and human friendly

**Code**:
- `src/Main.hx` - CLI argument parsing
- `src/ui/FileBrowser.hx` - Popup file browser
- `src/ui/AssetSelector.hx` - Browse button integration

---

## [X] JDW Loader (VP5 Phase 5.3) ✅ COMPLETE

**Status**: All tests passing (205/205 assertions)

**Implementation**: JDW Loader was already fully implemented!

- [X] Load JDW JSON (loadFromFile, loadFromString)
- [X] Parse scene hierarchy (worlds → layers → nodes)
- [X] Resolve asset references (JDA + 2D SDF assets)
- [X] Parse materials with PBR properties
- [X] Parse inline SDF nodes (reuses Jda3dLoader.parseSdfTree)
- [X] Parse JDA reference nodes with variant + param overrides
- [X] **Validate**: All JDW loader tests pass ✅

**Test Coverage**:
- 14 test cases covering all JDW features
- Document metadata, globals (space, raymarch, materials, assets)
- World structure (layers, nodes, bounds)
- Node transforms and sources (inline_sdf, jda references)
- All tests passing with 205/205 total assertions
