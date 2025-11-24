package loader;

import haxe.Json;
import sys.io.File;
import loader.Jda3dTypes;

/**
 * Loader for JDA 3D asset files
 *
 * Parses JSON files conforming to JDA 3D specification and converts
 * them into typed Haxe structures.
 */
class Jda3dLoader {

    /**
     * Load JDA 3D document from file
     */
    public static function loadFromFile(path:String):Jda3dDocument {
        var content = File.getContent(path);
        return loadFromString(content);
    }

    /**
     * Load JDA 3D document from JSON string
     */
    public static function loadFromString(jsonString:String):Jda3dDocument {
        var json:Dynamic = Json.parse(jsonString);

        // Validate required fields
        validateRequiredFields(json);

        // Parse document
        return {
            jdaVersion: json.jda_version,
            id: json.id,
            type: json.type,
            paramSchema: parseParamSchema(json.param_schema),
            sdfTree: parseSdfTree(json.sdf_tree),
            materials: parseMaterials(json.materials),
            variants: parseVariants(json.variants),
            attachPoints: parseAttachPoints(json.attach_points),
            depends: json.depends != null ? cast json.depends : []
        };
    }

    /**
     * Validate required fields in JSON
     */
    static function validateRequiredFields(json:Dynamic):Void {
        if (json.jda_version == null) {
            throw "Missing required field: jda_version";
        }
        if (json.id == null) {
            throw "Missing required field: id";
        }
        if (json.type == null) {
            throw "Missing required field: type";
        }
        if (json.sdf_tree == null) {
            throw "Missing required field: sdf_tree";
        }
    }

    /**
     * Parse param_schema section
     */
    static function parseParamSchema(json:Dynamic):Map<String, ParamDefinition> {
        var schema = new Map<String, ParamDefinition>();

        if (json == null) {
            return schema;
        }

        for (field in Reflect.fields(json)) {
            var paramJson:Dynamic = Reflect.field(json, field);
            schema.set(field, {
                type: paramJson.type,
                defaultValue: Reflect.field(paramJson, "default"),
                min: paramJson.min,
                max: paramJson.max
            });
        }

        return schema;
    }

    /**
     * Parse sdf_tree (recursive)
     */
    public static function parseSdfTree(json:Dynamic):SdfNode {
        if (json == null) {
            throw "sdf_tree cannot be null";
        }

        var kind:String = json.kind;

        if (kind == null) {
            throw "sdf_tree node missing 'kind' field";
        }

        return switch(kind) {
            case "primitive":
                parsePrimitive(json);
            case "op":
                parseOperationNode(json);
            case "modifier":
                parseModifier(json);
            case "reference":
                parseReference(json);
            default:
                throw 'Invalid sdf_tree kind: $kind';
        }
    }

    /**
     * Parse primitive node
     */
    static function parsePrimitive(json:Dynamic):SdfNode {
        var dim = parseDimension(json.dim);
        var shape = parseShape(json.shape);
        var params = parseParams(json.params);

        return Primitive(dim, shape, params);
    }

    /**
     * Parse operation node (CSG)
     */
    static function parseOperationNode(json:Dynamic):SdfNode {
        var op = parseCsgOp(json.op);
        var params = parseParams(json);  // k, etc. are at top level
        var children = new Array<SdfNode>();

        if (json.children != null) {
            var childrenJson:Array<Dynamic> = cast json.children;
            for (childJson in childrenJson) {
                children.push(parseSdfTree(childJson));
            }
        }

        return Operation(op, params, children);
    }

    /**
     * Parse modifier node
     */
    static function parseModifier(json:Dynamic):SdfNode {
        var modifier = parseModifierType(json.modifier);
        var params = parseParams(json.params);
        var child = parseSdfTree(json.child);

        return Modifier(modifier, params, child);
    }

    /**
     * Parse reference node
     */
    static function parseReference(json:Dynamic):SdfNode {
        var assetId:String = json.asset_id;
        var params = parseParams(json.params);

        return Reference(assetId, params);
    }

