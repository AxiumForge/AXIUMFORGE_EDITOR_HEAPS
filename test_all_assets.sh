#!/bin/bash
# Test all 3D JDA assets with screenshot generation

echo "=== Testing all 3D JDA assets with screenshots ==="
echo ""

mkdir -p sc

# Test each asset
test_asset() {
    local asset=$1
    local name=$(basename "$asset" .json)

    echo "Testing: $name"
    echo "  Path: $asset"

    # Run viewer with screenshot
    hl bin/viewer.hl "$asset" --screenshot "sc/${name}.png" 2>&1 &
    VIEWER_PID=$!
    sleep 4
    kill $VIEWER_PID 2>/dev/null
    wait $VIEWER_PID 2>/dev/null

    # Check result
    if [ -f "sc/${name}.png" ]; then
        ls -lh "sc/${name}.png" | awk '{print "  Screenshot: " $9 " (" $5 ")"}'
    else
        echo "  Screenshot: FAILED"
    fi
    echo ""
}

# Test all 3D assets
test_asset "assets/jda3d/jda.shape.sphere_basic.json"
test_asset "assets/jda3d/jda.shape.rounded_box.json"
test_asset "assets/jda3d/jda.shape.pillar_repeat.json"
test_asset "assets/test/test.box.json"
test_asset "assets/test/test.torus.json"

echo "=== Screenshot Summary ==="
ls -lh sc/*.png 2>/dev/null
echo ""
echo "Total screenshots: $(ls sc/*.png 2>/dev/null | wc -l | tr -d ' ')"
