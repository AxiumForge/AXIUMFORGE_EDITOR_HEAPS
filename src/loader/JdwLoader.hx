package loader;

import sys.io.File;
import haxe.Json;
import loader.JdwTypes;
import loader.Jda3dTypes.SdfNode;
import loader.Jda3dLoader;

/**
 * JDW (JSON Description of Worlds) Loader
 *
 * Loads and parses JDW world documents with:
 * - Scene hierarchies (worlds → layers → nodes)
 * - Asset references (JDA)
 * - Cascading defaults (materials, settings)
 * - Transform hierarchies
 */
class JdwLoader {

    /**
     * Load JDW document from file
     */
    public static function loadFromFile(path:String):JdwDocument {
        var content = File.getContent(path);
        return loadFromString(content);
    }

    /**
     * Load JDW document from JSON string
     */
    public static function loadFromString(json:String):JdwDocument {
        var data:Dynamic = Json.parse(json);

        return {
            jdw_version: data.jdw_version,
            id: data.id,
            meta: parseMeta(data.meta),
            units: parseUnits(data.units),
            globals: parseGlobals(data.globals),
            worlds: parseWorlds(data.worlds)
        };
    }

    // ════════════════════════════════════════════════════════════════
    // Metadata Parsing
    // ════════════════════════════════════════════════════════════════

    static function parseMeta(json:Dynamic):JdwMeta {
        return {
            title: json.title,
            author: json.author,
            description: json.description
        };
    }

    static function parseUnits(json:Dynamic):JdwUnits {
        var scales = new Map<String, Float>();
        if (json.reference_scales != null) {
            for (key in Reflect.fields(json.reference_scales)) {
                scales.set(key, Reflect.field(json.reference_scales, key));
            }
        }

        return {
            world_unit: json.world_unit,
            reference_scales: scales
        };
    }

    // ════════════════════════════════════════════════════════════════
    // Globals Parsing
    // ════════════════════════════════════════════════════════════════

    static function parseGlobals(json:Dynamic):JdwGlobals {
        return {
            space: parseSpaceDefinition(json.space),
            raymarch: parseRaymarchSettings(json.raymarch),
            materials: parseMaterials(json.materials),
            assets: parseAssetRegistry(json.assets)
        };
    }

    static function parseSpaceDefinition(json:Dynamic):SpaceDefinition {
        return {
            dim: json.dim,
            up: json.up,
            forward: json.forward,
            right: json.right
        };
    }

    static function parseRaymarchSettings(json:Dynamic):RaymarchSettings {
        return {
            max_steps: json.max_steps,
            hit_epsilon: json.hit_epsilon,
            max_distance: json.max_distance
        };
    }

    static function parseMaterials(json:Dynamic):Map<String, JdwMaterial> {
        var materials = new Map<String, JdwMaterial>();

        if (json == null) return materials;

        for (key in Reflect.fields(json)) {
            var matData:Dynamic = Reflect.field(json, key);
            materials.set(key, parseMaterial(matData));
        }

        return materials;
    }

    static function parseMaterial(json:Dynamic):JdwMaterial {
        var mat:JdwMaterial = {
            shading_model: json.shading_model,
            base_color: parseFloatArray(json.base_color)
        };

        if (json.sdf2d_overlay != null) {
            mat.sdf2d_overlay = json.sdf2d_overlay;
        }

        if (json.uv_mapping != null) {
            mat.uv_mapping = {
                type: json.uv_mapping.type,
                scale: json.uv_mapping.scale
            };
        }

        if (json.roughness != null) mat.roughness = json.roughness;
        if (json.metallic != null) mat.metallic = json.metallic;

        return mat;
    }

    static function parseAssetRegistry(json:Dynamic):AssetRegistry {
        var registry:AssetRegistry = {
            jda: new Map<String, String>()
        };

        if (json.jda != null) {
            for (key in Reflect.fields(json.jda)) {
                registry.jda.set(key, Reflect.field(json.jda, key));
            }
        }

        if (json.sdf2d != null) {
            registry.sdf2d = new Map<String, String>();
            for (key in Reflect.fields(json.sdf2d)) {
                registry.sdf2d.set(key, Reflect.field(json.sdf2d, key));
            }
        }

        return registry;
    }

