# Shell Installers for Shell Fake Core

This directory contains installer scripts for various shells that can be used with Shell Fake Core.

## Available Installers

### Individual Installers (Package Manager Based)
- `install_bash.sh` - GNU Bash shell installer
- `install_zsh.sh` - Z Shell installer  
- `install_fish.sh` - Fish shell installer
- `install_dash.sh` - Dash shell installer

### Alternative Installation Methods
- `install_from_source.sh` - Compile shells from source code
- `install_static_shells.sh` - Download static binaries for minimal systems
- `setup_minimal_system.sh` - Setup compatibility layer for containers/embedded

### Master Tools
- `install_shells.sh` - Interactive menu to install any or all shells
- `test_shells.sh` - Compatibility testing and validation

## Supported Operating Systems

### Package Manager Based (install_*.sh)
All installers automatically detect your operating system and use the appropriate package manager:

- **Ubuntu/Debian**: `apt`
- **CentOS/RHEL/Fedora**: `yum`/`dnf`
- **Alpine Linux**: `apk`
- **Arch Linux**: `pacman`
- **openSUSE**: `zypper`
- **macOS**: `brew` (Homebrew required)
- **FreeBSD**: `pkg`

### Systems Without Package Managers

#### Source Installation (`install_from_source.sh`)
For systems with build tools but no package manager:
- Requires: `make`, `gcc`/`clang`, `curl`/`wget`, `tar`
- Downloads and compiles from official sources
- Works on any POSIX system with build tools

#### Static Binaries (`install_static_shells.sh`)
For minimal systems without build tools:
- Downloads pre-compiled static binaries
- Supports: x86_64, i386, aarch64, armv7
- Minimal dependencies (only curl/wget)
- Perfect for containers and embedded systems

#### Minimal System Setup (`setup_minimal_system.sh`)
For ultra-minimal systems (containers, embedded):
- Creates compatibility wrappers using existing shells
- BusyBox optimization
- Works with any available shell (sh, ash, dash)
- No additional downloads required

## Usage

### Quick Start (Recommended)
```bash
# Make executable and run master installer
chmod +x install_shells.sh
./install_shells.sh
```

### Installation Methods by System Type

#### Standard Linux with Package Manager
```bash
# Use package manager based installers
./install_bash.sh     # Individual shell
./install_shells.sh   # Interactive menu
```

#### Systems Without Package Managers
```bash
# Method 1: Compile from source (requires build tools)
./install_from_source.sh

# Method 2: Use static binaries (minimal requirements)
./install_static_shells.sh

# Method 3: Minimal system setup (embedded/containers)
./setup_minimal_system.sh
```

#### Docker/Container Systems
```bash
# Best approach for containers
./setup_minimal_system.sh

# Alternative: static binaries
./install_static_shells.sh
```

### Testing and Validation
```bash
# Test shell compatibility
./test_shells.sh

# Check what's installed
./install_shells.sh   # Select option 8
```

## Shell Features Comparison

| Shell | Speed | Features | Compatibility | Use Case |
|-------|-------|----------|---------------|----------|
| **sh** | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ | Scripts, embedded systems |
| **dash** | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ | Fast POSIX scripts |
| **bash** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | General purpose, most compatible |
| **zsh** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | Interactive use, power users |
| **fish** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | Modern features, beginner-friendly |

## Configuration in Shell Fake Core

After installing shells, configure Shell Fake Core in RetroArch:

1. Open RetroArch
2. Load Shell Fake Core
3. Go to **Quick Menu > Core Options**
4. Set **Shell Interpreter** to your preferred shell:
   - `bash` - GNU Bash
   - `zsh` - Z Shell
   - `sh` - Default POSIX shell
   - `fish` - Fish shell
   - `dash` - Dash shell

## Using Installer Scripts as ROMs

### 🎮 Load Installers in Shell Fake Core

The installer scripts can be loaded directly as "ROMs" in RetroArch with Shell Fake Core:

1. **Copy installer scripts to your ROMs directory:**
   ```bash
   # Copy to your RetroArch ROMs folder
   cp scripts/installers/*.sh ~/RetroArch/ROMs/Shell-Scripts/
   ```

2. **Load in RetroArch:**
   - Open RetroArch
   - Load Content → Browse to Shell-Scripts folder
   - Select any installer script (e.g., `install_shells.sh`)
   - Choose Shell Fake Core

3. **Interactive Installation:**
   - The installer will run in the Shell Fake Core interface
   - Use controller to navigate menus (if supported)
   - Follow on-screen prompts for shell installation

### 🎯 Recommended ROM Setup

Create a dedicated folder structure:
```
~/RetroArch/ROMs/Shell-Scripts/
├── Installers/
│   ├── install_shells.sh          # Master installer menu
│   ├── install_bash.sh             # Individual installers
│   ├── install_zsh.sh
│   ├── install_fish.sh
│   ├── install_dash.sh
│   ├── install_from_source.sh      # For no-PM systems
│   ├── install_static_shells.sh    # Static binaries
│   ├── setup_minimal_system.sh     # Minimal systems
│   └── test_shells.sh              # Test compatibility
├── Games/
│   ├── simple_game.sh
│   └── interactive_menu.sh
└── Utilities/
    ├── system_info.sh
    └── file_manager.sh
```

### 🚀 Quick Start ROM Collection

**Step 1:** Copy installer scripts
```bash
mkdir -p ~/RetroArch/ROMs/Shell-Scripts/Installers
cp scripts/installers/*.sh ~/RetroArch/ROMs/Shell-Scripts/Installers/
chmod +x ~/RetroArch/ROMs/Shell-Scripts/Installers/*.sh
```

**Step 2:** Launch in RetroArch
- Load `install_shells.sh` as ROM
- Install desired shells through the gaming interface
- Test with `test_shells.sh` ROM

**Step 3:** Enjoy shell scripting as gaming!
- Any `.sh` file becomes a playable "game"
- Full shell environment in RetroArch interface
- Perfect for system administration through gaming UI

## Special Cases and Troubleshooting

### Systems Without Package Managers

#### Minimal Linux Distributions
- **Tiny Core Linux**: Use `install_static_shells.sh`
- **Alpine (minimal)**: Use `setup_minimal_system.sh` 
- **Custom embedded Linux**: Use `setup_minimal_system.sh`

#### Container Environments
```bash
# Docker containers without package managers
./setup_minimal_system.sh

# Creates compatibility wrappers for all shells
# Uses existing sh/ash/busybox for functionality
```

#### Build From Source Requirements
For `install_from_source.sh` you need:
- C compiler (gcc or clang)
- make
- curl or wget  
- tar
- Basic development headers

#### Static Binary Limitations
- Only available for common architectures (x86_64, aarch64, etc.)
- May not work on all systems due to libc differences
- Limited shell versions available

### Permission Issues
If you get permission errors:
```bash
# Add execute permission
chmod +x *.sh

# Or run with sh
sh install_shells.sh
```

### Package Manager Not Found
- **macOS**: Install Homebrew first
- **Linux**: Ensure your system's package manager is installed
- **Container/Docker**: May need to run as root or with sudo
- **No PM available**: Use source or static installers

### Shell Not Found After Installation
Check installation with:
```bash
./install_shells.sh
# Select option 8 (Check)

# Or manually check
which bash zsh fish dash sh
```

## BusyBox Compatibility

For systems with only BusyBox:
- **sh** is usually available and sufficient
- **dash** may be available in some BusyBox builds
- **bash**, **zsh**, **fish** require separate installation

## Contributing

To add support for additional shells:
1. Create `install_<shell_name>.sh` following the existing pattern
2. Add the shell to `install_shells.sh` menu
3. Update this README

## Notes

- All installers check if the shell is already installed before attempting installation
- Installers use system package managers and require appropriate permissions
- Some shells may require additional configuration for optimal experience
- Fish and Zsh offer enhanced interactive features but may not be compatible with all scripts