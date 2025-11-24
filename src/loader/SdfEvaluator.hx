package loader;

import loader.Jda3dTypes;

/**
 * SDF Evaluator - Generates HXSL code from SDF tree
 *
 * Converts parsed JDA SDF tree into executable HXSL shader code.
 * Handles primitives, CSG operations, and domain modifiers.
 */
class SdfEvaluator {

    static var varCounter:Int = 0;

    /**
     * Generate complete HXSL shader class from SDF tree
     */
    public static function generateShaderClass(sdfTree:SdfNode, className:String):String {
        varCounter = 0; // Reset counter

        var sdfFunction = generateSdfFunctionInternal(sdfTree, "sdf");

        return '
class $className extends hxsl.Shader {
    static var SRC = {
        @:import h3d.shader.Base2d;

        @param var cameraPos : Vec3;
        @param var cameraTarget : Vec3;
        @param var cameraUp : Vec3;
        @param var aspectRatio : Float;
        @param var fov : Float;

        $sdfFunction

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
    };

    public function new() {
        super();
        cameraUp = new h3d.Vector(0, -1, 0);  // Inverted Y for correct orientation
        fov = 1.0;
    }
}
';
    }

    /**
     * Generate SDF function from tree
     */
    public static function generateSdfFunction(sdfTree:SdfNode, functionName:String):String {
        varCounter = 0; // Reset counter
        statements = [];
        return generateSdfFunctionInternal(sdfTree, functionName);
    }

    static var statements:Array<String> = [];

    /**
     * Internal function generator
     */
    static function generateSdfFunctionInternal(sdfTree:SdfNode, functionName:String):String {
        var resultExpr = generateSdfExpression(sdfTree, "p");

        var body = "";
        if (statements.length > 0) {
            body = "\n            " + statements.join("\n            ") + "\n            return " + resultExpr + ";";
        } else {
            body = "return " + resultExpr + ";";
        }

        return '
        function $functionName(p: Vec3): Float {
            $body
        }
';
    }

    /**
     * Generate SDF expression (recursive)
     */
    static function generateSdfExpression(node:SdfNode, pVar:String):String {
        return switch(node) {
            case Primitive(dim, shape, params):
                generatePrimitive(shape, params, pVar);

            case Operation(op, params, children):
                generateOperation(op, params, children, pVar);

            case Modifier(modifier, params, child):
                generateModifier(modifier, params, child, pVar);

            case Reference(assetId, params):
                throw "Reference nodes not yet implemented";
        }
    }

    /**
     * Generate primitive SDF code
     */
    static function generatePrimitive(shape:PrimitiveShape, params:Map<String, Dynamic>, pVar:String):String {
        return switch(shape) {
            case Sphere:
                var radius:Float = params.get("radius");
                // Ensure float formatting (1.0 not 1)
                var radiusStr = Std.string(radius);
                if (radiusStr.indexOf(".") < 0) {
                    radiusStr += ".0";
                }
                'length($pVar) - $radiusStr';

            case Box:
                var size:Array<Float> = cast params.get("size");
                var sx = size[0];
                var sy = size[1];
                var sz = size[2];
                var boxSize = 'vec3(${sx/2}, ${sy/2}, ${sz/2})';
                var qVar = 'box_q${varCounter++}';

                // Add statements
                statements.push('var $qVar = abs($pVar) - $boxSize;');

                // Return expression
                'length(max($qVar, vec3(0.0))) + min(max($qVar.x, max($qVar.y, $qVar.z)), 0.0)';

            case Cylinder:
                var radius:Float = params.get("radius");
                var height:Float = params.get("height");
                var h2 = height / 2;
                var dVar = 'cyl_d${varCounter++}';

                // Add statement
                statements.push('var $dVar = abs(vec2(length($pVar.xz), $pVar.y)) - vec2($radius, $h2);');

                // Return expression
                'min(max($dVar.x, $dVar.y), 0.0) + length(max($dVar, vec2(0.0)))';

            case Capsule:
                var radius:Float = params.get("radius");
                var height:Float = params.get("height");
                var h2 = height / 2;
                var pyVar = 'cap_py${varCounter++}';

                // Add statements
                statements.push('var $pyVar = $pVar.y;');
                statements.push('$pyVar = $pyVar - clamp($pyVar, -$h2, $h2);');

                // Return expression
                'length(vec3($pVar.x, $pyVar, $pVar.z)) - $radius';

            case Torus:
                var majorRadius:Float = params.exists("major_radius") ? params.get("major_radius") : 1.0;
                var minorRadius:Float = params.exists("minor_radius") ? params.get("minor_radius") : 0.25;
                var qVar = 'tor_q${varCounter++}';

                // Add statement
                statements.push('var $qVar = vec2(length($pVar.xz) - $majorRadius, $pVar.y);');

                // Return expression
                'length($qVar) - $minorRadius';

            case Plane:
                var ny:Float = params.exists("ny") ? params.get("ny") : 1.0;
                var h:Float = params.exists("h") ? params.get("h") : 0.0;
                '$pVar.y - $h';
        }
    }

