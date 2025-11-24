#!/bin/bash
# Simple watch script for Heaps development
# Requires fswatch: brew install fswatch

echo "Watching src/ for changes..."
echo "Press Ctrl+C to stop"
echo ""

fswatch -o src/ | while read f; do
    echo "[$(date '+%H:%M:%S')] Change detected, recompiling..."
    haxe build.hxml
    if [ $? -eq 0 ]; then
        echo "✓ Compilation successful"
        echo "Run: hl bin/viewer.hl"
        echo ""
    else
        echo "✗ Compilation failed"
        echo ""
    fi
done
