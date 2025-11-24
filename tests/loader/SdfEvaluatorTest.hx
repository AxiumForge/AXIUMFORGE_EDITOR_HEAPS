package loader;

import utest.Test;
import utest.Assert;
import loader.SdfEvaluator;
import loader.Jda3dTypes;

/**
 * Tests for SDF Evaluator (HXSL code generation)
 *
 * TDD workflow: Write tests first, then implement code generator
 */
class SdfEvaluatorTest extends Test {

    /**
     * Test sphere primitive generates correct HXSL code
     */
    public function testSpherePrimitive() {
        var params = new Map<String, Dynamic>();
        params.set("radius", 1.0);

        var node = Primitive(Dim3D, Sphere, params);
        var code = SdfEvaluator.generateSdfFunction(node, "testSdf");

        // Should generate: length(p) - radius
        Assert.isTrue(code.indexOf("length(p)") >= 0);
        Assert.isTrue(code.indexOf("1.0") >= 0 || code.indexOf("radius") >= 0);
    }

    /**
     * Test box primitive generates correct HXSL code
     */
    public function testBoxPrimitive() {
        var params = new Map<String, Dynamic>();
        params.set("size", [0.8, 0.8, 0.8]);

        var node = Primitive(Dim3D, Box, params);
        var code = SdfEvaluator.generateSdfFunction(node, "testSdf");

        // Should generate box SDF formula
        Assert.isTrue(code.indexOf("abs(p)") >= 0);
        Assert.isTrue(code.indexOf("vec3") >= 0);
    }

    /**
     * Test CSG union operation
     */
    public function testCsgUnion() {
        var params1 = new Map<String, Dynamic>();
        params1.set("radius", 1.0);
        var sphere = Primitive(Dim3D, Sphere, params1);

        var params2 = new Map<String, Dynamic>();
        params2.set("size", [0.8, 0.8, 0.8]);
        var box = Primitive(Dim3D, Box, params2);

        var opParams = new Map<String, Dynamic>();
        var union = Operation(Union, opParams, [sphere, box]);

        var code = SdfEvaluator.generateSdfFunction(union, "testSdf");

        // Should use min() for union
        Assert.isTrue(code.indexOf("min(") >= 0);
    }

    /**
     * Test CSG subtract operation
     */
    public function testCsgSubtract() {
        var params1 = new Map<String, Dynamic>();
        params1.set("radius", 1.0);
        var sphere = Primitive(Dim3D, Sphere, params1);

        var params2 = new Map<String, Dynamic>();
        params2.set("size", [0.5, 0.5, 0.5]);
        var box = Primitive(Dim3D, Box, params2);

        var opParams = new Map<String, Dynamic>();
        var subtract = Operation(Subtract, opParams, [sphere, box]);

        var code = SdfEvaluator.generateSdfFunction(subtract, "testSdf");

        // Should use max(a, -b) for subtraction
        Assert.isTrue(code.indexOf("max(") >= 0);
    }

    /**
     * Test CSG smooth union operation
     */
    public function testCsgSmoothUnion() {
        var params1 = new Map<String, Dynamic>();
        params1.set("radius", 1.0);
        var sphere = Primitive(Dim3D, Sphere, params1);

        var params2 = new Map<String, Dynamic>();
        params2.set("size", [0.8, 0.8, 0.8]);
        var box = Primitive(Dim3D, Box, params2);

        var opParams = new Map<String, Dynamic>();
        opParams.set("k", 0.18);
        var smoothUnion = Operation(SmoothUnion, opParams, [sphere, box]);

        var code = SdfEvaluator.generateSdfFunction(smoothUnion, "testSdf");

        // Should use smoothmin formula
        Assert.isTrue(code.indexOf("0.18") >= 0); // k parameter
    }

    /**
     * Test repeat modifier
     */
    public function testRepeatModifier() {
        var params1 = new Map<String, Dynamic>();
        params1.set("radius", 0.35);
        var sphere = Primitive(Dim3D, Sphere, params1);

        var modParams = new Map<String, Dynamic>();
        modParams.set("cell_size", [4.0, 0.0, 4.0]);
        var repeat = Modifier(Repeat, modParams, sphere);

        var code = SdfEvaluator.generateSdfFunction(repeat, "testSdf");

        // Debug: print generated code
        trace("Generated repeat code: " + code);

        // Should modify p before passing to child
        Assert.isTrue(code.indexOf("mod(") >= 0 || code.indexOf("fract(") >= 0 || code.indexOf("modP") >= 0);
        Assert.isTrue(code.indexOf("4") >= 0); // cell_size (may be 4 or 4.0)
    }

    /**
     * Test complete HXSL shader generation from JDA document
     */
    public function testCompleteShaderGeneration() {
        var params = new Map<String, Dynamic>();
        params.set("radius", 1.0);
        var node = Primitive(Dim3D, Sphere, params);

        var shader = SdfEvaluator.generateShaderClass(node, "TestShader");

        // Should be valid HXSL class structure
        Assert.isTrue(shader.indexOf("class TestShader") >= 0);
        Assert.isTrue(shader.indexOf("extends hxsl.Shader") >= 0);
        Assert.isTrue(shader.indexOf("static var SRC") >= 0);
        Assert.isTrue(shader.indexOf("function fragment()") >= 0);
    }

    /**
     * Test generated code compiles (syntax check)
     */
    public function testGeneratedCodeSyntax() {
        var params = new Map<String, Dynamic>();
        params.set("radius", 1.0);
        var node = Primitive(Dim3D, Sphere, params);

        var code = SdfEvaluator.generateSdfFunction(node, "testSdf");

        // Should be valid HXSL function syntax
        Assert.isTrue(code.indexOf("function ") >= 0);
        Assert.isTrue(code.indexOf("Float ") >= 0);
        Assert.isTrue(code.indexOf("return ") >= 0);
        Assert.isTrue(code.indexOf(";") >= 0);
    }
}