    /**
     * Generate CSG operation code
     */
    static function generateOperation(op:CsgOperation, params:Map<String, Dynamic>, children:Array<SdfNode>, pVar:String):String {
        if (children.length == 0) {
            return "1000.0"; // No children = far away
        }

        // Generate expressions for all children
        var childExprs = new Array<String>();
        for (child in children) {
            childExprs.push(generateSdfExpression(child, pVar));
        }

        return switch(op) {
            case Union:
                // min(a, b)
                var result = childExprs[0];
                for (i in 1...childExprs.length) {
                    result = 'min($result, ${childExprs[i]})';
                }
                result;

            case Subtract:
                // max(a, -b)
                if (childExprs.length < 2) {
                    childExprs[0];
                } else {
                    var result = childExprs[0];
                    for (i in 1...childExprs.length) {
                        result = 'max($result, -(${childExprs[i]}))';
                    }
                    result;
                }

            case Intersect:
                // max(a, b)
                var result = childExprs[0];
                for (i in 1...childExprs.length) {
                    result = 'max($result, ${childExprs[i]})';
                }
                result;

            case SmoothUnion:
                var k:Float = params.get("k");
                if (childExprs.length < 2) {
                    childExprs[0];
                } else {
                    // Smooth min formula: https://iquilezles.org/articles/smin/
                    var aExpr = childExprs[0];
                    var bExpr = childExprs[1];

                    // Generate unique variable names
                    var aVar = 'smu_a${varCounter}';
                    var bVar = 'smu_b${varCounter}';
                    var hVar = 'smu_h${varCounter}';
                    varCounter++;

                    // Add statements
                    statements.push('var $aVar = $aExpr;');
                    statements.push('var $bVar = $bExpr;');
                    statements.push('var $hVar = clamp(0.5 + 0.5 * ($bVar - $aVar) / $k, 0.0, 1.0);');

                    // Return expression
                    'mix($bVar, $aVar, $hVar) - $k * $hVar * (1.0 - $hVar)';
                }

            case SmoothSubtract:
                var k:Float = params.get("k");
                if (childExprs.length < 2) {
                    childExprs[0];
                } else {
                    var aExpr = childExprs[0];
                    var bExpr = childExprs[1];

                    // Generate unique variable names
                    var aVar = 'sms_a${varCounter}';
                    var bVar = 'sms_b${varCounter}';
                    var hVar = 'sms_h${varCounter}';
                    varCounter++;

                    // Add statements
                    statements.push('var $aVar = $aExpr;');
                    statements.push('var $bVar = -($bExpr);');
                    statements.push('var $hVar = clamp(0.5 - 0.5 * ($bVar + $aVar) / $k, 0.0, 1.0);');

                    // Return expression
                    'mix($bVar, $aVar, $hVar) + $k * $hVar * (1.0 - $hVar)';
                }

            case SmoothIntersect:
                var k:Float = params.get("k");
                if (childExprs.length < 2) {
                    childExprs[0];
                } else {
                    var aExpr = childExprs[0];
                    var bExpr = childExprs[1];

                    // Generate unique variable names
                    var aVar = 'smi_a${varCounter}';
                    var bVar = 'smi_b${varCounter}';
                    var hVar = 'smi_h${varCounter}';
                    varCounter++;

                    // Add statements
                    statements.push('var $aVar = $aExpr;');
                    statements.push('var $bVar = $bExpr;');
                    statements.push('var $hVar = clamp(0.5 - 0.5 * ($bVar - $aVar) / $k, 0.0, 1.0);');

                    // Return expression
                    'mix($bVar, $aVar, $hVar) + $k * $hVar * (1.0 - $hVar)';
                }
        }
    }

