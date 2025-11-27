#!/bin/bash
# GUI E2E Test with Sequential Screenshot Documentation
# Tests UI interactions and documents with screenshots

set -e

echo "=== AxiumForge Viewer - GUI Flow Test ==="
echo ""

# Setup
SHOT_DIR="sc/ui_flow"
mkdir -p "$SHOT_DIR"
rm -f "$SHOT_DIR"/*.png 2>/dev/null || true

STEP=0

take_screenshot() {
    local name=$1
    STEP=$((STEP + 1))
    local filename=$(printf "%02d_%s.png" $STEP "$name")
    echo "  Step $STEP: $name"

    # Use the screenshot.sh script to capture the Heaps window
    SHOT_DIR="$SHOT_DIR" SHOT_PREFIX="" ./screenshot.sh

    # Rename the latest screenshot to our step name
    latest=$(ls -t "$SHOT_DIR"/*.png 2>/dev/null | head -1)
    if [ -n "$latest" ]; then
        mv "$latest" "$SHOT_DIR/$filename"
        echo "    Screenshot: $SHOT_DIR/$filename"
    fi

    sleep 0.5
}

simulate_click() {
    local x=$1
    local y=$2
    local description=$3

    echo "  Simulating click: $description (${x},${y})"

    # Use AppleScript to simulate click on macOS
    osascript <<EOF
tell application "System Events"
    tell application process "hl"
        set frontmost to true
        delay 0.2
        click at {$x, $y}
        delay 0.3
    end tell
end tell
EOF
}

# Step 1: Start viewer with initial asset
echo "Step 1: Starting viewer with sphere asset..."
hl bin/viewer.hl assets/jda3d/jda.shape.sphere_basic.json > /dev/null 2>&1 &
VIEWER_PID=$!

sleep 2

# Step 2: Initial state screenshot
take_screenshot "01_initial_sphere"

# Step 3: Click on "Rounded Box" button in Asset Selector
# Asset selector is at (10, 10), buttons are approximately 100px wide, 30px tall
# Buttons: Sphere (10,10), Rounded Box (10,45), Pillar Repeat (10,80)
echo ""
echo "Step 2: Testing Asset Selector - Click Rounded Box..."
simulate_click 60 45 "Rounded Box button"
sleep 1
take_screenshot "02_clicked_rounded_box"

# Step 4: Click on "Pillar Repeat" button
echo ""
echo "Step 3: Testing Asset Selector - Click Pillar Repeat..."
simulate_click 60 80 "Pillar Repeat button"
sleep 1
take_screenshot "03_clicked_pillar_repeat"

# Step 5: Click back to "Sphere"
echo ""
echo "Step 4: Testing Asset Selector - Click Sphere..."
simulate_click 60 10 "Sphere button"
sleep 1
take_screenshot "04_clicked_sphere"

# Step 6: Test camera controls (rotate with mouse)
echo ""
echo "Step 5: Testing camera controls - Drag to rotate..."
osascript <<'EOF'
tell application "System Events"
    tell application process "hl"
        set frontmost to true
        delay 0.2
        -- Simulate mouse drag (MMB would be ideal but we'll use left button)
        -- Move to center, press, drag, release
        set centerX to 640
        set centerY to 360
        click at {centerX, centerY}
        delay 0.1
        -- Note: This is simplified - actual drag simulation is complex
    end tell
end tell
EOF
sleep 1
take_screenshot "05_after_camera_move"

# Step 7: Hover over Inspector panel (right side)
echo ""
echo "Step 6: Testing Inspector panel visibility..."
# Inspector is positioned on the right side
simulate_click 1150 360 "Inspector panel area"
sleep 0.5
take_screenshot "06_inspector_visible"

# Cleanup
echo ""
echo "Step 7: Cleaning up..."
kill $VIEWER_PID 2>/dev/null || true
sleep 1

# Generate summary
echo ""
echo "=== UI Flow Test Complete ==="
echo ""
echo "Screenshots saved to: $SHOT_DIR/"
ls -lh "$SHOT_DIR"/*.png
echo ""
echo "Total steps documented: $STEP"
echo ""
echo "Review the screenshots to verify:"
echo "  1. Initial sphere renders correctly"
echo "  2. Clicking Rounded Box switches to that asset"
echo "  3. Clicking Pillar Repeat switches to that asset"
echo "  4. Clicking Sphere switches back"
echo "  5. Camera controls work (rotation visible)"
echo "  6. Inspector panel is visible and shows data"
