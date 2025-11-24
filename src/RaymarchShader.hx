package;

class RaymarchShader extends hxsl.Shader {
    static var SRC = {
        @:import h3d.shader.Base2d;

        @param var cameraPos : Vec3;
        @param var cameraTarget : Vec3;
        @param var cameraUp : Vec3;
        @param var aspectRatio : Float;
        @param var fov : Float;

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

            // Raymarch with SDF - all inlined
            var t = 0.0;
            var hit = false;

            for (i in 0...64) {
                var p = ro + rd * t;

                // SDF box inline (easier to see rotation than sphere)
                var boxSize = vec3(0.8, 0.8, 0.8);
                var q = abs(p) - boxSize;
                var dist = length(max(q, vec3(0.0))) + min(max(q.x, max(q.y, q.z)), 0.0);

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
                // Calculate normal inline
                var hitPos = ro + rd * t;
                var eps = 0.001;

                // Calculate normal for box using central difference
                var boxSize = vec3(0.8, 0.8, 0.8);

                var px = hitPos + vec3(eps, 0.0, 0.0);
                var qx = abs(px) - boxSize;
                var dx = length(max(qx, vec3(0.0))) + min(max(qx.x, max(qx.y, qx.z)), 0.0);

                var nx = hitPos - vec3(eps, 0.0, 0.0);
                var qnx = abs(nx) - boxSize;
                var dnx = length(max(qnx, vec3(0.0))) + min(max(qnx.x, max(qnx.y, qnx.z)), 0.0);

                var py = hitPos + vec3(0.0, eps, 0.0);
                var qy = abs(py) - boxSize;
                var dy = length(max(qy, vec3(0.0))) + min(max(qy.x, max(qy.y, qy.z)), 0.0);

                var ny = hitPos - vec3(0.0, eps, 0.0);
                var qny = abs(ny) - boxSize;
                var dny = length(max(qny, vec3(0.0))) + min(max(qny.x, max(qny.y, qny.z)), 0.0);

                var pz = hitPos + vec3(0.0, 0.0, eps);
                var qz = abs(pz) - boxSize;
                var dz = length(max(qz, vec3(0.0))) + min(max(qz.x, max(qz.y, qz.z)), 0.0);

                var nz = hitPos - vec3(0.0, 0.0, eps);
                var qnz = abs(nz) - boxSize;
                var dnz = length(max(qnz, vec3(0.0))) + min(max(qnz.x, max(qnz.y, qnz.z)), 0.0);

                var normal = normalize(vec3(dx - dnx, dy - dny, dz - dnz));

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
