# REFACTOR.md

## Status

### TEST
- [X] Fix errors - ALL 205 TESTS PASSING ✅

---

## Next: File Picker Implementation

### [] **Implement**: System File Picker for Asset Selection

**Intention**: Make a file picker popup/system file picker for selecting asset folders

**Current State**:
- ✅ Asset list display works (shows files in a folder)
- ❌ Cannot select which folder contains assets

**Requirements**:
- Native system file picker dialog
- Folder selection (not file selection)
- Update asset list when new folder selected
- File picker will have larger role later in project

**Related Code**:
- `src/ui/AssetSelector.hx` - Current asset list UI
- Platform: macOS (Darwin 25.1.0)

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
