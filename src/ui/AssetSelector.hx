package ui;

import h2d.Text;
import h2d.Object;
import h2d.Interactive;
import h2d.Graphics;

/**
 * Asset Selector UI Panel
 *
 * Simple panel for selecting JDA assets to load.
 * Displays list of available assets with click-to-load functionality.
 */
class AssetSelector extends Object {

    var assets:Array<AssetInfo>;
    var onAssetSelected:String->Void;
    var currentAssetText:Text;
    var panelBg:Graphics;

    public function new(parent:Object, onSelect:String->Void) {
        super(parent);
        this.onAssetSelected = onSelect;

        // Available assets (hardcoded for now - could scan directory later)
        assets = [
            {name: "Sphere", path: "assets/jda3d/jda.shape.sphere_basic.json"},
            {name: "Rounded Box", path: "assets/jda3d/jda.shape.rounded_box.json"},
            {name: "Pillar Repeat", path: "assets/jda3d/jda.shape.pillar_repeat.json"}
        ];

        buildUI();
    }

    function buildUI() {
        // Panel background
        panelBg = new Graphics(this);
        panelBg.beginFill(0x222222, 0.9);
        panelBg.drawRect(0, 0, 200, 150);
        panelBg.endFill();

        // Title
        var title = new Text(hxd.res.DefaultFont.get(), this);
        title.text = "JDA Assets";
        title.textColor = 0xFFFFFF;
        title.x = 10;
        title.y = 10;

        // Current asset display
        currentAssetText = new Text(hxd.res.DefaultFont.get(), this);
        currentAssetText.text = "Current: Sphere";
        currentAssetText.textColor = 0xAAAAAAFF;
        currentAssetText.x = 10;
        currentAssetText.y = 30;
        currentAssetText.maxWidth = 180;

        // Asset buttons
        var yOffset = 55;
        for (i in 0...assets.length) {
            createAssetButton(assets[i], yOffset);
            yOffset += 25;
        }
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
        trace('Asset selected: ${asset.name}');
        currentAssetText.text = 'Current: ${asset.name}';

        if (onAssetSelected != null) {
            onAssetSelected(asset.name);  // Pass name instead of path
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
