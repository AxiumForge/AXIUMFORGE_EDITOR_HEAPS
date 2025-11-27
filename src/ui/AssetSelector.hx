package ui;

import h2d.Text;
import h2d.Object;
import h2d.Interactive;
import h2d.Graphics;
import sys.FileSystem;
import ui.FileBrowser;
using StringTools;

/**
 * Asset Selector UI Panel
 *
 * Simple panel for selecting JDA assets to load.
 * Dynamically scans directory for .json files.
 */
class AssetSelector extends Object {

    var assets:Array<AssetInfo>;
    var onAssetSelected:String->Void;
    var currentAssetText:Text;
    var panelBg:Graphics;
    var defaultDir:String;

    public function new(parent:Object, onSelect:String->Void, ?assetDir:String) {
        super(parent);
        this.onAssetSelected = onSelect;
        this.defaultDir = assetDir != null ? assetDir : "assets/jda3d/";

        // Scan directory for JDA assets
        assets = scanDirectory(defaultDir);

        buildUI();
    }

    /**
     * Scan directory for .json files
     */
    function scanDirectory(dirPath:String):Array<AssetInfo> {
        var foundAssets:Array<AssetInfo> = [];

        if (!FileSystem.exists(dirPath) || !FileSystem.isDirectory(dirPath)) {
            trace('Warning: Directory not found: $dirPath');
            return foundAssets;
        }

        var files = FileSystem.readDirectory(dirPath);
        for (file in files) {
            if (file.endsWith(".json")) {
                var fullPath = dirPath + file;
                var displayName = formatDisplayName(file);
                foundAssets.push({name: displayName, path: fullPath});
            }
        }

        // Sort alphabetically by name
        foundAssets.sort((a, b) -> {
            if (a.name < b.name) return -1;
            if (a.name > b.name) return 1;
            return 0;
        });

        return foundAssets;
    }

    /**
     * Convert filename to display name
     * Example: "jda.shape.sphere_basic.json" -> "Sphere Basic"
     */
    function formatDisplayName(filename:String):String {
        // Remove .json extension
        var name = filename.substr(0, filename.length - 5);

        // Remove "jda.shape." prefix if present
        if (name.indexOf("jda.shape.") == 0) {
            name = name.substr(10);
        }

        // Replace underscores with spaces
        name = name.split("_").join(" ");

        // Capitalize first letter of each word
        var words = name.split(" ");
        var capitalized = words.map(w -> {
            if (w.length == 0) return w;
            return w.charAt(0).toUpperCase() + w.substr(1);
        });

        return capitalized.join(" ");
    }

    function buildUI() {
        // Calculate panel height based on number of assets
        var maxVisibleAssets = 10;  // Show max 10 assets at once
        var visibleAssets = assets.length < maxVisibleAssets ? assets.length : maxVisibleAssets;
        var panelHeight = 80 + (visibleAssets * 25) + 10;  // Header + browse button + assets + padding

        // Panel background
        panelBg = new Graphics(this);
        panelBg.beginFill(0x222222, 0.9);
        panelBg.drawRect(0, 0, 200, panelHeight);
        panelBg.endFill();

        // Title
        var title = new Text(hxd.res.DefaultFont.get(), this);
        title.text = "JDA Assets";
        title.textColor = 0xFFFFFF;
        title.x = 10;
        title.y = 10;

        // Browse button
        createBrowseButton();

        // Directory path display
        var dirText = new Text(hxd.res.DefaultFont.get(), this);
        dirText.text = defaultDir;
        dirText.textColor = 0x888888;
        dirText.x = 10;
        dirText.y = 45;
        dirText.maxWidth = 180;
        dirText.textAlign = Left;

        // Current asset display
        currentAssetText = new Text(hxd.res.DefaultFont.get(), this);
        if (assets.length > 0) {
            currentAssetText.text = 'Current: ${assets[0].name}';
        } else {
            currentAssetText.text = "No assets found";
        }
        currentAssetText.textColor = 0xAAAAAAFF;
        currentAssetText.x = 10;
        currentAssetText.y = 60;
        currentAssetText.maxWidth = 180;

        // Asset count
        var countText = new Text(hxd.res.DefaultFont.get(), this);
        countText.text = '${assets.length} asset${assets.length == 1 ? "" : "s"}';
        countText.textColor = 0x666666;
        countText.x = 150;
        countText.y = 10;

        // Asset buttons
        var yOffset = 80;
        var displayCount = assets.length < maxVisibleAssets ? assets.length : maxVisibleAssets;
        for (i in 0...displayCount) {
            createAssetButton(assets[i], yOffset);
            yOffset += 25;
        }

        // TODO: Add scroll support if assets.length > maxVisibleAssets
    }

