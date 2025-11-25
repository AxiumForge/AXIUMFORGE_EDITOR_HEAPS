package ui;

import utest.Test;
import utest.Assert;
import loader.Jda3dLoader;
import ui.InspectorModel;

/**
 * TDD Tests for InspectorModel
 *
 * Tests data extraction and formatting from JDA documents
 * for display in the Inspector UI panel.
 */
class InspectorModelTest extends Test {

    function testExtractMetadataFromSphere() {
        // Load sphere JDA asset
        var doc = Jda3dLoader.loadFromFile("assets/jda3d/jda.shape.sphere_basic.json");

        // Extract metadata via InspectorModel
        var data = InspectorModel.fromJdaDocument(doc);

        // Assert metadata extracted correctly
        Assert.equals("jda.shape.sphere_basic", data.id);
        Assert.equals("shape", data.type);
        Assert.equals("0.1.0", data.jdaVersion);
    }

    function testExtractParameters() {
        // Load sphere JDA asset
        var doc = Jda3dLoader.loadFromFile("assets/jda3d/jda.shape.sphere_basic.json");

        // Extract parameter info
        var data = InspectorModel.fromJdaDocument(doc);

        // Sphere has 1 parameter: radius
        Assert.equals(1, data.parameters.length);

        var radiusParam = data.parameters[0];
        Assert.equals("radius", radiusParam.name);
        Assert.equals("float", radiusParam.type);
        Assert.equals(1.0, radiusParam.defaultValue);
        Assert.isTrue(radiusParam.hasMin);
        Assert.equals(0.0, radiusParam.min);
        Assert.isFalse(radiusParam.hasMax);
    }

    function testExtractMaterialsFromSphere() {
        // Load sphere JDA asset
        var doc = Jda3dLoader.loadFromFile("assets/jda3d/jda.shape.sphere_basic.json");

        // Extract material info
        var data = InspectorModel.fromJdaDocument(doc);

        // Sphere has 1 material: "default"
        Assert.equals(1, data.materials.length);

        var defaultMaterial = data.materials[0];
        Assert.equals("default", defaultMaterial.name);
        Assert.equals("pbr", defaultMaterial.shadingModel);

        // Check base color from JDA file: [0.7, 0.8, 0.95, 1.0]
        Assert.equals(0.7, defaultMaterial.baseColor.r);
        Assert.equals(0.8, defaultMaterial.baseColor.g);
        Assert.equals(0.95, defaultMaterial.baseColor.b);

        Assert.equals(0.2, defaultMaterial.roughness);
        Assert.equals(0.0, defaultMaterial.metallic);
    }

    function testExtractVariants() {
        // Load sphere JDA asset
        var doc = Jda3dLoader.loadFromFile("assets/jda3d/jda.shape.sphere_basic.json");

        // Extract variants
        var data = InspectorModel.fromJdaDocument(doc);

        // Sphere has 3 variants: default, hero, small
        Assert.equals(3, data.variants.length);

        // Check default variant
        var defaultVariant = data.variants[0];
        Assert.equals("default", defaultVariant.name);
        Assert.equals(1, defaultVariant.params.length);
        Assert.equals("radius", defaultVariant.params[0].name);
        Assert.equals(1.0, defaultVariant.params[0].value);
    }

    function testExtractAttachPoints() {
        // Load sphere JDA asset
        var doc = Jda3dLoader.loadFromFile("assets/jda3d/jda.shape.sphere_basic.json");

        // Extract attach points
        var data = InspectorModel.fromJdaDocument(doc);

        // Sphere has 2 attach points: top, center
        Assert.equals(2, data.attachPoints.length);

        // Check top attach point
        var topPoint = data.attachPoints[0];
        Assert.equals("top", topPoint.name);
        Assert.equals(0.0, topPoint.position.x);
        Assert.equals(1.0, topPoint.position.y);
        Assert.equals(0.0, topPoint.position.z);
    }

    function testExtractFromRoundedBox() {
        // Load rounded box JDA asset (has CSG operations)
        var doc = Jda3dLoader.loadFromFile("assets/jda3d/jda.shape.rounded_box.json");

        // Extract data
        var data = InspectorModel.fromJdaDocument(doc);

        // Assert metadata
        Assert.equals("jda.shape.rounded_box", data.id);
        Assert.equals("shape", data.type);

        // Rounded box has multiple parameters (size, radius, smoothness)
        Assert.isTrue(data.parameters.length > 1);
    }

    function testHandleEmptyMaterials() {
        // Load sphere and modify to have empty materials
        var doc = Jda3dLoader.loadFromFile("assets/jda3d/jda.shape.sphere_basic.json");

        // Clear materials for test
        doc.materials = [];

        // Extract data
        var data = InspectorModel.fromJdaDocument(doc);

        // Should handle empty materials gracefully
        Assert.equals(0, data.materials.length);
    }

    function testHandleEmptyVariants() {
        // Load sphere and modify to have no variants
        var doc = Jda3dLoader.loadFromFile("assets/jda3d/jda.shape.sphere_basic.json");

        // Clear variants for test
        doc.variants = [];

        // Extract data
        var data = InspectorModel.fromJdaDocument(doc);

        // Should handle empty variants gracefully
        Assert.equals(0, data.variants.length);
    }
}
