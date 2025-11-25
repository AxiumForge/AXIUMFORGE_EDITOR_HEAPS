package loader;

import utest.Test;
import utest.Assert;
import loader.JdwLoader;
import loader.JdwTypes;
import loader.Jda3dTypes.PrimitiveShape;

/**
 * TDD Tests for JDW (JSON Description of Worlds) Loader
 *
 * Test Coverage:
 * - Document metadata loading
 * - Globals (space, raymarch, materials, assets)
 * - World structure (layers, nodes, bounds)
 * - Node sources (inline_sdf, jda references)
 * - Transform parsing
 * - Asset registry
 */
class JdwLoaderTest extends Test {

    var testFilePath:String = "assets/jdw/world/world.demo_axium.json";

    // ════════════════════════════════════════════════════════════════
    // Test 1: Load Document Metadata
    // ════════════════════════════════════════════════════════════════

    function testLoadDocument() {
        var doc = JdwLoader.loadFromFile(testFilePath);

        Assert.notNull(doc);
        Assert.equals("0.1.0", doc.jdw_version);
        Assert.equals("jdw.demo.axium", doc.id);
    }

    function testLoadMeta() {
        var doc = JdwLoader.loadFromFile(testFilePath);

        Assert.notNull(doc.meta);
        Assert.equals("Axium JDW Demo", doc.meta.title);
        Assert.equals("Lars + AI", doc.meta.author);
        Assert.isTrue(doc.meta.description.length > 0);
    }

    // ════════════════════════════════════════════════════════════════
    // Test 2: Globals - Space & Raymarch
    // ════════════════════════════════════════════════════════════════

    function testLoadGlobalsSpace() {
        var doc = JdwLoader.loadFromFile(testFilePath);

        Assert.notNull(doc.globals);
        Assert.notNull(doc.globals.space);
        Assert.equals("3D", doc.globals.space.dim);
        Assert.equals("y+", doc.globals.space.up);
        Assert.equals("z-", doc.globals.space.forward);
        Assert.equals("x+", doc.globals.space.right);
    }

    function testLoadGlobalsRaymarch() {
        var doc = JdwLoader.loadFromFile(testFilePath);

        Assert.notNull(doc.globals.raymarch);
        Assert.equals(96, doc.globals.raymarch.max_steps);
        Assert.equals(0.0005, doc.globals.raymarch.hit_epsilon);
        Assert.equals(50.0, doc.globals.raymarch.max_distance);
    }

    // ════════════════════════════════════════════════════════════════
    // Test 3: Globals - Materials
    // ════════════════════════════════════════════════════════════════

    function testLoadGlobalsMaterials() {
        var doc = JdwLoader.loadFromFile(testFilePath);

        Assert.notNull(doc.globals.materials);
        Assert.isTrue(doc.globals.materials.exists("mat.ground"));

        var groundMat = doc.globals.materials.get("mat.ground");
        Assert.equals("lambert", groundMat.shading_model);
        Assert.equals(4, groundMat.base_color.length);  // RGBA
        Assert.equals(0.2, groundMat.base_color[0]);
    }

    // ════════════════════════════════════════════════════════════════
    // Test 4: Globals - Asset Registry
    // ════════════════════════════════════════════════════════════════

    function testLoadGlobalsAssets() {
        var doc = JdwLoader.loadFromFile(testFilePath);

        Assert.notNull(doc.globals.assets);
        Assert.notNull(doc.globals.assets.jda);

        Assert.isTrue(doc.globals.assets.jda.exists("jda.shape.sphere_basic"));
        Assert.isTrue(doc.globals.assets.jda.exists("jda.shape.rounded_box"));
        Assert.isTrue(doc.globals.assets.jda.exists("jda.shape.pillar_repeat"));

        var spherePath = doc.globals.assets.jda.get("jda.shape.sphere_basic");
        Assert.isTrue(spherePath.indexOf("sphere_basic.json") >= 0);
    }

    // ════════════════════════════════════════════════════════════════
    // Test 5: Worlds Structure
    // ════════════════════════════════════════════════════════════════

    function testLoadWorlds() {
        var doc = JdwLoader.loadFromFile(testFilePath);

        Assert.notNull(doc.worlds);
        Assert.equals(1, doc.worlds.length);

        var world = doc.worlds[0];
        Assert.equals("world.main", world.id);
        Assert.equals("Demo World", world.name);
    }

    function testLoadWorldBounds() {
        var doc = JdwLoader.loadFromFile(testFilePath);
        var world = doc.worlds[0];

        Assert.notNull(world.bounds);
        Assert.equals("aabb", world.bounds.type);
        Assert.equals(-20, world.bounds.min[0]);
        Assert.equals(20, world.bounds.max[0]);
    }