    /**
     * Parse dimension ("2D" or "3D")
     */
    static function parseDimension(dimStr:String):Dimension {
        return switch(dimStr) {
            case "2D": Dim2D;
            case "3D": Dim3D;
            default: throw 'Invalid dimension: $dimStr';
        }
    }

    /**
     * Parse primitive shape
     */
    static function parseShape(shapeStr:String):PrimitiveShape {
        return switch(shapeStr) {
            case "sphere": Sphere;
            case "box": Box;
            case "cylinder": Cylinder;
            case "capsule": Capsule;
            case "torus": Torus;
            case "plane": Plane;
            default: throw 'Unknown primitive shape: $shapeStr';
        }
    }

    /**
     * Parse CSG operation type
     */
    static function parseCsgOp(opStr:String):CsgOperation {
        return switch(opStr) {
            case "union": Union;
            case "subtract": Subtract;
            case "intersect": Intersect;
            case "smooth_union": SmoothUnion;
            case "smooth_subtract": SmoothSubtract;
            case "smooth_intersect": SmoothIntersect;
            default: throw 'Unknown CSG operation: $opStr';
        }
    }

    /**
     * Parse modifier type
     */
    static function parseModifierType(modStr:String):ModifierType {
        return switch(modStr) {
            case "repeat": Repeat;
            case "elongate": Elongate;
            case "twist": Twist;
            case "bend": Bend;
            case "round": Round;
            case "onion": Onion;
            default: throw 'Unknown modifier type: $modStr';
        }
    }

    /**
     * Parse params object (generic key-value map)
     */
    static function parseParams(json:Dynamic):Map<String, Dynamic> {
        var params = new Map<String, Dynamic>();

        if (json == null) {
            return params;
        }

        for (field in Reflect.fields(json)) {
            // Skip known structure fields
            if (field == "kind" || field == "dim" || field == "shape" ||
                field == "op" || field == "modifier" || field == "children" ||
                field == "child" || field == "asset_id" || field == "params") {
                continue;
            }

            var value = Reflect.field(json, field);

            // Handle arrays (vec3, etc.)
            if (Std.isOfType(value, Array)) {
                var arr:Array<Dynamic> = cast value;
                // Convert to Float array if numeric
                if (arr.length > 0 && Std.isOfType(arr[0], Float)) {
                    var floatArr = new Array<Float>();
                    for (v in arr) {
                        floatArr.push(cast v);
                    }
                    params.set(field, floatArr);
                } else {
                    params.set(field, arr);
                }
            } else {
                params.set(field, value);
            }
        }

        return params;
    }

    /**
     * Parse materials section
     */
    static function parseMaterials(json:Dynamic):Map<String, Material> {
        var materials = new Map<String, Material>();

        if (json == null) {
            return materials;
        }

        for (field in Reflect.fields(json)) {
            var matJson:Dynamic = Reflect.field(json, field);
            materials.set(field, {
                shadingModel: matJson.shading_model,
                baseColor: cast matJson.base_color,
                roughness: matJson.roughness,
                metallic: matJson.metallic
            });
        }

        return materials;
    }

    /**
     * Parse variants section
     */
    static function parseVariants(json:Dynamic):Map<String, Map<String, Dynamic>> {
        var variants = new Map<String, Map<String, Dynamic>>();

        if (json == null) {
            return variants;
        }

        for (field in Reflect.fields(json)) {
            var variantJson:Dynamic = Reflect.field(json, field);
            var variantParams = new Map<String, Dynamic>();

            for (paramField in Reflect.fields(variantJson)) {
                variantParams.set(paramField, Reflect.field(variantJson, paramField));
            }

            variants.set(field, variantParams);
        }

        return variants;
    }

    /**
     * Parse attach_points section
     */
    static function parseAttachPoints(json:Dynamic):Map<String, AttachPoint> {
        var points = new Map<String, AttachPoint>();

        if (json == null) {
            return points;
        }

        for (field in Reflect.fields(json)) {
            var pointJson:Dynamic = Reflect.field(json, field);
            points.set(field, {
                position: cast pointJson.position,
                orientation: cast pointJson.orientation
            });
        }

        return points;
    }
}
