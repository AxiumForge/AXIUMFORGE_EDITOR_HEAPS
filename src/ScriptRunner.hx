package;

import hxd.System;
using StringTools;

/**
 * Script runner for automated UI testing
 * Frame-based execution: Commands execute across frames, not blocking
 */
class ScriptRunner {
    var app:Main;
    var screenshotIndex:Int = 0;
    var outputDir:String;

    // Command queue for frame-based execution
    var commandQueue:Array<String> = [];
    var currentCommandIndex:Int = 0;
    var waitFramesRemaining:Int = 0;
    var isRunning:Bool = false;

    public function new(app:Main, outputDir:String = "sc/script") {
        this.app = app;
        this.outputDir = outputDir;

        // Create output directory
        if (!sys.FileSystem.exists(outputDir)) {
            sys.FileSystem.createDirectory(outputDir);
        }
    }

    /**
     * Update - called each frame to process commands
     */
    public function update(dt:Float) {
        if (!isRunning) return;

        // If waiting, decrement wait counter
        if (waitFramesRemaining > 0) {
            waitFramesRemaining--;
            return;
        }

        // Execute next command
        if (currentCommandIndex < commandQueue.length) {
            var cmd = commandQueue[currentCommandIndex];
            currentCommandIndex++;

            executeCommand(cmd);
        } else {
            // Script finished
            trace('ScriptRunner: Script execution complete');
            isRunning = false;
        }
    }

    /**
     * Execute a single command
     */
    public function executeCommand(cmd:String):Bool {
        var parts = cmd.trim().split(" ");
        if (parts.length == 0 || parts[0] == "") return true;

        var command = parts[0].toLowerCase();

        trace('ScriptRunner: Executing command: $cmd');

        switch(command) {
            case "load_asset":
                if (parts.length < 2) {
                    trace('ScriptRunner ERROR: load_asset requires path argument');
                    return false;
                }
                var assetPath = parts[1];
                trace('ScriptRunner: Loading asset: $assetPath');
                // Call Main's switchShader with the asset path
                @:privateAccess app.switchShader(assetPath);
                return true;

            case "screenshot":
                var filename = parts.length > 1 ? parts[1] : null;
                if (filename == null) {
                    screenshotIndex++;
                    filename = '$outputDir/${StringTools.lpad(Std.string(screenshotIndex), "0", 3)}_screenshot.png';
                } else if (!filename.startsWith("/")) {
                    filename = '$outputDir/$filename';
                }
                trace('ScriptRunner: Taking screenshot: $filename');
                @:privateAccess app.takeScreenshot(filename);
                return true;

            case "wait":
                var milliseconds = parts.length > 1 ? Std.parseInt(parts[1]) : 1000;
                // Convert milliseconds to frames (assuming 60 FPS)
                waitFramesRemaining = Math.ceil(milliseconds / 16.67);
                trace('ScriptRunner: Waiting $milliseconds ms ($waitFramesRemaining frames)');
                return true;

            case "exit":
                trace('ScriptRunner: Exit command received');
                Sys.exit(0);
                return true;

            case "#":
                // Comment line
                return true;

            default:
                trace('ScriptRunner ERROR: Unknown command: $command');
                return false;
        }
    }

    /**
     * Load script from file into command queue
     */
    public function loadScriptFile(scriptPath:String) {
        trace('ScriptRunner: Loading script file: $scriptPath');

        if (!sys.FileSystem.exists(scriptPath)) {
            trace('ScriptRunner ERROR: Script file not found: $scriptPath');
            return;
        }

        var content = sys.io.File.getContent(scriptPath);
        var lines = content.split("\n");

        // Add commands to queue
        for (line in lines) {
            line = line.trim();
            if (line == "" || line.startsWith("#")) continue;
            commandQueue.push(line);
        }

        trace('ScriptRunner: Loaded ${commandQueue.length} commands');
    }

    /**
     * Start executing the loaded script
     */
    public function start() {
        if (commandQueue.length == 0) {
            trace('ScriptRunner ERROR: No commands to execute');
            return;
        }

        trace('ScriptRunner: Starting script execution (${commandQueue.length} commands)');
        isRunning = true;
        currentCommandIndex = 0;
        waitFramesRemaining = 0;
    }

}
