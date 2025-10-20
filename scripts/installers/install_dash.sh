#!/bin/sh
# Dash Shell Installer Script
# Automatically detects OS and installs dash shell

echo "========================================"
echo "    DASH SHELL INSTALLER"
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

# Check if dash is already installed
if command -v dash >/dev/null 2>&1; then
    echo "✅ Dash shell is already installed!"
    echo "   Location: $(which dash)"
    echo "   Dash is a POSIX-compliant shell focused on speed and efficiency."
    exit 0
fi

echo "🔍 Detecting operating system..."
OS=$(detect_os)
echo "   Detected OS: $OS"
echo ""

echo "⚡ Installing dash shell..."

case "$OS" in
    "ubuntu"|"debian")
        echo "   Using apt package manager..."
        if command -v sudo >/dev/null 2>&1; then
            sudo apt update && sudo apt install -y dash
        else
            apt update && apt install -y dash
        fi
        ;;
    "centos"|"rhel"|"fedora")
        echo "   Using yum/dnf package manager..."
        if command -v dnf >/dev/null 2>&1; then
            if command -v sudo >/dev/null 2>&1; then
                sudo dnf install -y dash
            else
                dnf install -y dash
            fi
        elif command -v yum >/dev/null 2>&1; then
            # For older RHEL/CentOS, might need EPEL
            echo "   Adding EPEL repository..."
            if command -v sudo >/dev/null 2>&1; then
                sudo yum install -y epel-release
                sudo yum install -y dash
            else
                yum install -y epel-release
                yum install -y dash
            fi
        fi
        ;;
    "alpine")
        echo "   Using apk package manager..."
        if command -v sudo >/dev/null 2>&1; then
            sudo apk add --no-cache dash
        else
            apk add --no-cache dash
        fi
        ;;
    "arch")
        echo "   Using pacman package manager..."
        if command -v sudo >/dev/null 2>&1; then
            sudo pacman -S --noconfirm dash
        else
            pacman -S --noconfirm dash
        fi
        ;;
    "opensuse"|"suse")
        echo "   Using zypper package manager..."
        if command -v sudo >/dev/null 2>&1; then
            sudo zypper install -y dash
        else
            zypper install -y dash
        fi
        ;;
    "macos")
        echo "   Using Homebrew..."
        if command -v brew >/dev/null 2>&1; then
            brew install dash
        else
            echo "   ❌ Homebrew not found. Please install Homebrew first:"
            echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            exit 1
        fi
        ;;
    "freebsd")
        echo "   Using pkg package manager..."
        if command -v sudo >/dev/null 2>&1; then
            sudo pkg install -y dash
        else
            pkg install -y dash
        fi
        ;;
    *)
        echo "   ❌ Unsupported operating system: $OS"
        echo "   Please install dash manually using your system's package manager."
        echo ""
        echo "   Common commands:"
        echo "   - Ubuntu/Debian: apt install dash"
        echo "   - CentOS/RHEL: yum install dash"
        echo "   - Alpine: apk add dash"
        echo "   - Arch: pacman -S dash"
        echo "   - macOS: brew install dash"
        echo ""
        echo "   Or compile from source: http://gondor.apana.org.au/~herbert/dash/"
        exit 1
        ;;
esac

echo ""
echo "🔍 Verifying installation..."

if command -v dash >/dev/null 2>&1; then
    echo "✅ Dash shell installed successfully!"
    echo "   Location: $(which dash)"
    echo ""
    echo "🎯 You can now use dash in Shell Fake Core!"
    echo "   Set shell option to 'dash' in RetroArch core options."
    echo ""
    echo "⚡ Dash features:"
    echo "   - POSIX compliance"
    echo "   - Extremely fast startup"
    echo "   - Minimal memory footprint"
    echo "   - Perfect for scripts and embedded systems"
    echo ""
    echo "📝 Note: Dash is designed for script execution, not interactive use."
else
    echo "❌ Installation failed!"
    echo "   Please try installing dash manually."
    exit 1
fi

echo ""
echo "📝 Quick test:"
echo "   Running: dash -c 'echo Hello from Dash!'"
dash -c 'echo "   Hello from Dash! ⚡"'
echo ""
echo "🚀 Installation complete!"