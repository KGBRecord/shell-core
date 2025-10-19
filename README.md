# Shell Fake Core

![Shell Script Execution](https://img.shields.io/badge/Shell-Script%20Execution-green?style=for-the-badge&logo=gnu-bash)

**A LibRetro core that executes shell scripts (.sh files) through a fake gaming interface for various user purposes.**

## 🎮 What is Shell Fake Core?

Shell Fake Core is a LibRetro core that provides a gaming-like interface for executing shell scripts. It creates a fake menu system that allows users to run shell scripts for various purposes - system administration, automation, utilities, or even simple shell-based games. Each `.sh` file is treated as a "ROM" that can be loaded and executed through RetroArch.

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
git clone https://github.com/KGBRecord/shell-fake-core.git
cd shell-fake-core

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

1. Copy `shell_fake_libretro.so` to your RetroArch cores directory
2. Create or copy `.sh` script files to a directory (your "ROM" directory)
3. In RetroArch:
   - Load Core → Shell Fake Core
   - Load Content → Select your `.sh` file
   - Run your shell script through the interface!

## 📁 Project Structure

```
shell-fake-core/
├── README.md
├── LICENSE
├── Makefile
├── build.sh
├── src/
│   └── libretro/
│       ├── shell_fake_libretro.c
│       ├── shell_fake_libretro.h
│       └── Makefile
├── scripts/
│   └── examples/
│       ├── hello_world.sh
│       ├── system_info.sh
│       ├── interactive_menu.sh
│       └── simple_game.sh
├── package/
│   ├── shell_fake_libretro.info
│   └── retroarch.cfg
└── docker/
    ├── Dockerfile
    └── docker-compose.yml
```

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

## ⚙️ Configuration Options

The core supports these RetroArch core options:

- **shell_fake_shell**: Choose shell interpreter (bash, zsh, sh)
- **shell_fake_timeout**: Script execution timeout (seconds)
- **shell_fake_working_dir**: Working directory for scripts
- **shell_fake_capture_output**: Enable/disable output capture
- **shell_fake_interactive**: Allow interactive input

## 🔧 Core Options

| Option | Description | Values |
|--------|-------------|---------|
| `shell_fake_shell` | Shell interpreter to use | `bash`, `zsh`, `sh`, `fish` |
| `shell_fake_timeout` | Script timeout in seconds | `0`, `5`, `10`, `30`, `60`, `300` |
| `shell_fake_working_dir` | Working directory | `script_dir`, `home`, `tmp` |
| `shell_fake_capture_output` | Capture script output | `enabled`, `disabled` |
| `shell_fake_interactive` | Allow interactive scripts | `enabled`, `disabled` |

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
[Shell Fake Core] Loading script: /path/to/script.sh
[Shell Fake Core] Using shell: /bin/bash
[Shell Fake Core] Script output: Hello World!
[Shell Fake Core] Script finished with exit code: 0
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