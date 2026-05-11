# Shell Core

![Shell Script Execution](https://img.shields.io/badge/Shell-Script%20Execution-green?style=for-the-badge&logo=gnu-bash)

**A LibRetro core that executes shell scripts (.sh files) through a fake gaming interface for various user purposes.**

## 🎮 What is Shell Core?

Shell Core is a LibRetro core that provides a gaming-like interface for executing shell scripts. It creates a fake menu system that allows users to run shell scripts for various purposes - system administration, automation, utilities, or even simple shell-based games. Each `.sh` file is treated as a "ROM" that can be loaded and executed through RetroArch.

### Key Features:
- **Shell Script Execution**: Run any `.sh` script through a gaming interface
- **LibRetro Integration**: Full RetroArch compatibility with fake gaming UI
- **Cross-platform**: Works on Linux, macOS, and Windows (with WSL/Git Bash)
- **Terminal Output Capture**: See script output in real-time through the interface
- **Interactive Scripts**: Support for user input and interactive menus
- **Multi-purpose**: System administration, automation, utilities, or entertainment
- **Flexible Configuration**: Customizable shell and script parameters

## 🚀 Quick Start

### Prerequisites
- LibRetro frontend (RetroArch)
- Shell environment (bash, zsh, etc.)
- Make and GCC for building

### Building

```bash
# Clone the repository
git clone https://github.com/KGBRecord/shell-core.git
cd shell-core

# Setup Docker environment (recommended)
make setup

# Build options:
# Build everything (all platforms)
make build-all

# Build specific platforms:
make build-so      # Build .so file using Docker (Linux)
make build-dylib   # Build .dylib file (macOS)
make build-dll     # Build .dll file (Windows)
make build-native  # Build native file for current platform

# Create package files
make package-files

# Create complete distribution package
make package

# Install to RetroArch cores directory
make install

# Check build status
make status

# Clean build artifacts
make clean
```

#### Build Targets Explained:

- **`make setup`** - Sets up Docker environment for cross-platform builds
- **`make build-all`** - Builds all possible platforms (.so, .dylib)
- **`make build-so`** - Builds Linux shared library using Docker
- **`make build-dylib`** - Builds macOS dynamic library
- **`make build-dll`** - Builds Windows DLL
- **`make build-native`** - Builds for current platform automatically
- **`make package`** - Creates complete distribution tar.gz package
- **`make install`** - Installs core to RetroArch directory
- **`make status`** - Shows build status and file information
- **`make clean`** - Removes all build artifacts

### Usage

1. Copy `shell_core_libretro.so` to your RetroArch cores directory
2. Create or copy `.sh` script files to a directory (your "ROM" directory)
3. In RetroArch:
   - Load Core → Shell Core
   - Load Content → Select your `.sh` file
   - Run your shell script through the interface!

## 📁 Project Structure

```
shell-core/
├── src/
│   └── libretro/
│       ├── shell_core_libretro.c
│       ├── shell_core_libretro.h
│       ├── Makefile
│       └── deps/
├── scripts/
│   ├── examples/
│   │   ├── hello_world.sh
│   │   ├── system_info.sh
│   │   ├── interactive_menu.sh
│   │   ├── simple_game.sh
│   │   └── system_monitor.sh
│   ├── installers/
│   │   ├── install_shells.sh (master installer)
│   │   ├── install_bash.sh
│   │   ├── install_zsh.sh
│   │   ├── install_fish.sh
│   │   ├── install_dash.sh
│   │   ├── install_from_source.sh (for systems without PM)
│   │   ├── install_static_shells.sh (static binaries)
│   │   ├── setup_minimal_system.sh (containers/embedded)
│   │   ├── test_shells.sh (compatibility testing)
│   │   └── README.md
│   └── setup_rom_collection.sh (Automatic ROM setup)
├── package/
│   ├── shell_core_libretro.info
│   └── retroarch.cfg
└── docker/
    ├── Dockerfile
    └── docker-compose.yml
```

## 🐚 Shell Installation

Shell Core includes installer scripts for various shells:

### Quick Shell Setup
```bash
# Navigate to installers directory
cd scripts/installers

# Run interactive installer
./install_shells.sh

# Or install specific shells
./install_bash.sh   # GNU Bash
./install_zsh.sh    # Z Shell
./install_fish.sh   # Fish Shell  
./install_dash.sh   # Dash Shell
```

### 🎮 Use Installer Scripts as ROMs

The installer scripts themselves can be loaded as "ROMs" in Shell Core:

```bash
# Copy installers to your RetroArch ROMs folder
mkdir -p ~/RetroArch/ROMs/Shell-Scripts/Installers
cp scripts/installers/*.sh ~/RetroArch/ROMs/Shell-Scripts/Installers/
chmod +x ~/RetroArch/ROMs/Shell-Scripts/Installers/*.sh

# Then in RetroArch:
# 1. Load Content → Shell-Scripts/Installers/install_shells.sh
# 2. Choose Shell Core
# 3. Install shells through the gaming interface!
```

### Supported Shells
- **bash** - GNU Bourne Again Shell (recommended)
- **zsh** - Z Shell with advanced features
- **fish** - Friendly Interactive Shell
- **dash** - Fast POSIX-compliant shell
- **sh** - Default POSIX shell (usually available)

The installers automatically detect your OS and use the appropriate package manager (apt, yum, apk, brew, etc.).

## 🎯 Example Use Cases

### System Administration Scripts
```bash
#!/bin/bash
echo "=== System Maintenance Menu ==="
echo "1. Check disk usage"
echo "2. Monitor system processes"
echo "3. Update system packages"
echo "4. Backup important files"
read -p "Choose option: " choice
# Script logic here...
```

### Automation Scripts
```bash
#!/bin/bash
echo "=== Automated Tasks ==="
echo "Running scheduled maintenance..."
# Cleanup, backups, monitoring, etc.
echo "Tasks completed!"
```

### Utility Scripts
```bash
#!/bin/bash
echo "=== File Organizer ==="
echo "Organizing downloads folder..."
# Sort files by type, date, etc.
echo "Organization complete!"
```

## 🎮 Setting Up Your Shell ROM Collection

Shell Core treats every `.sh` file as a "ROM" that can be loaded in RetroArch. Here's how to set up your collection:

### Quick ROM Setup

```bash
# Automatic ROM collection setup
chmod +x scripts/setup_rom_collection.sh
./scripts/setup_rom_collection.sh

# Manual setup
mkdir -p ~/RetroArch/ROMs/Shell-Scripts/{Installers,Games,Utilities,System}

# Copy installer scripts
cp scripts/installers/*.sh ~/RetroArch/ROMs/Shell-Scripts/Installers/
cp scripts/examples/*.sh ~/RetroArch/ROMs/Shell-Scripts/Games/

# Make executable
chmod +x ~/RetroArch/ROMs/Shell-Scripts/**/*.sh
```

### Recommended ROM Categories

```
Shell-Scripts/
├── 🔧 Installers/          # Shell installation ROMs
│   ├── install_shells.sh    # Master installer
│   ├── install_bash.sh      # Individual installers
│   ├── test_shells.sh       # Compatibility testing
│   └── setup_minimal_system.sh
├── 🎮 Games/               # Entertainment ROMs
│   ├── hello_world.sh       # Simple introduction
│   ├── simple_game.sh       # Interactive games
│   └── interactive_menu.sh  # Menu-based games
├── 🛠️ Utilities/           # Tool ROMs
│   ├── system_info.sh       # System information
│   ├── file_manager.sh      # File operations
│   └── network_utils.sh     # Network tools
└── ⚙️ System/              # Administration ROMs
    ├── backup_scripts.sh    # Backup automation
    ├── maintenance.sh       # System maintenance
    └── monitoring.sh        # System monitoring
```

### Using ROMs in RetroArch

1. **Load Shell Core**
2. **Load Content** → Browse to `Shell-Scripts/`
3. **Select ROM** (any `.sh` file)
4. **Configure Core Options:**
   - Shell Interpreter: `bash` (recommended)
   - Capture Output: `enabled`
   - Working Directory: `script_dir`
5. **Play!** - Your script runs as a "game"

### Creating Custom ROMs

Any shell script can become a ROM:

```bash
#!/bin/bash
# my_custom_game.sh
echo "=== My Custom Shell Game ==="
echo "1. Option A"
echo "2. Option B" 
read -p "Choose: " choice
case $choice in
    1) echo "You chose A!" ;;
    2) echo "You chose B!" ;;
esac
```

Copy to ROM folder and load in RetroArch!

## ⚙️ Configuration Options

The core supports these RetroArch core options:

- **shell_core_shell**: Choose shell interpreter (bash, zsh, sh)
- **shell_core_timeout**: Script execution timeout (seconds)
- **shell_core_working_dir**: Working directory for scripts
- **shell_core_capture_output**: Enable/disable output capture
- **shell_core_interactive**: Allow interactive input

## 🔧 Core Options

| Option | Description | Values |
|--------|-------------|---------|
| `shell_core_shell` | Shell interpreter to use | `bash`, `zsh`, `sh`, `fish` |
| `shell_core_timeout` | Script timeout in seconds | `0`, `5`, `10`, `30`, `60`, `300` |
| `shell_core_working_dir` | Working directory | `script_dir`, `home`, `tmp` |
| `shell_core_capture_output` | Capture script output | `enabled`, `disabled` |
| `shell_core_interactive` | Allow interactive scripts | `enabled`, `disabled` |

## 🐳 Docker Support

Build using Docker for consistent cross-platform builds:

```bash
# Build with Docker
docker-compose up --build

# Or use the build script
./build.sh docker
```

## 🎮 Creating Shell Script "Games"

### Basic Game Template
```bash
#!/bin/bash
# Game Title: My Shell Game
# Description: A simple shell script game

echo "=== My Shell Game ==="
echo "Starting game..."

# Your game logic here
for i in {1..5}; do
    echo "Turn $i"
    sleep 1
done

echo "Game completed!"
read -p "Press Enter to exit..."
```

### Advanced Game Features
- Use ANSI colors for visual effects
- Implement simple text-based graphics
- Create interactive menus and choices
- Save game state to files
- Network operations and API calls
- System monitoring and utilities

## 🔍 Debugging

Enable debug logging in RetroArch to see core execution details:

```
[Shell Core] Loading script: /path/to/script.sh
[Shell Core] Using shell: /bin/bash
[Shell Core] Script output: Hello World!
[Shell Core] Script finished with exit code: 0
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the GPL-3.0 License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built on LibRetro API
- Thanks to the RetroArch community
- Shell scripting community for inspiration

## 📚 Documentation

- [LibRetro API Documentation](https://docs.libretro.com/)
- [RetroArch Core Development Guide](https://docs.libretro.com/development/cores/)
- [Shell Scripting Best Practices](https://google.github.io/styleguide/shellguide.html)

---

**Warning**: Be careful when running shell scripts from unknown sources. Shell scripts have full system access and can potentially be dangerous. Only run scripts you trust!