package tools;

import loader.Jda3dLoader;
import loader.SdfEvaluator;
import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;
using StringTools;

/**
 * JDA to HXSL Shader Compiler (CLI Tool)
 *
 * Compiles JDA 3D asset files to HXSL shader classes.
 *
 * Usage:
 *   haxe --run tools.Jda2Hxsl <input.json> <OutputShaderName> [outputDir]
 *   haxe --run tools.Jda2Hxsl assets/jda3d/jda.shape.sphere_basic.json SphereShader src/generated
 *
 * Batch mode:
 *   haxe --run tools.Jda2Hxsl --batch assets/jda3d/*.json src/generated
 */
class Jda2Hxsl {

    static function main() {
        var args = Sys.args();

        if (args.length == 0) {
            printUsage();
            Sys.exit(1);
        }

        // Check for batch mode
        if (args[0] == "--batch") {
            if (args.length < 3) {
                trace("Error: Batch mode requires input pattern and output directory");
                printUsage();
                Sys.exit(1);
            }

            var inputPattern = args[1];
            var outputDir = args[2];
            runBatchMode(inputPattern, outputDir);
        } else {
            // Single file mode
            if (args.length < 2) {
                trace("Error: Missing required arguments");
                printUsage();
                Sys.exit(1);
            }

            var inputFile = args[0];
            var className = args[1];
            var outputDir = args.length >= 3 ? args[2] : "src/generated";

            compileSingle(inputFile, className, outputDir);
        }
    }

    static function printUsage() {
        trace("JDA to HXSL Shader Compiler");
        trace("");
        trace("Usage:");
        trace("  Single file mode:");
        trace("    haxe --run tools.Jda2Hxsl <input.json> <ShaderClassName> [outputDir]");
        trace("");
        trace("  Batch mode:");
        trace("    haxe --run tools.Jda2Hxsl --batch <inputDir> <outputDir>");
        trace("");
        trace("Examples:");
        trace("  haxe --run tools.Jda2Hxsl assets/jda3d/jda.shape.sphere_basic.json SphereShader src/generated");
        trace("  haxe --run tools.Jda2Hxsl --batch assets/jda3d src/generated");
    }

    static function compileSingle(inputFile:String, className:String, outputDir:String) {
        trace('Compiling: $inputFile -> $className');

        // Check input file exists
        if (!FileSystem.exists(inputFile)) {
            trace('Error: Input file not found: $inputFile');
            Sys.exit(1);
        }

        try {
            // Load JDA document
            var doc = Jda3dLoader.loadFromFile(inputFile);
            trace('  ✓ Loaded JDA document: ${doc.id}');

            // Generate HXSL shader class
            var shaderCode = SdfEvaluator.generateShaderClass(doc.sdfTree, className);
            trace('  ✓ Generated HXSL code');

            // Ensure output directory exists
            if (!FileSystem.exists(outputDir)) {
                FileSystem.createDirectory(outputDir);
                trace('  ✓ Created directory: $outputDir');
            }

            // Write output file
            var outputFile = Path.join([outputDir, '$className.hx']);
            File.saveContent(outputFile, shaderCode);
            trace('  ✓ Saved: $outputFile');

            trace('✅ Success: $inputFile -> $outputFile');

        } catch (e:Dynamic) {
            trace('❌ Error compiling $inputFile: $e');
            Sys.exit(1);
        }
    }

    static function runBatchMode(inputDir:String, outputDir:String) {
        trace('Batch compile mode: $inputDir -> $outputDir');

        // Check input directory exists
        if (!FileSystem.exists(inputDir)) {
            trace('Error: Input directory not found: $inputDir');
            Sys.exit(1);
        }

        // Find all .json files in input directory
        var files = FileSystem.readDirectory(inputDir);
        var jdaFiles = files.filter(f -> f.endsWith('.json'));

        if (jdaFiles.length == 0) {
            trace('Warning: No .json files found in $inputDir');
            Sys.exit(0);
        }

        trace('Found ${jdaFiles.length} JDA files');
        trace('');

        var successCount = 0;
        var failCount = 0;

        // Compile each file
        for (file in jdaFiles) {
            var inputPath = Path.join([inputDir, file]);

            // Generate class name from file name
            // jda.shape.sphere_basic.json -> SphereBasicShader
            var className = generateClassName(file);

            try {
                compileSingle(inputPath, className, outputDir);
                successCount++;
                trace('');
            } catch (e:Dynamic) {
                trace('❌ Failed: $file');
                trace('   Error: $e');
                trace('');
                failCount++;
            }
        }

        // Summary
        trace('════════════════════════════════════════');
        trace('Batch compilation complete');
        trace('  Success: $successCount');
        trace('  Failed:  $failCount');
        trace('  Total:   ${jdaFiles.length}');
        trace('════════════════════════════════════════');

        if (failCount > 0) {
            Sys.exit(1);
        }
    }

    /**
     * Generate class name from JDA file name
     * Examples:
     *   jda.shape.sphere_basic.json -> SphereBasicShader
     *   jda.shape.rounded_box.json -> RoundedBoxShader
     */
    static function generateClassName(filename:String):String {
        // Remove .json extension
        var name = filename.substr(0, filename.length - 5);

        // Split by dots and underscores
        var parts = name.split('.');

        // Take last part (e.g., "sphere_basic" from "jda.shape.sphere_basic")
        var lastPart = parts[parts.length - 1];

        // Split by underscores
        var words = lastPart.split('_');

        // Capitalize each word
        var className = words.map(w -> {
            return w.charAt(0).toUpperCase() + w.substr(1);
        }).join('');

        // Add "Shader" suffix
        return className + 'Shader';
    }
}