    // ════════════════════════════════════════════════════════════════
    // World Parsing
    // ════════════════════════════════════════════════════════════════

    static function parseWorlds(json:Array<Dynamic>):Array<JdwWorld> {
        var worlds = new Array<JdwWorld>();

        for (worldData in json) {
            worlds.push(parseWorld(worldData));
        }

        return worlds;
    }

    static function parseWorld(json:Dynamic):JdwWorld {
        return {
            id: json.id,
            name: json.name,
            space: parseSpaceDefinition(json.space),
            bounds: parseWorldBounds(json.bounds),
            layers: parseLayers(json.layers),
            nodes: parseNodes(json.nodes)
        };
    }

    static function parseWorldBounds(json:Dynamic):WorldBounds {
        var bounds:WorldBounds = {
            type: json.type
        };

        if (json.min != null) bounds.min = parseFloatArray(json.min);
        if (json.max != null) bounds.max = parseFloatArray(json.max);
        if (json.center != null) bounds.center = parseFloatArray(json.center);
        if (json.radius != null) bounds.radius = json.radius;

        return bounds;
    }

    // ════════════════════════════════════════════════════════════════
    // Layer Parsing
    // ════════════════════════════════════════════════════════════════

    static function parseLayers(json:Array<Dynamic>):Array<JdwLayer> {
        var layers = new Array<JdwLayer>();

        for (layerData in json) {
            layers.push(parseLayer(layerData));
        }

        return layers;
    }

    static function parseLayer(json:Dynamic):JdwLayer {
        var nodeIds = new Array<String>();
        if (json.nodes != null) {
            for (nodeId in (json.nodes:Array<Dynamic>)) {
                nodeIds.push(nodeId);
            }
        }

        return {
            id: json.id,
            dim: json.dim,
            visible: json.visible,
            render_order: json.render_order,
            nodes: nodeIds
        };
    }

    // ════════════════════════════════════════════════════════════════
    // Node Parsing
    // ════════════════════════════════════════════════════════════════

    static function parseNodes(json:Array<Dynamic>):Array<JdwNode> {
        var nodes = new Array<JdwNode>();

        for (nodeData in json) {
            nodes.push(parseNode(nodeData));
        }

        return nodes;
    }

    static function parseNode(json:Dynamic):JdwNode {
        return {
            id: json.id,
            layer: json.layer,
            transform: parseTransform(json.transform),
            material: json.material,
            source: parseNodeSource(json.source)
        };
    }

    static function parseTransform(json:Dynamic):Transform3D {
        return {
            position: parseFloatArray(json.position),
            rotation_euler: parseFloatArray(json.rotation_euler),
            scale: parseFloatArray(json.scale),
            space: json.space
        };
    }

    static function parseNodeSource(json:Dynamic):NodeSource {
        var sourceType:String = json.type;

        return switch(sourceType) {
            case "inline_sdf":
                var sdfTree = Jda3dLoader.parseSdfTree(json.sdf_tree);
                NodeSource.InlineSdf(sdfTree);

            case "jda":
                var ref:String = json.ref;
                var variant:String = json.variant != null ? json.variant : "default";
                var overrides = new Map<String, Dynamic>();

                if (json.param_overrides != null) {
                    for (key in Reflect.fields(json.param_overrides)) {
                        overrides.set(key, Reflect.field(json.param_overrides, key));
                    }
                }

                NodeSource.JdaReference(ref, variant, overrides);

            default:
                throw 'Unknown node source type: $sourceType';
        };
    }

    // ════════════════════════════════════════════════════════════════
    // Helper Functions
    // ════════════════════════════════════════════════════════════════

    static function parseFloatArray(json:Dynamic):Array<Float> {
        var arr = new Array<Float>();
        for (val in (json:Array<Dynamic>)) {
            arr.push(val);
        }
        return arr;
    }
}
