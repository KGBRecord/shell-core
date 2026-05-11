# Shell Core Makefile
# LibRetro core for executing shell scripts

# Variables
DOCKER_COMPOSE = docker-compose
DOCKER_BUILD_SERVICE = shell-core-builder

# Platform detection
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
    PLATFORM = osx
    CORE_EXT = dylib
else ifeq ($(UNAME_S),Linux)
    PLATFORM = linux
    CORE_EXT = so
else
    PLATFORM = windows
    CORE_EXT = dll
endif

# Core info
CORE_NAME = shell_core_libretro
CORE_FILE = $(CORE_NAME).$(CORE_EXT)

# Directories
SRC_DIR = src/libretro
BUILD_DIR = build
CORES_DIR = $(BUILD_DIR)/cores
PACKAGE_DIR = $(BUILD_DIR)/package
SCRIPTS_DIR = scripts/examples
INSTALL_DIR = ~/.config/retroarch/cores

# Default target
.DEFAULT_GOAL := help

# Help target
.PHONY: help
help:
	@echo "Shell Core Build System"
	@echo "============================="
	@echo ""
	@echo "Available targets:"
	@echo "  setup          - Build Docker image and setup environment"
	@echo "  build-so       - Build libretro .so file using Docker (Linux)"
	@echo "  build-native   - Build native file (.dylib on macOS, .dll on Windows)"
	@echo "  build-dylib    - Build macOS .dylib file specifically"
	@echo "  build-dll      - Build Windows .dll file specifically"
	@echo "  build-all      - Build .so file and package files"
	@echo "  package        - Create distribution tar.gz package"
	@echo "  package-files  - Create package files only"
	@echo "  install        - Install core to RetroArch"
	@echo "  setup-roms     - Create Shell-Scripts ROM collection"
	@echo "  clean          - Clean build artifacts"
	@echo "  status         - Show build status"
	@echo "  test           - Run basic tests"
	@echo "  help           - Show this help message"
	@echo ""

# Setup Docker environment
.PHONY: setup
setup:
	@echo "Setting up Docker environment..."
	@$(DOCKER_COMPOSE) build
	@echo "Docker environment ready!"

