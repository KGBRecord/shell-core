# Shell Core - Example Scripts

This directory contains example shell scripts that demonstrate the capabilities of Shell Core. Each script serves a different purpose and showcases how shell scripts can be used through the LibRetro interface.

## 📁 Available Scripts

### 🎮 Entertainment & Games
- **`simple_game.sh`** - A text-based adventure game with RPG elements
- **`interactive_menu.sh`** - Multi-game menu with various mini-games

### 🛠️ System Administration
- **`system_monitor.sh`** - Comprehensive system monitoring dashboard
- **`system_info.sh`** - Basic system information display
- **`file_manager.sh`** - Text-based file management interface

### 🌐 Network Tools
- **`network_utils.sh`** - Network diagnostic and testing utilities

### 👋 Basic Examples
- **`hello_world.sh`** - Simple introduction script

## 🚀 How to Use

1. **Through RetroArch:**
   - Load the Shell Core
   - Browse to this scripts directory
   - Select any `.sh` file as a "ROM"
   - The script will execute in the fake gaming interface

2. **Direct Execution:**
   ```bash
   # Make script executable
   chmod +x script_name.sh
   
   # Run the script
   ./script_name.sh
   ```

## 🎯 Script Categories

### System Administration Scripts
These scripts provide system management functionality through a gaming-like interface:

- **System Monitoring**: Real-time system status, resource usage, and health checks
- **File Management**: Create, copy, move, delete files and directories
- **Network Diagnostics**: Ping tests, port scanning, DNS lookup, speed tests

### Utility Scripts
General-purpose tools for various tasks:

- **Information Gathering**: System specs, network configuration, user data
- **Automation Helpers**: Batch operations, scheduled tasks, maintenance routines

### Entertainment Scripts
Interactive shell games and entertainment:

- **Adventure Games**: Text-based RPGs with combat, inventory, and progression
- **Puzzle Games**: Logic games, word games, number games
- **Interactive Menus**: Choose-your-own-adventure style interfaces

## 🔧 Creating Your Own Scripts

### Basic Template
```bash
#!/bin/bash
# Script Title: Your Script Name
# Description: What your script does

echo "╔══════════════════════════════════════════════════════════════════════════════════════╗"
echo "║                                YOUR SCRIPT TITLE                                     ║"
echo "╚══════════════════════════════════════════════════════════════════════════════════════╝"

# Your script logic here
echo "Hello from Shell Core!"

# Always end with a pause for user interaction
read -p "Press Enter to exit..."
```

### Best Practices

1. **User Interface**: Use clear menus and visual separators
2. **Error Handling**: Check for required commands and files
3. **User Input**: Always validate user input
4. **Cross-Platform**: Test on different operating systems
5. **Documentation**: Include comments explaining complex logic

### Advanced Features

- **Colored Output**: Use ANSI color codes for better visuals
- **Interactive Menus**: Implement menu systems with numbered options
- **Progress Indicators**: Show progress for long-running operations
- **Configuration Files**: Allow users to customize script behavior
- **Logging**: Keep logs of script execution and errors

## 🔒 Security Considerations

**⚠️ IMPORTANT**: These scripts execute with full system privileges. Only run scripts from trusted sources.

### Security Guidelines:
- Review script contents before execution
- Avoid running scripts with `sudo` unless necessary
- Test scripts in a safe environment first
- Be cautious with file operations and system commands
- Never run scripts that prompt for passwords or sensitive data

## 🎨 Customization

### Visual Styling
You can customize the visual appearance of your scripts:

```bash
# Box drawing characters
echo "╔═══╗"
echo "║   ║"
echo "╚═══╝"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Success message${NC}"
echo -e "${RED}Error message${NC}"
```

### Interactive Elements
```bash
# Menu selection
select option in "Option 1" "Option 2" "Exit"; do
    case $option in
        "Option 1") echo "You chose option 1"; break ;;
        "Option 2") echo "You chose option 2"; break ;;
        "Exit") exit 0 ;;
    esac
done

# Progress bar
for i in {1..100}; do
    printf "\rProgress: %d%%" $i
    sleep 0.1
done
echo ""
```

## 📚 Learning Resources

- [Bash Scripting Guide](https://tldp.org/LDP/abs/html/)
- [Shell Scripting Tutorial](https://www.shellscript.sh/)
- [Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/)

## 🤝 Contributing

Feel free to contribute your own example scripts! Make sure they:

1. Are well-documented
2. Follow security best practices
3. Work across different platforms
4. Provide clear user interaction
5. Include error handling

---

**Have fun creating and running shell scripts through Shell Core!** 🚀