    /**
     * Generate modifier code
     */
    static function generateModifier(modifier:ModifierType, params:Map<String, Dynamic>, child:SdfNode, pVar:String):String {
        return switch(modifier) {
            case Repeat:
                var cellSize:Array<Float> = cast params.get("cell_size");
                var cx = cellSize[0];
                var cy = cellSize[1];
                var cz = cellSize[2];
                var modP = 'rep_p${varCounter++}';

                // Add statements for domain repetition
                statements.push('var $modP = $pVar;');
                if (cx > 0.0) statements.push('$modP.x = mod($modP.x + ${cx*0.5}, $cx) - ${cx*0.5};');
                if (cy > 0.0) statements.push('$modP.y = mod($modP.y + ${cy*0.5}, $cy) - ${cy*0.5};');
                if (cz > 0.0) statements.push('$modP.z = mod($modP.z + ${cz*0.5}, $cz) - ${cz*0.5};');

                // Return expression with modified position
                generateSdfExpression(child, modP);

            case Elongate:
                var elongation:Array<Float> = cast params.get("elongation");
                var ex = elongation[0];
                var ey = elongation[1];
                var ez = elongation[2];
                var modP = 'elo_p${varCounter++}';

                // Add statement
                statements.push('var $modP = $pVar - clamp($pVar, vec3(-$ex, -$ey, -$ez), vec3($ex, $ey, $ez));');

                // Return expression with modified position
                generateSdfExpression(child, modP);

            case Twist:
                var k:Float = params.get("k");
                var cVar = 'twi_c${varCounter}';
                var sVar = 'twi_s${varCounter}';
                var modP = 'twi_p${varCounter}';
                varCounter++;

                // Add statements
                statements.push('var $cVar = cos($k * $pVar.y);');
                statements.push('var $sVar = sin($k * $pVar.y);');
                statements.push('var $modP = vec3($cVar * $pVar.x - $sVar * $pVar.z, $pVar.y, $sVar * $pVar.x + $cVar * $pVar.z);');

                // Return expression with modified position
                generateSdfExpression(child, modP);

            case Bend:
                var k:Float = params.get("k");
                var cVar = 'ben_c${varCounter}';
                var sVar = 'ben_s${varCounter}';
                var modP = 'ben_p${varCounter}';
                varCounter++;

                // Add statements
                statements.push('var $cVar = cos($k * $pVar.x);');
                statements.push('var $sVar = sin($k * $pVar.x);');
                statements.push('var $modP = vec3($pVar.x, $cVar * $pVar.y - $sVar * $pVar.z, $sVar * $pVar.y + $cVar * $pVar.z);');

                // Return expression with modified position
                generateSdfExpression(child, modP);

            case Round:
                var radius:Float = params.get("radius");
                '(${generateSdfExpression(child, pVar)} - $radius)';

            case Onion:
                var thickness:Float = params.get("thickness");
                'abs(${generateSdfExpression(child, pVar)}) - $thickness';
        }
    }
}
