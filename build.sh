#!/bin/bash
# Shell Core Build Script
# Builds the LibRetro core for shell script execution

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Build configuration
BUILD_TYPE="${1:-native}"
CORES_DIR="build/cores"
PACKAGE_DIR="build/package"

print_status "Shell Core Build System"
print_status "============================="
print_status "Build type: $BUILD_TYPE"

# Create build directories
mkdir -p "$CORES_DIR"
mkdir -p "$PACKAGE_DIR"

case "$BUILD_TYPE" in
    "native")
        print_status "Building native core..."
        cd src/libretro
        make clean
        make
        cd ../..
        
        # Copy built core
        if [ -f "src/libretro/shell_core_libretro.so" ]; then
            cp src/libretro/shell_core_libretro.so "$CORES_DIR/"
            print_success "Core built successfully: $CORES_DIR/shell_core_libretro.so"
        elif [ -f "src/libretro/shell_core_libretro.dll" ]; then
            cp src/libretro/shell_core_libretro.dll "$CORES_DIR/"
            print_success "Core built successfully: $CORES_DIR/shell_core_libretro.dll"
        elif [ -f "src/libretro/shell_core_libretro.dylib" ]; then
            cp src/libretro/shell_core_libretro.dylib "$CORES_DIR/"
            print_success "Core built successfully: $CORES_DIR/shell_core_libretro.dylib"
        else
            print_error "Core build failed - no output file found"
            exit 1
        fi
        ;;
        
    "docker")
        print_status "Building with Docker..."
        docker-compose build
        docker-compose run --rm shell-core-builder make -C src/libretro
        
        # Copy from container
        docker-compose run --rm shell-core-builder cp src/libretro/shell_core_libretro.so /workspace/build/cores/
        print_success "Docker build completed"
        ;;
        
    "clean")
        print_status "Cleaning build artifacts..."
        rm -rf build/
        cd src/libretro && make clean && cd ../..
        print_success "Clean completed"
        exit 0
        ;;
        
    *)
        print_error "Unknown build type: $BUILD_TYPE"
        print_status "Usage: $0 [native|docker|clean]"
        exit 1
        ;;
esac

# Copy additional files
print_status "Copying package files..."
cp package/shell_core_libretro.info "$PACKAGE_DIR/"
cp package/retroarch.cfg "$PACKAGE_DIR/"

# Copy example scripts
print_status "Copying example scripts..."
mkdir -p "$PACKAGE_DIR/examples"
cp -r scripts/examples/* "$PACKAGE_DIR/examples/"

# Show build summary
print_status "Build Summary:"
print_status "=============="
echo "Core files:"
ls -la "$CORES_DIR"
echo ""
echo "Package files:"
ls -la "$PACKAGE_DIR"
echo ""
echo "Example scripts:"
ls -la "$PACKAGE_DIR/examples"

print_success "Build completed successfully!"
print_status "To install: make install"
print_status "To test: Load the core in RetroArch and run an example script"