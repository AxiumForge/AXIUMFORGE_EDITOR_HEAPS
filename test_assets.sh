#!/bin/bash

echo "=== AxiumForge Viewer CLI Test ==="
echo ""

test_asset() {
    local path=$1
    local name=$2
    echo "Testing: $name"
    echo "  Path: $path"
    
    # Run viewer for 2 seconds and capture output
    timeout 2s hl bin/viewer.hl "$path" 2>&1 | grep -E "(Auto-positioned|output.color|Successfully compiled)" | head -3
    echo ""
}

test_asset "assets/test/test.box.json" "Green Box"
test_asset "assets/test/test.torus.json" "Purple Torus"  
test_asset "assets/jda3d/jda.shape.sphere_basic.json" "Orange Sphere"
test_asset "assets/jda3d/jda.shape.rounded_box.json" "Grey Rounded Box"

echo "=== All tests complete ==="
