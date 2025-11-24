package;

class TestShader extends hxsl.Shader {
    static var SRC = {
        @:import h3d.shader.Base2d;

        function fragment() {
            // Simple test - output UV as color
            pixelColor = vec4(calculatedUV.x, calculatedUV.y, 0.5, 1.0);
        }
    };

    public function new() {
        super();
    }
}