    function createBrowseButton() {
        var buttonY = 25;
        var buttonWidth = 80;
        var buttonHeight = 18;

        // Button background
        var btnBg = new Graphics(this);
        btnBg.beginFill(0x4A90E2);
        btnBg.drawRect(110, buttonY, buttonWidth, buttonHeight);
        btnBg.endFill();

        // Button text
        var btnText = new Text(hxd.res.DefaultFont.get(), this);
        btnText.text = "Browse...";
        btnText.textColor = 0xFFFFFF;
        btnText.x = 120;
        btnText.y = buttonY + 2;

        // Interactive area
        var interactive = new Interactive(buttonWidth, buttonHeight, this);
        interactive.x = 110;
        interactive.y = buttonY;
        interactive.onOver = function(e) {
            btnBg.clear();
            btnBg.beginFill(0x5AA0F2);
            btnBg.drawRect(110, buttonY, buttonWidth, buttonHeight);
            btnBg.endFill();
        };
        interactive.onOut = function(e) {
            btnBg.clear();
            btnBg.beginFill(0x4A90E2);
            btnBg.drawRect(110, buttonY, buttonWidth, buttonHeight);
            btnBg.endFill();
        };
        interactive.onClick = function(e) {
            trace("Browse button clicked!");
            openFilePicker();
        };
    }

    function openFilePicker() {
        trace("Opening file browser popup...");

        // Create file browser popup overlay
        var browser = new FileBrowser(
            getScene(),  // Add to root scene
            defaultDir,  // Start in assets directory
            function(selectedPath:String) {
                trace('File browser selected: $selectedPath');
                loadExternalFile(selectedPath);
            }
        );
    }

    function loadExternalFile(filePath:String) {
        // Extract filename for display
        var parts = filePath.split("/");
        var filename = parts[parts.length - 1];
        var displayName = formatDisplayName(filename);

        // Update current asset text
        currentAssetText.text = 'Current: $displayName';

        // Trigger callback with full file path
        if (onAssetSelected != null) {
            onAssetSelected(filePath);
        }

        trace('Loaded external file: $filePath');
    }

    function createAssetButton(asset:AssetInfo, y:Float) {
        // Button background
        var btnBg = new Graphics(this);
        btnBg.beginFill(0x444444);
        btnBg.drawRect(10, y, 180, 20);
        btnBg.endFill();

        // Button text
        var btnText = new Text(hxd.res.DefaultFont.get(), this);
        btnText.text = asset.name;
        btnText.textColor = 0xFFFFFF;
        btnText.x = 15;
        btnText.y = y + 3;

        // Interactive area
        var interactive = new Interactive(180, 20, this);
        interactive.x = 10;
        interactive.y = y;
        interactive.backgroundColor = 0x666666;
        interactive.onOver = function(e) {
            btnBg.clear();
            btnBg.beginFill(0x666666);
            btnBg.drawRect(10, y, 180, 20);
            btnBg.endFill();
        };
        interactive.onOut = function(e) {
            btnBg.clear();
            btnBg.beginFill(0x444444);
            btnBg.drawRect(10, y, 180, 20);
            btnBg.endFill();
        };
        interactive.onClick = function(e) {
            selectAsset(asset);
        };
    }

    function selectAsset(asset:AssetInfo) {
        currentAssetText.text = 'Current: ${asset.name}';

        if (onAssetSelected != null) {
            onAssetSelected(asset.name);  // Pass display name (for switch statement matching)
        }
    }

    public function setPos(xPos:Float, yPos:Float) {
        this.x = xPos;
        this.y = yPos;
    }
}

typedef AssetInfo = {
    var name:String;
    var path:String;
}
