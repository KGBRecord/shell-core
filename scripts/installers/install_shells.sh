#!/bin/sh
# Shell Installer Master Script
# Provides a menu to install various shells for Shell Fake Core

echo "========================================"
echo "    SHELL INSTALLER COLLECTION"
echo "========================================"
echo ""
echo "🐚 Available Shell Installers:"
echo ""
echo "=== Package Manager Based ==="
echo "1) Bash     - GNU Bourne Again Shell"
echo "2) Zsh      - Z Shell with advanced features"  
echo "3) Fish     - Friendly Interactive Shell"
echo "4) Dash     - Debian Almquist Shell (fast POSIX)"
echo "5) All      - Install all shells"
echo ""
echo "=== Alternative Methods ==="
echo "6) Source   - Compile from source code"
echo "7) Static   - Static binaries for minimal systems"
echo "8) Check    - Check installed shells"
echo "0) Exit"
echo ""

# Function to detect OS
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    elif [ -f /etc/debian_version ]; then
        echo "debian"
    elif [ -f /etc/redhat-release ]; then
        echo "rhel"
    elif [ -f /etc/alpine-release ]; then
        echo "alpine"
    elif command -v lsb_release >/dev/null 2>&1; then
        lsb_release -si | tr '[:upper:]' '[:lower:]'
    elif [ "$(uname)" = "Darwin" ]; then
        echo "macos"
    elif [ "$(uname)" = "FreeBSD" ]; then
        echo "freebsd"
    else
        echo "unknown"
    fi
}

# Function to check if shell is installed
check_shell() {
    shell_name="$1"
    shell_cmd="$2"
    
    if command -v "$shell_cmd" >/dev/null 2>&1; then
        if [ "$shell_cmd" = "bash" ]; then
            version=$($shell_cmd --version | head -n1)
        elif [ "$shell_cmd" = "zsh" ]; then
            version=$($shell_cmd --version)
        elif [ "$shell_cmd" = "fish" ]; then
            version=$($shell_cmd --version)
        elif [ "$shell_cmd" = "dash" ]; then
            version="POSIX shell"
        else
            version="Unknown version"
        fi
        echo "   ✅ $shell_name: $version ($(which $shell_cmd))"
    else
        echo "   ❌ $shell_name: Not installed"
    fi
}

# Function to check all shells
check_all_shells() {
    echo "🔍 Checking installed shells..."
    echo ""
    check_shell "Bash" "bash"
    check_shell "Zsh" "zsh"
    check_shell "Fish" "fish"
    check_shell "Dash" "dash"
    check_shell "Default sh" "sh"
    echo ""
}

# Function to run installer script
run_installer() {
    script_name="$1"
    script_dir="$(dirname "$0")"
    script_path="$script_dir/$script_name"
    
    if [ -f "$script_path" ]; then
        echo "🚀 Running $script_name..."
        echo ""
        sh "$script_path"
    else
        echo "❌ Installer script not found: $script_path"
        echo "   Please ensure all installer scripts are in the same directory."
        return 1
    fi
}

# Get current OS info
echo "📋 System Information:"
echo "   OS: $(detect_os)"
echo "   Architecture: $(uname -m)"
echo "   Kernel: $(uname -s) $(uname -r)"
echo ""

# Main menu loop
while true; do
    printf "🐚 Select an option (1-8, 0 to exit): "
    read -r choice
    echo ""
    
    case "$choice" in
        1)
            echo "Installing Bash..."
            run_installer "install_bash.sh"
            echo ""
            ;;
        2)
            echo "Installing Zsh..."
            run_installer "install_zsh.sh"
            echo ""
            ;;
        3)
            echo "Installing Fish..."
            run_installer "install_fish.sh"
            echo ""
            ;;
        4)
            echo "Installing Dash..."
            run_installer "install_dash.sh"
            echo ""
            ;;
        5)
            echo "Installing all shells..."
            echo ""
            run_installer "install_bash.sh"
            echo ""
            echo "================================"
            echo ""
            run_installer "install_zsh.sh"
            echo ""
            echo "================================"
            echo ""
            run_installer "install_fish.sh"
            echo ""
            echo "================================"
            echo ""
            run_installer "install_dash.sh"
            echo ""
            echo "🎉 All shell installations completed!"
            echo ""
            ;;
        6)
            echo "Launching source installer..."
            run_installer "install_from_source.sh"
            echo ""
            ;;
        7)
            echo "Launching static binary installer..."
            run_installer "install_static_shells.sh"
            echo ""
            ;;
        8)
            check_all_shells
            ;;
        0)
            echo "👋 Goodbye!"
            exit 0
            ;;
        *)
            echo "❌ Invalid option. Please select 1-8 or 0 to exit."
            echo ""
            ;;
    esac
done