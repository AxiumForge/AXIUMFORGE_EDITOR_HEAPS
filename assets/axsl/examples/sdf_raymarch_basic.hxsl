// Generated-style HXSL matching `sdf_raymarch_basic.axsl` (handwritten placeholder until parser/emitter exists).
class SdfRaymarchBasic extends hxsl.Shader {
  static var SRC = {
    @input var input: { var uv: Vec2; }

    @param var uCamera: Mat4;     // not used in this simple demo; reserved for real camera rays
    @param var uLightDir: Vec3;

    function sdSphere(p: Vec3, r: Float): Float {
      return length(p) - r;
    }

    function sdBox(p: Vec3, b: Vec3): Float {
      var d = abs(p) - b;
      return min(max(d.x, max(d.y, d.z)), 0.0) + length(max(d, 0.0));
    }

    function map(p: Vec3): Float {
      var sphere = sdSphere(p, 1.0);
      var cut = sdBox(p - vec3(0.0, -0.6, 0.0), vec3(1.2, 0.2, 1.2));
      return max(sphere, -cut);
    }

    function fragment() {
      var uv = input.uv;
      var ro = vec3(0.0, 0.0, -5.0);
      var rd = normalize(vec3(uv, 1.4));

      var t = 0.0;
      var hit = false;
      var p = vec3(0.0, 0.0, 0.0);

      for (i in 0...96) {
        p = ro + rd * t;
        var d = map(p);
        if (d < 0.001) {
          hit = true;
          break;
        }
        t += d;
        if (t > 40.0) break;
      }

      if (!hit) {
        output.color = vec4(0.02, 0.03, 0.05, 1.0);
        return;
      }

      var e = 0.001;
      var n = normalize(vec3(
        map(p + vec3(e, 0.0, 0.0)) - map(p - vec3(e, 0.0, 0.0)),
        map(p + vec3(0.0, e, 0.0)) - map(p - vec3(0.0, e, 0.0)),
        map(p + vec3(0.0, 0.0, e)) - map(p - vec3(0.0, 0.0, e))
      ));

      var l = normalize(uLightDir);
      var diff = max(dot(n, l), 0.0);
      var col = vec3(0.8, 0.6, 0.9) * diff + vec3(0.05, 0.06, 0.08);
      output.color = vec4(col, 1.0);
    }
  };
}
