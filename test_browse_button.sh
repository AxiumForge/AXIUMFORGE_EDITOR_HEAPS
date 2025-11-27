#!/bin/bash
# Test Browse button and FileBrowser popup

echo "=== Testing Browse Button & FileBrowser ==="
echo ""

mkdir -p sc/browse_test

# Start viewer
echo "Starting viewer..."
hl bin/viewer.hl assets/jda3d/jda.shape.sphere_basic.json > /dev/null 2>&1 &
VIEWER_PID=$!
sleep 2

# Take initial screenshot
echo "Step 1: Initial state"
export SHOT_DIR="sc/browse_test"
./screenshot.sh
sleep 0.5
latest=$(ls -t sc/browse_test/*.png 2>/dev/null | head -1)
mv "$latest" "sc/browse_test/01_initial.png"
echo "  Screenshot: sc/browse_test/01_initial.png"

# Click Browse button - it's the blue button near top left
# Looking at the screenshot, Browse button appears to be around x=150, y=110
echo ""
echo "Step 2: Clicking Browse button..."
osascript <<'EOF'
tell application "System Events"
    tell application process "hl"
        set frontmost to true
        delay 0.3
        -- Click Browse button (estimated coordinates in window)
        click at {150, 110}
        delay 0.5
    end tell
end tell
EOF

sleep 1

# Take screenshot after clicking Browse
echo "  Taking screenshot after Browse click..."
./screenshot.sh
sleep 0.5
latest=$(ls -t sc/browse_test/*.png 2>/dev/null | head -1)
mv "$latest" "sc/browse_test/02_after_browse_click.png"
echo "  Screenshot: sc/browse_test/02_after_browse_click.png"

# Wait a bit to see if FileBrowser popup appears
sleep 1

# Take another screenshot to capture FileBrowser
echo ""
echo "Step 3: Checking for FileBrowser popup..."
./screenshot.sh
sleep 0.5
latest=$(ls -t sc/browse_test/*.png 2>/dev/null | head -1)
mv "$latest" "sc/browse_test/03_filebrowser_popup.png"
echo "  Screenshot: sc/browse_test/03_filebrowser_popup.png"

# Cleanup
echo ""
echo "Cleaning up..."
kill $VIEWER_PID 2>/dev/null || true
sleep 1

echo ""
echo "=== Browse Test Complete ==="
echo ""
echo "Screenshots:"
ls -lh sc/browse_test/*.png
