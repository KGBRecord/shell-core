#!/bin/sh
# Zsh Installer Script
# Automatically detects OS and installs zsh

echo "========================================"
echo "    ZSH SHELL INSTALLER"
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

# Check if zsh is already installed
if command -v zsh >/dev/null 2>&1; then
    echo "✅ Zsh is already installed!"
    echo "   Version: $(zsh --version)"
    echo "   Location: $(which zsh)"
    exit 0
fi

echo "🔍 Detecting operating system..."
OS=$(detect_os)
echo "   Detected OS: $OS"
echo ""

echo "📦 Installing zsh..."

case "$OS" in
    "ubuntu"|"debian")
        echo "   Using apt package manager..."
        if command -v sudo >/dev/null 2>&1; then
            sudo apt update && sudo apt install -y zsh
        else
            apt update && apt install -y zsh
        fi
        ;;
    "centos"|"rhel"|"fedora")
        echo "   Using yum/dnf package manager..."
        if command -v dnf >/dev/null 2>&1; then
            if command -v sudo >/dev/null 2>&1; then
                sudo dnf install -y zsh
            else
                dnf install -y zsh
            fi
        elif command -v yum >/dev/null 2>&1; then
            if command -v sudo >/dev/null 2>&1; then
                sudo yum install -y zsh
            else
                yum install -y zsh
            fi
        fi
        ;;
    "alpine")
        echo "   Using apk package manager..."
        if command -v sudo >/dev/null 2>&1; then
            sudo apk add --no-cache zsh
        else
            apk add --no-cache zsh
        fi
        ;;
    "arch")
        echo "   Using pacman package manager..."
        if command -v sudo >/dev/null 2>&1; then
            sudo pacman -S --noconfirm zsh
        else
            pacman -S --noconfirm zsh
        fi
        ;;
    "opensuse"|"suse")
        echo "   Using zypper package manager..."
        if command -v sudo >/dev/null 2>&1; then
            sudo zypper install -y zsh
        else
            zypper install -y zsh
        fi
        ;;
    "macos")
        echo "   Zsh is usually pre-installed on macOS (10.15+)"
        echo "   If not available, using Homebrew..."
        if command -v brew >/dev/null 2>&1; then
            brew install zsh
        else
            echo "   ❌ Homebrew not found. Please install Homebrew first:"
            echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            exit 1
        fi
        ;;
    "freebsd")
        echo "   Using pkg package manager..."
        if command -v sudo >/dev/null 2>&1; then
            sudo pkg install -y zsh
        else
            pkg install -y zsh
        fi
        ;;
    *)
        echo "   ❌ Unsupported operating system: $OS"
        echo "   Please install zsh manually using your system's package manager."
        echo ""
        echo "   Common commands:"
        echo "   - Ubuntu/Debian: apt install zsh"
        echo "   - CentOS/RHEL: yum install zsh"
        echo "   - Alpine: apk add zsh"
        echo "   - Arch: pacman -S zsh"
        echo "   - macOS: brew install zsh"
        exit 1
        ;;
esac

echo ""
echo "🔍 Verifying installation..."

if command -v zsh >/dev/null 2>&1; then
    echo "✅ Zsh installed successfully!"
    echo "   Version: $(zsh --version)"
    echo "   Location: $(which zsh)"
    echo ""
    echo "🎯 You can now use zsh in Shell Fake Core!"
    echo "   Set shell option to 'zsh' in RetroArch core options."
    echo ""
    echo "💡 Optional: Install Oh My Zsh for enhanced experience:"
    echo "   sh -c \"\$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
else
    echo "❌ Installation failed!"
    echo "   Please try installing zsh manually."
    exit 1
fi

echo ""
echo "📝 Quick test:"
echo "   Running: zsh -c 'echo Hello from Zsh!'"
zsh -c 'echo "   Hello from Zsh!"'
echo ""
echo "🚀 Installation complete!"