
class GeneratedShader extends hxsl.Shader {
    static var SRC = {
        @:import h3d.shader.Base2d;

        @param var cameraPos : Vec3;
        @param var cameraTarget : Vec3;
        @param var cameraUp : Vec3;
        @param var aspectRatio : Float;
        @param var fov : Float;

        
        function sdf(p: Vec3): Float {
            return (function() {
                        var a = (function() {
                    var q = abs(p) - vec3(0.6, 0.6, 0.6);
                    return length(max(q, vec3(0.0))) + min(max(q.x, max(q.y, q.z)), 0.0);
                })();
                        var b = length(p) - 1.0;
                        var h = clamp(0.5 + 0.5 * (b - a) / 0.18, 0.0, 1.0);
                        return mix(b, a, h) - 0.18 * h * (1.0 - h);
                    })();
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
    };

    public function new() {
        super();
        cameraUp = new h3d.Vector(0, 1, 0);
        fov = 1.0;
    }
}
