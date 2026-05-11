#!/bin/sh
# Fish Shell Installer Script
# Automatically detects OS and installs fish shell

echo "========================================"
echo "    FISH SHELL INSTALLER"
echo "========================================"
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

# Check if fish is already installed
if command -v fish >/dev/null 2>&1; then
    echo "✅ Fish shell is already installed!"
    echo "   Version: $(fish --version)"
    echo "   Location: $(which fish)"
    exit 0
fi

echo "🔍 Detecting operating system..."
OS=$(detect_os)
echo "   Detected OS: $OS"
echo ""

echo "🐟 Installing fish shell..."

case "$OS" in
    "ubuntu"|"debian")
        echo "   Using apt package manager..."
        if command -v sudo >/dev/null 2>&1; then
            sudo apt update && sudo apt install -y fish
        else
            apt update && apt install -y fish
        fi
        ;;
    "centos"|"rhel"|"fedora")
        echo "   Using yum/dnf package manager..."
        if command -v dnf >/dev/null 2>&1; then
            if command -v sudo >/dev/null 2>&1; then
                sudo dnf install -y fish
            else
                dnf install -y fish
            fi
        elif command -v yum >/dev/null 2>&1; then
            # For older RHEL/CentOS, might need EPEL
            echo "   Adding EPEL repository..."
            if command -v sudo >/dev/null 2>&1; then
                sudo yum install -y epel-release
                sudo yum install -y fish
            else
                yum install -y epel-release
                yum install -y fish
            fi
        fi
        ;;
    "alpine")
        echo "   Using apk package manager..."
        if command -v sudo >/dev/null 2>&1; then
            sudo apk add --no-cache fish
        else
            apk add --no-cache fish
        fi
        ;;
    "arch")
        echo "   Using pacman package manager..."
        if command -v sudo >/dev/null 2>&1; then
            sudo pacman -S --noconfirm fish
        else
            pacman -S --noconfirm fish
        fi
        ;;
    "opensuse"|"suse")
        echo "   Using zypper package manager..."
        if command -v sudo >/dev/null 2>&1; then
            sudo zypper install -y fish
        else
            zypper install -y fish
        fi
        ;;
    "macos")
        echo "   Using Homebrew..."
        if command -v brew >/dev/null 2>&1; then
            brew install fish
        else
            echo "   ❌ Homebrew not found. Please install Homebrew first:"
            echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            exit 1
        fi
        ;;
    "freebsd")
        echo "   Using pkg package manager..."
        if command -v sudo >/dev/null 2>&1; then
            sudo pkg install -y fish
        else
            pkg install -y fish
        fi
        ;;
    *)
        echo "   ❌ Unsupported operating system: $OS"
        echo "   Please install fish manually using your system's package manager."
        echo ""
        echo "   Common commands:"
        echo "   - Ubuntu/Debian: apt install fish"
        echo "   - CentOS/RHEL: yum install epel-release && yum install fish"
        echo "   - Alpine: apk add fish"
        echo "   - Arch: pacman -S fish"
        echo "   - macOS: brew install fish"
        echo ""
        echo "   Or compile from source: https://github.com/fish-shell/fish-shell"
        exit 1
        ;;
esac

echo ""
echo "🔍 Verifying installation..."

if command -v fish >/dev/null 2>&1; then
    echo "✅ Fish shell installed successfully!"
    echo "   Version: $(fish --version)"
    echo "   Location: $(which fish)"
    echo ""
    echo "🎯 You can now use fish in Shell Core!"
    echo "   Set shell option to 'fish' in RetroArch core options."
    echo ""
    echo "🐟 Fish features:"
    echo "   - Syntax highlighting"
    echo "   - Intelligent autosuggestions"
    echo "   - Tab completions"
    echo "   - Web-based configuration"
    echo ""
    echo "💡 To configure fish, run: fish_config"
else
    echo "❌ Installation failed!"
    echo "   Please try installing fish manually."
    exit 1
fi

echo ""
echo "📝 Quick test:"
echo "   Running: fish -c 'echo Hello from Fish!'"
fish -c 'echo "   Hello from Fish! 🐟"'
echo ""
echo "🚀 Installation complete!"