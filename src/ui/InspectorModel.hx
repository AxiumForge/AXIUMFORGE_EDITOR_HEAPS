package ui;

import loader.Jda3dTypes;
import loader.Jda3dTypes.Material;

/**
 * Data model for Inspector UI panel
 *
 * Extracts and formats JDA document data for display.
 */

// Parameter information for display
typedef ParamInfo = {
    name: String,
    type: String,
    defaultValue: Dynamic,  // Can be Float or String (for display)
    hasMin: Bool,
    min: Float,
    hasMax: Bool,
    max: Float
}

// Color information
typedef ColorInfo = {
    r: Float,
    g: Float,
    b: Float
}

// Material information for display
typedef MaterialInfo = {
    name: String,
    shadingModel: String,
    baseColor: ColorInfo,
    roughness: Float,
    metallic: Float
}

// Variant information for display
typedef VariantParamInfo = {
    name: String,
    value: Dynamic  // Can be Float or String (for display)
}

typedef VariantInfo = {
    name: String,
    params: Array<VariantParamInfo>
}

// Attach point information for display
typedef AttachPointInfo = {
    name: String,
    position: {x: Float, y: Float, z: Float}
}

// Complete inspector data
typedef InspectorData = {
    id: String,
    type: String,
    jdaVersion: String,
    parameters: Array<ParamInfo>,
    materials: Array<MaterialInfo>,
    variants: Array<VariantInfo>,
    attachPoints: Array<AttachPointInfo>
}

/**
 * InspectorModel - Extract and format JDA data for UI display
 */
class InspectorModel {

    /**
     * Create InspectorData from a JDA 3D document
     */
    public static function fromJdaDocument(doc: Jda3dDocument): InspectorData {
        return {
            id: doc.id,
            type: doc.type,
            jdaVersion: doc.jdaVersion,
            parameters: extractParameters(doc),
            materials: extractMaterials(doc),
            variants: extractVariants(doc),
            attachPoints: extractAttachPoints(doc)
        };
    }

    /**
     * Extract parameter information from param_schema
     */
    static function extractParameters(doc: Jda3dDocument): Array<ParamInfo> {
        var params: Array<ParamInfo> = [];

        if (doc.paramSchema == null) {
            return params;
        }

        for (paramName in doc.paramSchema.keys()) {
            var paramDef = doc.paramSchema.get(paramName);

            // Keep default value as-is (Float or Array<Float>)
            // UI can convert to string for display if needed
            params.push({
                name: paramName,
                type: paramDef.type,
                defaultValue: paramDef.defaultValue,
                hasMin: paramDef.min != null,
                min: paramDef.min != null ? paramDef.min : 0.0,
                hasMax: paramDef.max != null,
                max: paramDef.max != null ? paramDef.max : 0.0
            });
        }

        return params;
    }

    /**
     * Extract material information
     */
    static function extractMaterials(doc: Jda3dDocument): Array<MaterialInfo> {
        var materials: Array<MaterialInfo> = [];

        if (doc.materials == null) {
            return materials;
        }

        for (materialName in doc.materials.keys()) {
            var material = doc.materials.get(materialName);

            // Convert base color array to ColorInfo
            // Safe array access for HashLink
            var baseColor: ColorInfo = {
                r: material.baseColor.length > 0 ? material.baseColor[0] : 0.0,
                g: material.baseColor.length > 1 ? material.baseColor[1] : 0.0,
                b: material.baseColor.length > 2 ? material.baseColor[2] : 0.0
            };

            materials.push({
                name: materialName,
                shadingModel: material.shadingModel,
                baseColor: baseColor,
                roughness: material.roughness,
                metallic: material.metallic
            });
        }

        return materials;
    }

    /**
     * Extract variant information
     */
    static function extractVariants(doc: Jda3dDocument): Array<VariantInfo> {
        var variants: Array<VariantInfo> = [];

        if (doc.variants == null) {
            return variants;
        }

        for (variantName in doc.variants.keys()) {
            var variantParams = doc.variants.get(variantName);

            var paramInfos: Array<VariantParamInfo> = [];

            if (variantParams != null) {
                for (paramName in variantParams.keys()) {
                    var paramValue: Dynamic = variantParams.get(paramName);

                    // Keep value as-is (Float or Array<Float>)
                    // UI can convert to string for display if needed
                    paramInfos.push({
                        name: paramName,
                        value: paramValue
                    });
                }
            }

            variants.push({
                name: variantName,
                params: paramInfos
            });
        }

        return variants;
    }

    /**
     * Extract attach point information
     */
    static function extractAttachPoints(doc: Jda3dDocument): Array<AttachPointInfo> {
        var attachPoints: Array<AttachPointInfo> = [];

        if (doc.attachPoints == null) {
            return attachPoints;
        }

        for (pointName in doc.attachPoints.keys()) {
            var point = doc.attachPoints.get(pointName);

            attachPoints.push({
                name: pointName,
                position: {
                    x: point.position.length > 0 ? point.position[0] : 0.0,
                    y: point.position.length > 1 ? point.position[1] : 0.0,
                    z: point.position.length > 2 ? point.position[2] : 0.0
                }
            });
        }

        return attachPoints;
    }

    /**
     * Parse hex color string to RGB floats (0.0-1.0)
     * Example: "#FFA500" -> {r: 1.0, g: 0.647, b: 0.0}
     */
    static function parseColor(hex: String): ColorInfo {
        // Remove # if present
        if (hex.charAt(0) == "#") {
            hex = hex.substr(1);
        }

        // Parse hex components
        var r = Std.parseInt("0x" + hex.substr(0, 2));
        var g = Std.parseInt("0x" + hex.substr(2, 2));
        var b = Std.parseInt("0x" + hex.substr(4, 2));

        // Convert to 0.0-1.0 range
        return {
            r: r / 255.0,
            g: g / 255.0,
            b: b / 255.0
        };
    }
}
