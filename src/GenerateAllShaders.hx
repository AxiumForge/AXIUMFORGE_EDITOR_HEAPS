import loader.Jda3dLoader;
import loader.SdfEvaluator;
import sys.io.File;

class GenerateAllShaders {
    static function main() {
        var assets = [
            {name: "SphereShader", path: "assets/jda3d/jda.shape.sphere_basic.json"},
            {name: "RoundedBoxShader", path: "assets/jda3d/jda.shape.rounded_box.json"},
            {name: "PillarRepeatShader", path: "assets/jda3d/jda.shape.pillar_repeat.json"}
        ];

        for (asset in assets) {
            Sys.println('Generating ${asset.name}...');
            try {
                var doc = Jda3dLoader.loadFromFile(asset.path);
                var code = SdfEvaluator.generateShaderClass(doc.sdfTree, asset.name);
                File.saveContent('src/${asset.name}.hx', code);
                Sys.println('  ✓ Saved to src/${asset.name}.hx');
            } catch(e:Dynamic) {
                Sys.println('  ✗ Error: $e');
            }
        }
        
        Sys.println('Done! All shaders generated.');
    }
}
