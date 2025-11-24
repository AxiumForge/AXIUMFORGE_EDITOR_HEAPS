package loader;

import utest.Test;
import utest.Assert;
import loader.Jda3dLoader;
import loader.Jda3dTypes;

/**
 * Tests for JDA 3D loader
 *
 * TDD workflow: Write tests first, then implement types and loader
 */
class Jda3dLoaderTest extends Test {

    var sphereJsonPath:String = "assets/jda3d/jda.shape.sphere_basic.json";
    var roundedBoxJsonPath:String = "assets/jda3d/jda.shape.rounded_box.json";
    var pillarRepeatJsonPath:String = "assets/jda3d/jda.shape.pillar_repeat.json";

    /**
     * Test loading basic sphere JDA document
     */
    public function testLoadSpherePrimitive() {
        var doc = Jda3dLoader.loadFromFile(sphereJsonPath);

        // Check metadata
        Assert.equals("1.0", doc.jdaVersion);
        Assert.equals("jda.shape.sphere_basic", doc.id);
        Assert.equals("sdf3d", doc.type);
    }

    /**
     * Test parsing param_schema section
     */
    public function testParseParamSchema() {
        var doc = Jda3dLoader.loadFromFile(sphereJsonPath);

        // Check param schema exists
        Assert.notNull(doc.paramSchema);
        Assert.isTrue(doc.paramSchema.exists("radius"));

        // Check param definition
        var radiusParam = doc.paramSchema.get("radius");
        Assert.equals("float", radiusParam.type);
        Assert.floatEquals(1.0, radiusParam.defaultValue, 0.001);
    }

    /**
     * Test parsing simple primitive SDF tree (sphere)
     */
    public function testParsePrimitiveSdfTree() {
        var doc = Jda3dLoader.loadFromFile(sphereJsonPath);

        Assert.notNull(doc.sdfTree);

        switch(doc.sdfTree) {
            case Primitive(dim, shape, params):
                Assert.equals(Dim3D, dim);
                Assert.equals(Sphere, shape);
                Assert.isTrue(params.exists("radius"));
                Assert.floatEquals(1.0, params.get("radius"), 0.001);
            default:
                Assert.fail("Expected Primitive node");
        }
    }

    /**
     * Test parsing CSG operation (smooth_union in rounded_box)
     */
    public function testParseCsgOperation() {
        var doc = Jda3dLoader.loadFromFile(roundedBoxJsonPath);

        Assert.notNull(doc.sdfTree);

        switch(doc.sdfTree) {
            case Operation(op, params, children):
                Assert.equals(SmoothUnion, op);
                Assert.floatEquals(0.18, params.get("k"), 0.001);
                Assert.equals(2, children.length);
            default:
                Assert.fail("Expected Operation node");
        }
    }

    /**
     * Test parsing modifier (repeat in pillar_repeat)
     */
    public function testParseModifier() {
        var doc = Jda3dLoader.loadFromFile(pillarRepeatJsonPath);

        Assert.notNull(doc.sdfTree);

        switch(doc.sdfTree) {
            case Modifier(modifier, params, child):
                Assert.equals(Repeat, modifier);
                Assert.notNull(child);
            default:
                Assert.fail("Expected Modifier node");
        }
    }

    /**
     * Test parsing materials section
     */
    public function testParseMaterials() {
        var doc = Jda3dLoader.loadFromFile(sphereJsonPath);

        Assert.notNull(doc.materials);
        Assert.isTrue(doc.materials.exists("mat.default"));

        var mat = doc.materials.get("mat.default");
        Assert.equals("pbr", mat.shadingModel);
        Assert.equals(4, mat.baseColor.length);
        Assert.floatEquals(0.7, mat.baseColor[0], 0.001);
    }

    /**
     * Test parsing variants section
     */
    public function testParseVariants() {
        var doc = Jda3dLoader.loadFromFile(sphereJsonPath);

        Assert.notNull(doc.variants);
        Assert.isTrue(doc.variants.exists("default"));
        Assert.isTrue(doc.variants.exists("hero"));

        var heroVariant = doc.variants.get("hero");
        Assert.floatEquals(1.25, heroVariant.get("radius"), 0.001);
    }

    /**
     * Test validation - missing required field should throw
     */
    public function testValidationMissingField() {
        var invalidJson = '{"jda_version": "1.0"}'; // Missing id, type, sdf_tree

        Assert.raises(function() {
            Jda3dLoader.loadFromString(invalidJson);
        });
    }

    /**
     * Test validation - invalid sdf_tree kind should throw
     */
    public function testValidationInvalidSdfKind() {
        var invalidJson = '{
            "jda_version": "1.0",
            "id": "test",
            "type": "sdf3d",
            "sdf_tree": {
                "kind": "invalid_kind"
            }
        }';

        Assert.raises(function() {
            Jda3dLoader.loadFromString(invalidJson);
        });
    }
}
