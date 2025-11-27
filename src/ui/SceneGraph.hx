package ui;

import h2d.Object;
import h2d.Text;
import h2d.Graphics;
import loader.JdwTypes;

/**
 * Scene Graph UI Panel
 *
 * Displays JDW world hierarchy:
 * - Worlds
 *   - Layers
 *     - Nodes
 *
 * Left-side panel with tree view structure.
 */
class SceneGraph extends Object {

    var background:Graphics;
    var titleText:Text;
    var contentText:Text;

    var panelWidth:Int = 280;
    var panelHeight:Int = 500;
    var padding:Int = 10;

    public function new(parent:Object) {
        super(parent);

        // Create semi-transparent background (match Inspector style)
        background = new Graphics(this);
        background.beginFill(0x222222, 0.9);
        background.drawRect(0, 0, panelWidth, panelHeight);
        background.endFill();

        // Create title text
        titleText = new Text(hxd.res.DefaultFont.get(), this);
        titleText.text = "Scene Graph";
        titleText.textColor = 0xFFFFFF;
        titleText.x = padding;
        titleText.y = padding;

        // Create content text
        contentText = new Text(hxd.res.DefaultFont.get(), this);
        contentText.textColor = 0xCCCCCC;
        contentText.x = padding;
        contentText.y = titleText.y + 25;
        contentText.maxWidth = panelWidth - (padding * 2);

        // Initial placeholder content
        contentText.text = "No scene loaded";
    }

    /**
     * Update scene graph with JDW document data
     */
    public function updateScene(doc:JdwDocument) {
        var content = "";

        // Document header
        content += '=== ${doc.meta.title} ===\n';
        content += 'ID: ${doc.id}\n';
        content += 'Version: ${doc.jdw_version}\n\n';

        // World hierarchy
        for (world in doc.worlds) {
            content += 'World: ${world.name}\n';
            content += '  Bounds: ${world.bounds.type}\n';
            content += '  Layers: ${world.layers.length}\n';
            content += '  Nodes: ${world.nodes.length}\n\n';

            // Layers
            for (layer in world.layers) {
                content += '  Layer: ${layer.id}\n';
                content += '    Dim: ${layer.dim}\n';
                content += '    Visible: ${layer.visible}\n';
                content += '    Render Order: ${layer.render_order}\n';
                content += '    Nodes: ${layer.nodes.length}\n\n';

                // Nodes in layer
                for (nodeId in layer.nodes) {
                    var node = findNodeById(world.nodes, nodeId);
                    if (node != null) {
                        var sourceDesc = getSourceDescription(node.source);
                        content += '    Node: ${node.id}\n';
                        content += '      Source: $sourceDesc\n';
                        content += '      Material: ${node.material}\n';
                        content += '      Position: [${formatVec3(node.transform.position)}]\n';
                        content += '\n';
                    }
                }
            }
        }

        contentText.text = content;
    }

    /**
     * Find node by ID in nodes array
     */
    function findNodeById(nodes:Array<JdwNode>, id:String):Null<JdwNode> {
        for (node in nodes) {
            if (node.id == id) return node;
        }
        return null;
    }

    /**
     * Get human-readable description of node source
     */
    function getSourceDescription(source:NodeSource):String {
        return switch(source) {
            case InlineSdf(sdfTree):
                "Inline SDF";
            case JdaReference(ref, variant, overrides):
                '$ref (variant: $variant)';
        }
    }

    /**
     * Format Vec3 array as string
     */
    function formatVec3(arr:Array<Float>):String {
        if (arr == null || arr.length < 3) return "?";
        return '${formatFloat(arr[0])}, ${formatFloat(arr[1])}, ${formatFloat(arr[2])}';
    }

    /**
     * Format float with max 2 decimals
     */
    function formatFloat(f:Float):String {
        return Std.string(Math.round(f * 100) / 100);
    }
}
