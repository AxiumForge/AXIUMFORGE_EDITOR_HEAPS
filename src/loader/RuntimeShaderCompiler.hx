package loader;

import hscript.Parser;
import hscript.Macro;
import hxsl.MacroParser;
import hxsl.Checker;
import hxsl.SharedShader;
import hxsl.DynamicShader;
import loader.Jda3dLoader;
import loader.Jda3dTypes;
import loader.SdfEvaluator;

/**
 * Runtime HXSL shader compiler
 *
 * Compiles JDA assets to HXSL shaders at runtime without pre-compilation.
 * Uses hscript + hxsl.DynamicShader for dynamic shader creation.
 */
class RuntimeShaderCompiler {

    /**
     * Compile JDA asset to runtime HXSL shader
     *
     * @param jdaPath Path to JDA asset file
     * @return Dynamic shader ready to use
     */
    public static function compileFromJda(jdaPath:String):DynamicShader {
        trace('RuntimeCompiler: Loading JDA from $jdaPath');

        // 1. Load JDA document
        var doc = Jda3dLoader.loadFromFile(jdaPath);

        // 2. Generate HXSL code string
        var hxslCode = generateHxslShaderCode(doc);

        trace('RuntimeCompiler: Generated HXSL code (${hxslCode.length} chars)');
        trace('RuntimeCompiler: HXSL Code:\n$hxslCode');

        // 3. Compile HXSL to runtime shader
        return compileHxslCode(hxslCode, doc.id);
    }

    /**
     * Generate complete HXSL shader code from JDA document
     */
    static function generateHxslShaderCode(doc:Jda3dDocument):String {
        // Generate SDF function (already includes function signature)
        var sdfFunction = SdfEvaluator.generateSdfFunction(doc.sdfTree, "sdf");

        // Extract material color from JDA document (use mat.default)
        var baseColor = [0.9, 0.6, 0.3];  // Default orange/tan
        if (doc.materials != null && doc.materials.exists("mat.default")) {
            var mat = doc.materials.get("mat.default");
            if (mat.baseColor != null && mat.baseColor.length >= 3) {
                baseColor = [mat.baseColor[0], mat.baseColor[1], mat.baseColor[2]];
            }
        }

        // Build complete HXSL shader
        // NOTE: @:import is NOT supported in dynamic HXSL compilation!
        // Must define input/output variables explicitly
        var code = '
{
    @param var cameraPos : Vec3;
    @param var cameraTarget : Vec3;
    @param var cameraUp : Vec3;
    @param var aspectRatio : Float;
    @param var fov : Float;

    var input : {
        uv : Vec2
    };

    var output : {
        color : Vec4
    };

    ${sdfFunction}

    function fragment() {
        // Calculate ray direction (use input.uv instead of calculatedUV)
        var uv = input.uv * 2.0 - 1.0;
        uv.x *= aspectRatio;

        var forward = normalize(cameraTarget - cameraPos);
        var right = normalize(cross(cameraUp, forward));
        var up = cross(forward, right);

        var fovScale = tan(fov * 0.5);
        var rd = normalize(forward + uv.x * right * fovScale + uv.y * up * fovScale);
        var ro = cameraPos;

        // Raymarch
        var t = 0.0;
        var hit = false;

        for (i in 0...64) {
            var p = ro + rd * t;
            var dist = sdf(p);

            if (dist < 0.001) {
                hit = true;
                break;
            }
            if (t > 50.0) {
                break;
            }
            t += dist;
        }

        if (hit) {
            // Calculate normal
            var hitPos = ro + rd * t;
            var eps = 0.001;
            var normal = normalize(vec3(
                sdf(hitPos + vec3(eps, 0.0, 0.0)) - sdf(hitPos - vec3(eps, 0.0, 0.0)),
                sdf(hitPos + vec3(0.0, eps, 0.0)) - sdf(hitPos - vec3(0.0, eps, 0.0)),
                sdf(hitPos + vec3(0.0, 0.0, eps)) - sdf(hitPos - vec3(0.0, 0.0, eps))
            ));

            // Lighting
            var lightDir = normalize(vec3(0.5, 1.0, 0.3));
            var diff = max(dot(normal, lightDir), 0.0);

            output.color = vec4(vec3(${baseColor[0]}, ${baseColor[1]}, ${baseColor[2]}) * (0.2 + diff * 0.8), 1.0);
        } else {
            // Sky (use input.uv instead of calculatedUV)
            var skyColor = mix(vec3(0.5, 0.7, 1.0), vec3(0.3, 0.5, 0.8), input.uv.y);
            output.color = vec4(skyColor, 1.0);
        }
    }
}
';

        return code;
    }

    /**
     * Compile HXSL code string to DynamicShader
     */
    static function compileHxslCode(hxslCode:String, shaderName:String):DynamicShader {
        try {
            // 1. Parse with hscript
            var parser = new Parser();
            parser.allowMetadata = true;
            parser.allowTypes = true;
            parser.allowJSON = true;

            var expr = parser.parseString(hxslCode);
            var e = new Macro({ file: shaderName, min: 0, max: hxslCode.length }).convert(expr);

            // 2. Parse HXSL AST
            var ast = new MacroParser().parseExpr(e);

            // 3. Type check
            var checker = new Checker();
            var checked = checker.check(shaderName, ast);

            // 4. Create runtime shader
            var shared = new SharedShader("");
            shared.data = checked;
            @:privateAccess shared.initialize();

            var shader = new DynamicShader(shared);

            trace('RuntimeCompiler: Successfully compiled shader "$shaderName"');

            return shader;

        } catch (e:Dynamic) {
            trace('RuntimeCompiler ERROR: Failed to compile shader');
            trace('Error details: $e');
            trace('Error type: ${Type.typeof(e)}');

            // Try to extract more info from hscript error
            try {
                var errObj:Dynamic = e;
                if (Reflect.hasField(errObj, "e")) trace('  e.e: ${errObj.e}');
                if (Reflect.hasField(errObj, "pmin")) trace('  e.pmin: ${errObj.pmin}');
                if (Reflect.hasField(errObj, "pmax")) trace('  e.pmax: ${errObj.pmax}');
            } catch (_:Dynamic) {}

            throw e;
        }
    }
}
