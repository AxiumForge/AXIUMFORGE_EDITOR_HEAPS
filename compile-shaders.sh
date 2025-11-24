#!/bin/bash
# ════════════════════════════════════════════════════════════════
# JDA Shader Compiler - Batch compile all JDA assets to HXSL
# ════════════════════════════════════════════════════════════════
#
# Usage:
#   ./compile-shaders.sh              # Compile all assets in assets/jda3d/
#   ./compile-shaders.sh --watch      # Watch mode (auto-recompile on changes)
#   ./compile-shaders.sh --clean      # Clean generated shaders
#
# Output:
#   Generated shaders are written to src/generated/
#

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directories
ASSETS_DIR="assets/jda3d"
OUTPUT_DIR="src/generated"

# Functions
print_header() {
    echo -e "${BLUE}════════════════════════════════════════${NC}"
    echo -e "${BLUE}  JDA → HXSL Shader Compiler${NC}"
    echo -e "${BLUE}════════════════════════════════════════${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${YELLOW}→${NC} $1"
}

# Clean generated shaders
clean_shaders() {
    print_header
    print_info "Cleaning generated shaders..."

    if [ -d "$OUTPUT_DIR" ]; then
        rm -rf "$OUTPUT_DIR"
        print_success "Removed $OUTPUT_DIR"
    else
        print_info "$OUTPUT_DIR does not exist"
    fi

    echo ""
    print_success "Clean complete"
}

# Compile all shaders
compile_shaders() {
    print_header
    print_info "Compiling JDA assets to HXSL shaders..."
    echo ""

    # Check if assets directory exists
    if [ ! -d "$ASSETS_DIR" ]; then
        print_error "Assets directory not found: $ASSETS_DIR"
        exit 1
    fi

    # Create output directory if it doesn't exist
    mkdir -p "$OUTPUT_DIR"

    # Run batch compiler
    print_info "Running: haxe --run tools.Jda2Hxsl --batch $ASSETS_DIR $OUTPUT_DIR"
    echo ""

    haxe -cp src --run tools.Jda2Hxsl --batch "$ASSETS_DIR" "$OUTPUT_DIR"

    # Check result
    if [ $? -eq 0 ]; then
        echo ""
        print_success "Shader compilation complete!"
        print_info "Generated shaders in: $OUTPUT_DIR"
    else
        echo ""
        print_error "Shader compilation failed!"
        exit 1
    fi
}

# Watch mode - recompile on file changes
watch_shaders() {
    print_header
    print_info "Watch mode: monitoring $ASSETS_DIR for changes..."
    print_info "Press Ctrl+C to stop"
    echo ""

    # Check if fswatch is installed
    if ! command -v fswatch &> /dev/null; then
        print_error "fswatch not found. Install with: brew install fswatch"
        print_info "Falling back to simple loop..."
        echo ""

        # Simple polling fallback
        while true; do
            compile_shaders
            print_info "Waiting for changes... (checking every 5 seconds)"
            sleep 5
        done
    else
        # Use fswatch for efficient file monitoring
        fswatch -o "$ASSETS_DIR" | while read change; do
            echo ""
            print_info "Changes detected, recompiling..."
            compile_shaders
            echo ""
            print_info "Watching for changes..."
        done
    fi
}

# Main
case "${1:-}" in
    --clean)
        clean_shaders
        ;;
    --watch)
        watch_shaders
        ;;
    --help|-h)
        print_header
        echo ""
        echo "Usage:"
        echo "  ./compile-shaders.sh           Compile all JDA assets"
        echo "  ./compile-shaders.sh --watch   Watch mode (auto-recompile)"
        echo "  ./compile-shaders.sh --clean   Remove generated shaders"
        echo "  ./compile-shaders.sh --help    Show this help"
        echo ""
        ;;
    *)
        compile_shaders
        ;;
esac