# Build everything (all platforms we can build)
.PHONY: build-all all
build-all all: package-files
	@echo "Building all possible platforms..."
	@$(MAKE) build-so    # Always build .so via Docker
	@$(MAKE) build-dylib # Build .dylib if on macOS or cross-compile
	@echo "All builds completed successfully!"
	@echo ""
	@echo "Build artifacts:"
	@echo "================"
	@echo "Libretro cores:"
	@ls -la $(SRC_DIR)/*.so 2>/dev/null || echo "  No .so files found"
	@ls -la $(SRC_DIR)/*.dylib 2>/dev/null || echo "  No .dylib files found"  
	@ls -la $(SRC_DIR)/*.dll 2>/dev/null || echo "  No .dll files found"
	@echo ""
	@echo "Package files:"
	@ls -la $(PACKAGE_DIR) 2>/dev/null || echo "  No package files found"

# Build libretro shared library (.so) using Docker
.PHONY: build-so
build-so: setup
	@echo "Building libretro shared library (.so)..."
	@$(DOCKER_COMPOSE) run --rm $(DOCKER_BUILD_SERVICE) sh -c "cd $(SRC_DIR) && make clean && make platform=unix"
	@echo "Libretro core (.so) built successfully!"
	@echo "Output files:"
	@ls -la $(SRC_DIR)/*.so 2>/dev/null || echo "No .so files found in $(SRC_DIR)"

# Build native library (.dylib on macOS, .dll on Windows)  
.PHONY: build-native
build-native:
	@echo "Building native libretro library..."
	@$(MAKE) -C $(SRC_DIR) clean
	@$(MAKE) -C $(SRC_DIR)
	@echo "Native libretro core built successfully!"
	@echo "Output files:"
	@ls -la $(SRC_DIR)/*.dylib $(SRC_DIR)/*.dll 2>/dev/null || echo "No native core files found in $(SRC_DIR)"

# Build macOS .dylib specifically
.PHONY: build-dylib  
build-dylib:
	@echo "Building macOS libretro library (.dylib)..."
	@$(MAKE) -C $(SRC_DIR) clean
	@$(MAKE) -C $(SRC_DIR) platform=osx
	@echo "macOS libretro core (.dylib) built successfully!"
	@echo "Output files:"
	@ls -la $(SRC_DIR)/*.dylib 2>/dev/null || echo "No .dylib files found in $(SRC_DIR)"

# Build Windows .dll specifically
.PHONY: build-dll
build-dll:
	@echo "Building Windows libretro library (.dll)..."
	@$(MAKE) -C $(SRC_DIR) clean  
	@$(MAKE) -C $(SRC_DIR) platform=win
	@echo "Windows libretro core (.dll) built successfully!"
	@echo "Output files:"
	@ls -la $(SRC_DIR)/*.dll 2>/dev/null || echo "No .dll files found in $(SRC_DIR)"

# Create package files
.PHONY: package-files
package-files:
	@echo "Creating package files..."
	@mkdir -p $(PACKAGE_DIR)
	@mkdir -p $(PACKAGE_DIR)/examples
	@cp package/$(CORE_NAME).info $(PACKAGE_DIR)/
	@cp package/retroarch.cfg $(PACKAGE_DIR)/
	@cp -r $(SCRIPTS_DIR)/* $(PACKAGE_DIR)/examples/
	@echo "Package files created in $(PACKAGE_DIR)/"

# Create distribution package (all built files)
.PHONY: package
package: build-all
	@echo "Creating distribution package..."
	@mkdir -p dist
	@echo "Collecting files for package..."
	@mkdir -p dist/shell-core
	@if [ -f "$(SRC_DIR)/shell_core_libretro.so" ]; then cp $(SRC_DIR)/shell_core_libretro.so dist/shell-core/; fi
	@if [ -f "$(SRC_DIR)/shell_core_libretro.dylib" ]; then cp $(SRC_DIR)/shell_core_libretro.dylib dist/shell-core/; fi
	@if [ -f "$(SRC_DIR)/shell_core_libretro.dll" ]; then cp $(SRC_DIR)/shell_core_libretro.dll dist/shell-core/; fi
	@cp $(PACKAGE_DIR)/shell_core_libretro.info dist/shell-core/
	@cp $(PACKAGE_DIR)/retroarch.cfg dist/shell-core/
	@cp -r $(PACKAGE_DIR)/examples dist/shell-core/
	@cp README.md dist/shell-core/
	@cp LICENSE dist/shell-core/
	@cd dist && tar -czf shell-core-$(shell date +%Y%m%d).tar.gz shell-core/
	@rm -rf dist/shell-core
	@echo "Package created: dist/shell-core-$(shell date +%Y%m%d).tar.gz"

# Install core
.PHONY: install
install: build-so
	@echo "Installing core to $(INSTALL_DIR)..."
	@mkdir -p $(INSTALL_DIR)
	@cp $(SRC_DIR)/shell_core_libretro.so $(INSTALL_DIR)/ 2>/dev/null || \
	 cp $(SRC_DIR)/shell_core_libretro.dylib $(INSTALL_DIR)/ 2>/dev/null || \
	 cp $(SRC_DIR)/shell_core_libretro.dll $(INSTALL_DIR)/ 2>/dev/null
	@echo "Core installed successfully!"
	@echo "You can now load it in RetroArch"

# Setup ROM collection
.PHONY: setup-roms
setup-roms:
	@echo "Setting up Shell-Scripts ROM collection..."
	@chmod +x scripts/setup_rom_collection.sh
	@./scripts/setup_rom_collection.sh
	@echo "ROM collection setup completed."

# Clean build files
.PHONY: clean
clean:
	@echo "Cleaning build files..."
	@rm -rf $(BUILD_DIR)
	@$(MAKE) -C $(SRC_DIR) clean
	@echo "Clean completed"

# Test build
.PHONY: test
test: build-so
	@echo "Testing core build..."
	@test -f $(SRC_DIR)/shell_core_libretro.so -o -f $(SRC_DIR)/shell_core_libretro.dylib -o -f $(SRC_DIR)/shell_core_libretro.dll || (echo "ERROR: Core file not found!" && exit 1)
	@echo "Build test passed!"

# Docker build
.PHONY: docker-build
docker-build:
	@echo "Building with Docker..."
	@$(DOCKER_COMPOSE) build
	@$(DOCKER_COMPOSE) run --rm $(DOCKER_BUILD_SERVICE) make

# Docker shell
.PHONY: docker-shell
docker-shell:
	@echo "Starting Docker shell..."
	@$(DOCKER_COMPOSE) run --rm $(DOCKER_BUILD_SERVICE) bash

# Show status
.PHONY: status
status:
	@echo "Build Status:"
	@echo "============="
	@echo ""
	@echo "Core files:"
	@if [ -f "$(SRC_DIR)/shell_core_libretro.so" ]; then \
		echo "  ✓ shell_core_libretro.so ($$(stat -f%z $(SRC_DIR)/shell_core_libretro.so 2>/dev/null || stat -c%s $(SRC_DIR)/shell_core_libretro.so 2>/dev/null || echo 'unknown') bytes)"; \
	else \
		echo "  ✗ shell_core_libretro.so"; \
	fi
	@if [ -f "$(SRC_DIR)/shell_core_libretro.dylib" ]; then \
		echo "  ✓ shell_core_libretro.dylib ($$(stat -f%z $(SRC_DIR)/shell_core_libretro.dylib 2>/dev/null || stat -c%s $(SRC_DIR)/shell_core_libretro.dylib 2>/dev/null || echo 'unknown') bytes)"; \
	else \
		echo "  ✗ shell_core_libretro.dylib"; \
	fi
	@if [ -f "$(SRC_DIR)/shell_core_libretro.dll" ]; then \
		echo "  ✓ shell_core_libretro.dll ($$(stat -f%z $(SRC_DIR)/shell_core_libretro.dll 2>/dev/null || stat -c%s $(SRC_DIR)/shell_core_libretro.dll 2>/dev/null || echo 'unknown') bytes)"; \
	else \
		echo "  ✗ shell_core_libretro.dll"; \
	fi
	@echo ""
	@echo "Package files:"
	@if [ -f "$(PACKAGE_DIR)/$(CORE_NAME).info" ]; then \
		echo "  ✓ $(CORE_NAME).info"; \
	else \
		echo "  ✗ $(CORE_NAME).info"; \
	fi
	@if [ -d "$(PACKAGE_DIR)/examples" ]; then \
		echo "  ✓ Example scripts"; \
	else \
		echo "  ✗ Example scripts"; \
	fi
	@echo ""
	@echo "Distribution package:"
	@if [ -f "dist/shell-core-$(shell date +%Y%m%d).tar.gz" ]; then \
		echo "  ✓ dist/shell-core-$(shell date +%Y%m%d).tar.gz"; \
	else \
		echo "  ✗ Distribution package not created"; \
	fi
	@echo ""
	@echo "Installation:"
	@if [ -f "$(INSTALL_DIR)/shell_core_libretro.so" ] || [ -f "$(INSTALL_DIR)/shell_core_libretro.dylib" ] || [ -f "$(INSTALL_DIR)/shell_core_libretro.dll" ]; then \
		echo "  ✓ Installed in RetroArch"; \
	else \
		echo "  ✗ Not installed"; \
	fi

# Create release package
.PHONY: release
release: clean all
	@echo "Creating release package..."
	@mkdir -p releases
	@tar -czf releases/shell-core-$(shell date +%Y%m%d)-$(PLATFORM).tar.gz \
		-C $(BUILD_DIR) .
	@echo "Release package created: releases/shell-core-$(shell date +%Y%m%d)-$(PLATFORM).tar.gz"