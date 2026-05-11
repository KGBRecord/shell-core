#!/bin/sh
# Bash Installer Script
# Automatically detects OS and installs bash

echo "========================================"
echo "    BASH SHELL INSTALLER"
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

# Check if bash is already installed
if command -v bash >/dev/null 2>&1; then
    echo "✅ Bash is already installed!"
    echo "   Version: $(bash --version | head -n1)"
    echo "   Location: $(which bash)"
    exit 0
fi

echo "🔍 Detecting operating system..."
OS=$(detect_os)
echo "   Detected OS: $OS"
echo ""

echo "📦 Installing bash..."

case "$OS" in
    "ubuntu"|"debian")
        echo "   Using apt package manager..."
        if command -v sudo >/dev/null 2>&1; then
            sudo apt update && sudo apt install -y bash
        else
            apt update && apt install -y bash
        fi
        ;;
    "centos"|"rhel"|"fedora")
        echo "   Using yum/dnf package manager..."
        if command -v dnf >/dev/null 2>&1; then
            if command -v sudo >/dev/null 2>&1; then
                sudo dnf install -y bash
            else
                dnf install -y bash
            fi
        elif command -v yum >/dev/null 2>&1; then
            if command -v sudo >/dev/null 2>&1; then
                sudo yum install -y bash
            else
                yum install -y bash
            fi
        fi
        ;;
    "alpine")
        echo "   Using apk package manager..."
        if command -v sudo >/dev/null 2>&1; then
            sudo apk add --no-cache bash
        else
            apk add --no-cache bash
        fi
        ;;
    "arch")
        echo "   Using pacman package manager..."
        if command -v sudo >/dev/null 2>&1; then
            sudo pacman -S --noconfirm bash
        else
            pacman -S --noconfirm bash
        fi
        ;;
    "opensuse"|"suse")
        echo "   Using zypper package manager..."
        if command -v sudo >/dev/null 2>&1; then
            sudo zypper install -y bash
        else
            zypper install -y bash
        fi
        ;;
    "macos")
        echo "   Using Homebrew (if available)..."
        if command -v brew >/dev/null 2>&1; then
            brew install bash
        else
            echo "   ❌ Homebrew not found. Please install Homebrew first:"
            echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            exit 1
        fi
        ;;
    "freebsd")
        echo "   Using pkg package manager..."
        if command -v sudo >/dev/null 2>&1; then
            sudo pkg install -y bash
        else
            pkg install -y bash
        fi
        ;;
    *)
        echo "   ❌ Unsupported operating system: $OS"
        echo "   Please install bash manually using your system's package manager."
        echo ""
        echo "   Common commands:"
        echo "   - Ubuntu/Debian: apt install bash"
        echo "   - CentOS/RHEL: yum install bash"
        echo "   - Alpine: apk add bash"
        echo "   - Arch: pacman -S bash"
        echo "   - macOS: brew install bash"
        exit 1
        ;;
esac

echo ""
echo "🔍 Verifying installation..."

if command -v bash >/dev/null 2>&1; then
    echo "✅ Bash installed successfully!"
    echo "   Version: $(bash --version | head -n1)"
    echo "   Location: $(which bash)"
    echo ""
    echo "🎯 You can now use bash in Shell Core!"
    echo "   Set shell option to 'bash' in RetroArch core options."
else
    echo "❌ Installation failed!"
    echo "   Please try installing bash manually."
    exit 1
fi

echo ""
echo "📝 Quick test:"
echo "   Running: bash -c 'echo Hello from Bash!'"
bash -c 'echo "   Hello from Bash!"'
echo ""
echo "🚀 Installation complete!"