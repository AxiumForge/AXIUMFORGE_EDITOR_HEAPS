package ui;

import h2d.Object;
import h2d.Text;
import h2d.Graphics;
import ui.InspectorModel;

/**
 * Inspector UI Panel
 *
 * Displays metadata and properties of the currently selected JDA asset.
 * Right-side panel with read-only information display.
 */
class Inspector extends Object {

    var background:Graphics;
    var titleText:Text;
    var contentText:Text;

    var panelWidth:Int = 300;
    var panelHeight:Int;
    var padding:Int = 10;

    public function new(parent:Object, windowHeight:Int) {
        super(parent);

        this.panelHeight = windowHeight;

        // Create semi-transparent background
        background = new Graphics(this);
        background.beginFill(0x222222, 0.9);
        background.drawRect(0, 0, panelWidth, panelHeight);
        background.endFill();

        // Create title text
        titleText = new Text(hxd.res.DefaultFont.get(), this);
        titleText.text = "Inspector";
        titleText.textColor = 0xFFFFFF;
        titleText.x = padding;
        titleText.y = padding;

        // Create content text
        contentText = new Text(hxd.res.DefaultFont.get(), this);
        contentText.textColor = 0xCCCCCC;
        contentText.x = padding;
        contentText.y = titleText.y + 25;
        contentText.maxWidth = panelWidth - (padding * 2);
    }

    /**
     * Update inspector with new asset data
     */
    public function updateData(data:InspectorData) {
        var content = "";

        // Metadata section
        content += "=== Metadata ===\n";
        content += 'ID: ${data.id}\n';
        content += 'Type: ${data.type}\n';
        content += 'Version: ${data.jdaVersion}\n';
        content += "\n";

        // Parameters section
        if (data.parameters.length > 0) {
            content += "=== Parameters ===\n";
            for (param in data.parameters) {
                content += '${param.name} (${param.type})\n';
                content += '  default: ${param.defaultValue}\n';
                if (param.hasMin) {
                    content += '  min: ${param.min}\n';
                }
                if (param.hasMax) {
                    content += '  max: ${param.max}\n';
                }
            }
            content += "\n";
        }

        // Materials section
        if (data.materials.length > 0) {
            content += "=== Materials ===\n";
            for (material in data.materials) {
                content += '${material.name}\n';
                content += '  model: ${material.shadingModel}\n';
                content += '  color: RGB(${formatFloat(material.baseColor.r)}, ${formatFloat(material.baseColor.g)}, ${formatFloat(material.baseColor.b)})\n';
                content += '  roughness: ${material.roughness}\n';
                content += '  metallic: ${material.metallic}\n';
            }
            content += "\n";
        }

        // Variants section
        if (data.variants.length > 0) {
            content += "=== Variants ===\n";
            for (variant in data.variants) {
                content += '${variant.name}\n';
                for (param in variant.params) {
                    content += '  ${param.name}: ${param.value}\n';
                }
            }
            content += "\n";
        }

        // Attach points section
        if (data.attachPoints.length > 0) {
            content += "=== Attach Points ===\n";
            for (point in data.attachPoints) {
                content += '${point.name}\n';
                content += '  pos: (${formatFloat(point.position.x)}, ${formatFloat(point.position.y)}, ${formatFloat(point.position.z)})\n';
            }
            content += "\n";
        }

        contentText.text = content;
    }

    /**
     * Helper function to format float values for display
     */
    function formatFloat(value:Float):String {
        return Std.string(Math.round(value * 100) / 100);
    }

    /**
     * Position inspector panel at right side of screen
     */
    public function positionRight(screenWidth:Int) {
        this.x = screenWidth - panelWidth;
        this.y = 0;
    }
}
