package ui;

import h2d.Object;
import h2d.Graphics;
import h2d.Text;
import h2d.Interactive;
import sys.FileSystem;
using StringTools;

/**
 * Simple file browser popup for selecting JDA/JDW files
 */
class FileBrowser extends Object {

    var onFileSelected:String->Void;
    var currentPath:String;
    var fileListY:Float = 60;

    var background:Graphics;
    var pathText:Text;
    var fileContainer:Object;

    public function new(parent:Object, startPath:String, onSelect:String->Void) {
        super(parent);

        this.onFileSelected = onSelect;
        this.currentPath = startPath;

        buildUI();
        refreshFileList();
    }

    function buildUI() {
        // Semi-transparent full-screen overlay
        var overlay = new Graphics(this);
        overlay.beginFill(0x000000, 0.7);
        overlay.drawRect(0, 0, 1920, 1080);  // Large enough for most screens
        overlay.endFill();

        // Center panel
        background = new Graphics(this);
        background.beginFill(0x2a2a2a, 1.0);
        background.drawRect(300, 100, 800, 600);
        background.endFill();

        // Title
        var title = new Text(hxd.res.DefaultFont.get(), this);
        title.text = "Select Asset File";
        title.textColor = 0xFFFFFF;
        title.x = 320;
        title.y = 120;
        title.scale(1.5);

        // Current path display
        pathText = new Text(hxd.res.DefaultFont.get(), this);
        pathText.textColor = 0xCCCCCC;
        pathText.x = 320;
        pathText.y = 150;
        pathText.maxWidth = 760;

        // Close button
        createCloseButton();

        // File list container
        fileContainer = new Object(this);
        fileContainer.x = 320;
        fileContainer.y = fileListY + 120;
    }

    function createCloseButton() {
        var btnX = 1050;
        var btnY = 115;

        var btnBg = new Graphics(this);
        btnBg.beginFill(0xFF4444);
        btnBg.drawRect(btnX, btnY, 30, 30);
        btnBg.endFill();

        var btnText = new Text(hxd.res.DefaultFont.get(), this);
        btnText.text = "X";
        btnText.textColor = 0xFFFFFF;
        btnText.x = btnX + 8;
        btnText.y = btnY + 5;
        btnText.scale(1.5);

        var interactive = new Interactive(30, 30, this);
        interactive.x = btnX;
        interactive.y = btnY;
        interactive.onClick = function(e) {
            this.remove();  // Close popup
        };
    }

    function refreshFileList() {
        // Clear existing file list
        fileContainer.removeChildren();

        // Update path display
        pathText.text = currentPath;

        var yOffset = 0;

        // Add ".." to go up if not at root
        if (currentPath != "/") {
            createFileEntry("..", true, yOffset);
            yOffset += 25;
        }

        // List directories and files
        if (FileSystem.exists(currentPath) && FileSystem.isDirectory(currentPath)) {
            var entries = FileSystem.readDirectory(currentPath);

            // Separate dirs and files
            var dirs:Array<String> = [];
            var files:Array<String> = [];

            for (entry in entries) {
                var fullPath = currentPath + "/" + entry;
                if (FileSystem.isDirectory(fullPath)) {
                    dirs.push(entry);
                } else if (entry.endsWith(".json")) {
                    files.push(entry);
                }
            }

            // Sort
            dirs.sort((a, b) -> a < b ? -1 : 1);
            files.sort((a, b) -> a < b ? -1 : 1);

            // Show dirs first
            for (dir in dirs) {
                createFileEntry("[" + dir + "]", true, yOffset);
                yOffset += 25;
            }

            // Then files
            for (file in files) {
                createFileEntry(file, false, yOffset);
                yOffset += 25;
            }
        }
    }

    function createFileEntry(name:String, isDir:Bool, yOffset:Float) {
        var entryBg = new Graphics(fileContainer);
        entryBg.beginFill(0x444444);
        entryBg.drawRect(0, yOffset, 760, 20);
        entryBg.endFill();

        var entryText = new Text(hxd.res.DefaultFont.get(), fileContainer);
        entryText.text = name;
        entryText.textColor = isDir ? 0xFFFF88 : 0xFFFFFF;
        entryText.x = 5;
        entryText.y = yOffset + 2;

        var interactive = new Interactive(760, 20, fileContainer);
        interactive.x = 0;
        interactive.y = yOffset;
        interactive.onOver = function(e) {
            entryBg.clear();
            entryBg.beginFill(0x666666);
            entryBg.drawRect(0, yOffset, 760, 20);
            entryBg.endFill();
        };
        interactive.onOut = function(e) {
            entryBg.clear();
            entryBg.beginFill(0x444444);
            entryBg.drawRect(0, yOffset, 760, 20);
            entryBg.endFill();
        };
        interactive.onClick = function(e) {
            if (isDir) {
                navigateTo(name);
            } else {
                selectFile(name);
            }
        };
    }

    function navigateTo(dirName:String) {
        if (dirName == "..") {
            // Go up
            var parts = currentPath.split("/");
            parts.pop();
            currentPath = parts.length > 0 ? parts.join("/") : "/";
            if (currentPath == "") currentPath = "/";
        } else {
            // Go into directory
            var cleanName = dirName.replace("[", "").replace("]", "");
            currentPath = currentPath.endsWith("/")
                ? currentPath + cleanName
                : currentPath + "/" + cleanName;
        }

        refreshFileList();
    }

    function selectFile(fileName:String) {
        // Build path, avoiding double slashes
        var fullPath = currentPath.endsWith("/")
            ? currentPath + fileName
            : currentPath + "/" + fileName;

        trace('File selected: $fullPath');

        if (onFileSelected != null) {
            onFileSelected(fullPath);
        }

        this.remove();  // Close popup
    }
}
