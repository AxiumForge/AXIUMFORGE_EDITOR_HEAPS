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

## JDW Loader (VP5 Phase 5.3) - DEFERRED

**Note**: JDW Loader tests already exist and pass. Implementation deferred until after file picker.

- [] Load JDW JSON (loadFromFile, loadFromString)
- [] Parse scene hierarchy (worlds → layers → nodes)
- [] Resolve asset references (JDA + 2D SDF assets)
- [] Parse materials with PBR properties
- [] Parse inline SDF nodes (reuses Jda3dLoader.parseSdfTree)
- [] Parse JDA reference nodes with variant + param overrides
- [] **Validate**: All JDW loader tests pass ✅