    // ════════════════════════════════════════════════════════════════
    // Test 6: Layers
    // ════════════════════════════════════════════════════════════════

    function testLoadLayers() {
        var doc = JdwLoader.loadFromFile(testFilePath);
        var world = doc.worlds[0];

        Assert.notNull(world.layers);
        Assert.equals(1, world.layers.length);

        var layer = world.layers[0];
        Assert.equals("layer.main_3d", layer.id);
        Assert.equals("3D", layer.dim);
        Assert.isTrue(layer.visible);
        Assert.equals(0, layer.render_order);
    }

    function testLoadLayerNodes() {
        var doc = JdwLoader.loadFromFile(testFilePath);
        var world = doc.worlds[0];
        var layer = world.layers[0];

        Assert.notNull(layer.nodes);
        Assert.equals(2, layer.nodes.length);
        Assert.equals("node.ground", layer.nodes[0]);
        Assert.equals("node.hero", layer.nodes[1]);
    }

    // ════════════════════════════════════════════════════════════════
    // Test 7: Nodes - Basic Structure
    // ════════════════════════════════════════════════════════════════

    function testLoadNodes() {
        var doc = JdwLoader.loadFromFile(testFilePath);
        var world = doc.worlds[0];

        Assert.notNull(world.nodes);
        Assert.equals(2, world.nodes.length);
    }

    function testLoadNodeGround() {
        var doc = JdwLoader.loadFromFile(testFilePath);
        var world = doc.worlds[0];
        var groundNode = world.nodes[0];

        Assert.equals("node.ground", groundNode.id);
        Assert.equals("layer.main_3d", groundNode.layer);
        Assert.equals("mat.ground", groundNode.material);
    }

    function testLoadNodeHero() {
        var doc = JdwLoader.loadFromFile(testFilePath);
        var world = doc.worlds[0];
        var heroNode = world.nodes[1];

        Assert.equals("node.hero", heroNode.id);
        Assert.equals("layer.main_3d", heroNode.layer);
        Assert.equals("mat.default", heroNode.material);
    }

    // ════════════════════════════════════════════════════════════════
    // Test 8: Node Transforms
    // ════════════════════════════════════════════════════════════════

    function testLoadNodeTransform() {
        var doc = JdwLoader.loadFromFile(testFilePath);
        var world = doc.worlds[0];
        var heroNode = world.nodes[1];

        Assert.notNull(heroNode.transform);
        Assert.equals(0.0, heroNode.transform.position[0]);  // x
        Assert.equals(1.0, heroNode.transform.position[1]);  // y
        Assert.equals(0.0, heroNode.transform.position[2]);  // z

        Assert.equals(0.0, heroNode.transform.rotation_euler[0]);
        Assert.equals(25.0, heroNode.transform.rotation_euler[1]);

        Assert.equals("world", heroNode.transform.space);
    }

    // ════════════════════════════════════════════════════════════════
    // Test 9: Node Sources - Inline SDF
    // ════════════════════════════════════════════════════════════════

    function testLoadNodeSourceInlineSdf() {
        var doc = JdwLoader.loadFromFile(testFilePath);
        var world = doc.worlds[0];
        var groundNode = world.nodes[0];

        Assert.notNull(groundNode.source);

        switch(groundNode.source) {
            case InlineSdf(sdfTree):
                Assert.notNull(sdfTree);
                // Ground node has inline plane primitive
                switch(sdfTree) {
                    case Primitive(dim, shape, params):
                        Assert.equals(Plane, shape);
                    default:
                        Assert.fail("Expected Primitive node");
                }
            default:
                Assert.fail("Expected InlineSdf source");
        }
    }

    // ════════════════════════════════════════════════════════════════
    // Test 10: Node Sources - JDA Reference
    // ════════════════════════════════════════════════════════════════

    function testLoadNodeSourceJdaReference() {
        var doc = JdwLoader.loadFromFile(testFilePath);
        var world = doc.worlds[0];
        var heroNode = world.nodes[1];

        Assert.notNull(heroNode.source);

        switch(heroNode.source) {
            case JdaReference(ref, variant, paramOverrides):
                Assert.equals("jda.shape.rounded_box", ref);
                Assert.equals("hero", variant);
                Assert.notNull(paramOverrides);
                Assert.isTrue(paramOverrides.exists("fillet"));
                Assert.equals(0.22, paramOverrides.get("fillet"));
            default:
                Assert.fail("Expected JdaReference source");
        }
    }
}
