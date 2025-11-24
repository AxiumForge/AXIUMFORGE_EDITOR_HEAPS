package loader;

/**
 * Type definitions for JDA 3D documents
 *
 * Mirrors the JDA 3D JSON structure defined in:
 * docs/jdw_sdf_csg_world_standard_v_0.md
 */

/**
 * Complete JDA 3D document structure
 */
typedef Jda3dDocument = {
    var jdaVersion:String;       // "jda_version" in JSON
    var id:String;
    var type:String;             // "sdf3d", "sdf2d", etc.
    var paramSchema:Map<String, ParamDefinition>;  // "param_schema" in JSON
    var sdfTree:SdfNode;         // "sdf_tree" in JSON
    var materials:Map<String, Material>;
    var variants:Map<String, Map<String, Dynamic>>;  // variant_name -> param overrides
    var attachPoints:Map<String, AttachPoint>;  // "attach_points" in JSON
    var depends:Array<String>;
}

/**
 * Parameter definition in param_schema
 */
typedef ParamDefinition = {
    var type:String;             // "float", "vec2", "vec3", "vec4", "bool"
    var defaultValue:Dynamic;    // "default" in JSON
    var ?min:Float;              // Optional min value
    var ?max:Float;              // Optional max value
}

/**
 * SDF tree node (recursive structure)
 *
 * Can be:
 * - Primitive: Basic SDF shape (sphere, box, etc.)
 * - Operation: CSG operation on children (union, subtract, intersect)
 * - Modifier: Domain manipulation (repeat, twist, elongate)
 * - Reference: Reference to another JDA asset
 */
enum SdfNode {
    Primitive(dim:Dimension, shape:PrimitiveShape, params:Map<String, Dynamic>);
    Operation(op:CsgOperation, params:Map<String, Dynamic>, children:Array<SdfNode>);
    Modifier(modifier:ModifierType, params:Map<String, Dynamic>, child:SdfNode);
    Reference(assetId:String, params:Map<String, Dynamic>);
}

/**
 * Dimension of SDF primitive
 */
enum Dimension {
    Dim2D;
    Dim3D;
}

/**
 * Primitive SDF shapes
 */
enum PrimitiveShape {
    Sphere;
    Box;
    Cylinder;
    Capsule;
    Torus;
    Plane;
    // Add more as needed
}

/**
 * CSG operations
 */
enum CsgOperation {
    Union;
    Subtract;
    Intersect;
    SmoothUnion;
    SmoothSubtract;
    SmoothIntersect;
}

/**
 * Domain modifiers
 */
enum ModifierType {
    Repeat;
    Elongate;
    Twist;
    Bend;
    Round;
    Onion;
}

/**
 * Material definition
 */
typedef Material = {
    var shadingModel:String;     // "pbr", "lambert", "unlit"
    var baseColor:Array<Float>;  // RGBA [0-1]
    var roughness:Float;
    var metallic:Float;
}

/**
 * Attachment point for composition
 */
typedef AttachPoint = {
    var position:Array<Float>;   // [x, y, z]
    var orientation:Array<Float>; // [rx, ry, rz] in degrees
}
