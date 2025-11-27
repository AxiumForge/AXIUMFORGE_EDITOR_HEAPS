package loader;

import hscript.Parser;
import hscript.Macro;
import hxsl.MacroParser;
import hxsl.Checker;
import hxsl.SharedShader;
import hxsl.DynamicShader;
import loader.Jda3dLoader;
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

        // 3. Compile HXSL to runtime shader
        return compileHxslCode(hxslCode, doc.id);
    }

    /**
     * Generate complete HXSL shader code from JDA document
     */
    static function generateHxslShaderCode(doc:Jda3dDocument):String {
        // Generate SDF function body
        var sdfFunction = SdfEvaluator.generateHxslCode(doc.sdfTree);

        // Build complete HXSL shader
        var code = '
{
    @:import h3d.shader.Base2d;

    @param var cameraPos : Vec3;
    @param var cameraTarget : Vec3;
    @param var cameraUp : Vec3;
    @param var aspectRatio : Float;
    @param var fov : Float;

    function sdf(p: Vec3): Float {
        ${sdfFunction}
    }

    function fragment() {
        // Calculate ray direction
        var uv = calculatedUV * 2.0 - 1.0;
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

            pixelColor = vec4(vec3(0.9, 0.6, 0.3) * (0.2 + diff * 0.8), 1.0);
        } else {
            // Sky
            var skyColor = mix(vec3(0.5, 0.7, 1.0), vec3(0.3, 0.5, 0.8), calculatedUV.y);
            pixelColor = vec4(skyColor, 1.0);
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
            trace('Error: $e');
            throw e;
        }
    }
}
