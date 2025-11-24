class Main extends hxd.App {
    var raymarchShader:RaymarchShader;
    var bitmap:h2d.Bitmap;

    override function init() {
        // Create raymarch shader
        raymarchShader = new RaymarchShader();

        // Create fullscreen bitmap with our shader
        bitmap = new h2d.Bitmap(h2d.Tile.fromColor(0x000000, engine.width, engine.height), s2d);
        bitmap.addShader(raymarchShader);

        // Setup camera initial position
        s3d.camera.pos.set(0, 0, 5);
        s3d.camera.target.set(0, 0, 0);

        // Initialize shader camera
        raymarchShader.cameraPos = s3d.camera.pos;
        raymarchShader.cameraTarget = s3d.camera.target;
        raymarchShader.aspectRatio = engine.width / engine.height;
    }

    override function update(dt:Float) {
        // Update shader parameters each frame
        raymarchShader.cameraPos = s3d.camera.pos;
        raymarchShader.cameraTarget = s3d.camera.target;
        raymarchShader.aspectRatio = engine.width / engine.height;
    }

    static function main() {
        new Main();
    }
}
