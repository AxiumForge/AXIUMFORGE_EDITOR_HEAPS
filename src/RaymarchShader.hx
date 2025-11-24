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

                // SDF sphere inline
                var dist = length(p) - 1.0;

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

                var px = hitPos + vec3(eps, 0.0, 0.0);
                var nx = hitPos - vec3(eps, 0.0, 0.0);
                var py = hitPos + vec3(0.0, eps, 0.0);
                var ny = hitPos - vec3(0.0, eps, 0.0);
                var pz = hitPos + vec3(0.0, 0.0, eps);
                var nz = hitPos - vec3(0.0, 0.0, eps);

                var dx = (length(px) - 1.0) - (length(nx) - 1.0);
                var dy = (length(py) - 1.0) - (length(ny) - 1.0);
                var dz = (length(pz) - 1.0) - (length(nz) - 1.0);

                var normal = normalize(vec3(dx, dy, dz));

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
