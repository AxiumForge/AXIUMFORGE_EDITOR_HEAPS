#!/bin/bash
# Simple test to verify screenshot.sh works with viewer

echo "Testing screenshot.sh with viewer window..."
echo ""

# Start viewer
echo "Starting viewer..."
hl bin/viewer.hl assets/jda3d/jda.shape.sphere_basic.json > /dev/null 2>&1 &
VIEWER_PID=$!

# Wait for window to appear
sleep 2

# Try to take a screenshot
echo "Taking screenshot with screenshot.sh..."
mkdir -p sc/test_screenshot
export SHOT_DIR="sc/test_screenshot"
./screenshot.sh

# Wait a bit
sleep 1

# Kill viewer
echo "Stopping viewer..."
kill $VIEWER_PID 2>/dev/null || true

# Check if screenshot was created
echo ""
echo "Screenshot result:"
ls -lh sc/test_screenshot/*.png 2>/dev/null || echo "No screenshot found"
