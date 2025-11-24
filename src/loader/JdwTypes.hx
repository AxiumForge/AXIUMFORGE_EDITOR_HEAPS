package loader;

import loader.Jda3dTypes.SdfNode;

/**
 * JDW (JSON Description of Worlds) Type Definitions
 *
 * Complete type system for JDW v0.1.0 world documents.
 */

// ════════════════════════════════════════════════════════════════
// Main Document
// ════════════════════════════════════════════════════════════════

typedef JdwDocument = {
    var jdw_version:String;
    var id:String;
    var meta:JdwMeta;
    var units:JdwUnits;
    var globals:JdwGlobals;
    var worlds:Array<JdwWorld>;
}

typedef JdwMeta = {
    var title:String;
    var author:String;
    var description:String;
}

typedef JdwUnits = {
    var world_unit:String;
    var reference_scales:Map<String, Float>;
}

// ════════════════════════════════════════════════════════════════
// Globals
// ════════════════════════════════════════════════════════════════

typedef JdwGlobals = {
    var space:SpaceDefinition;
    var raymarch:RaymarchSettings;
    var materials:Map<String, Material>;
    var assets:AssetRegistry;
}

typedef SpaceDefinition = {
    var dim:String;  // "2D" or "3D"
    var up:String;   // "y+", "z+", etc.
    var forward:String;
    var right:String;
}

typedef RaymarchSettings = {
    var max_steps:Int;
    var hit_epsilon:Float;
    var max_distance:Float;
}

typedef Material = {
    var shading_model:String;  // "lambert", "pbr", etc.
    var base_color:Array<Float>;  // RGBA
    @:optional var sdf2d_overlay:String;
    @:optional var uv_mapping:UvMapping;
    @:optional var roughness:Float;
    @:optional var metallic:Float;
}

typedef UvMapping = {
    var type:String;  // "triplanar", "planar", "spherical", etc.
    @:optional var scale:Float;
}

typedef AssetRegistry = {
    var jda:Map<String, String>;  // asset_id -> file_path
    @:optional var sdf2d:Map<String, String>;
}

// ════════════════════════════════════════════════════════════════
// World Structure
// ════════════════════════════════════════════════════════════════

typedef JdwWorld = {
    var id:String;
    var name:String;
    var space:SpaceDefinition;
    var bounds:WorldBounds;
    var layers:Array<JdwLayer>;
    var nodes:Array<JdwNode>;
}

typedef WorldBounds = {
    var type:String;  // "aabb", "sphere", "infinite"
    @:optional var min:Array<Float>;  // For AABB
    @:optional var max:Array<Float>;
    @:optional var center:Array<Float>;  // For sphere
    @:optional var radius:Float;
}

typedef JdwLayer = {
    var id:String;
    var dim:String;  // "2D" or "3D"
    var visible:Bool;
    var render_order:Int;
    var nodes:Array<String>;  // Node IDs
}

// ════════════════════════════════════════════════════════════════
// Nodes
// ════════════════════════════════════════════════════════════════

typedef JdwNode = {
    var id:String;
    var layer:String;  // Layer ID
    var transform:Transform3D;
    var material:String;  // Material ID
    var source:NodeSource;
}

typedef Transform3D = {
    var position:Array<Float>;  // [x, y, z]
    var rotation_euler:Array<Float>;  // [x, y, z] in degrees
    var scale:Array<Float>;  // [x, y, z]
    var space:String;  // "world" or "local"
}

// ════════════════════════════════════════════════════════════════
// Node Sources
// ════════════════════════════════════════════════════════════════

enum NodeSource {
    InlineSdf(sdfTree:SdfNode);
    JdaReference(ref:String, variant:String, paramOverrides:Map<String, Dynamic>);
}
