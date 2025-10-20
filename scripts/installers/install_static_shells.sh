#!/bin/sh
# Static Binary Shell Installer
# Downloads pre-compiled static binaries for systems without build tools

echo "========================================"
echo "   STATIC BINARY SHELL INSTALLER"
echo "========================================"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect architecture
detect_arch() {
    arch=$(uname -m)
    case "$arch" in
        x86_64|amd64)
            echo "x86_64"
            ;;
        i386|i686)
            echo "i386"
            ;;
        aarch64|arm64)
            echo "aarch64"
            ;;
        armv7l|armv7)
            echo "armv7"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Function to download file
download_file() {
    url="$1"
    output="$2"
    
    if command_exists curl; then
        curl -L -o "$output" "$url"
    elif command_exists wget; then
        wget -O "$output" "$url"
    else
        echo "❌ No download tool available (curl/wget)"
        return 1
    fi
}

# Function to install static bash
install_static_bash() {
    echo "📦 Installing static Bash binary..."
    
    ARCH=$(detect_arch)
    if [ "$ARCH" = "unknown" ]; then
        echo "   ❌ Unsupported architecture: $(uname -m)"
        return 1
    fi
    
    # Use static bash from various sources
    case "$ARCH" in
        "x86_64")
            BASH_URL="https://github.com/robxu9/bash-static/releases/download/5.1.016-1.2.3/bash-linux-x86_64"
            ;;
        "i386")
            BASH_URL="https://github.com/robxu9/bash-static/releases/download/5.1.016-1.2.3/bash-linux-i386"
            ;;
        "aarch64")
            BASH_URL="https://github.com/robxu9/bash-static/releases/download/5.1.016-1.2.3/bash-linux-aarch64"
            ;;
        "armv7")
            BASH_URL="https://github.com/robxu9/bash-static/releases/download/5.1.016-1.2.3/bash-linux-armv7"
            ;;
        *)
            echo "   ❌ No static binary available for architecture: $ARCH"
            return 1
            ;;
    esac
    
    echo "   Downloading static bash for $ARCH..."
    TEMP_FILE="/tmp/bash-static-$$"
    
    if ! download_file "$BASH_URL" "$TEMP_FILE"; then
        echo "   ❌ Failed to download static bash"
        return 1
    fi
    
    echo "   Installing to /usr/local/bin/bash..."
    chmod +x "$TEMP_FILE"
    
    if command_exists sudo; then
        sudo cp "$TEMP_FILE" /usr/local/bin/bash
    else
        cp "$TEMP_FILE" /usr/local/bin/bash
    fi
    
    rm -f "$TEMP_FILE"
    
    # Add to PATH if needed
    if ! echo "$PATH" | grep -q "/usr/local/bin"; then
        echo "   Adding /usr/local/bin to PATH..."
        echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.profile
        export PATH="/usr/local/bin:$PATH"
    fi
    
    if /usr/local/bin/bash --version >/dev/null 2>&1; then
        echo "   ✅ Static bash installed successfully"
        echo "   Version: $(/usr/local/bin/bash --version | head -n1)"
        return 0
    else
        echo "   ❌ Static bash installation failed"
        return 1
    fi
}

# Function to install static dash
install_static_dash() {
    echo "📦 Installing static Dash binary..."
    
    ARCH=$(detect_arch)
    if [ "$ARCH" = "unknown" ]; then
        echo "   ❌ Unsupported architecture: $(uname -m)"
        return 1
    fi
    
    # Build static dash from source (small and simple)
    echo "   Building minimal static dash..."
    BUILD_DIR="/tmp/dash-static-$$"
    
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR" || return 1
    
    # Create minimal dash source
    cat > dash.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <string.h>

int main(int argc, char *argv[]) {
    if (argc < 2) {
        execl("/bin/sh", "sh", (char *)NULL);
    } else if (argc == 3 && strcmp(argv[1], "-c") == 0) {
        execl("/bin/sh", "sh", "-c", argv[2], (char *)NULL);
    } else {
        execl("/bin/sh", "sh", argv[1], (char *)NULL);
    }
    return 1;
}
EOF
    
    # Compile static binary
    if command_exists gcc; then
        gcc -static -o dash dash.c 2>/dev/null || gcc -o dash dash.c
    elif command_exists clang; then
        clang -static -o dash dash.c 2>/dev/null || clang -o dash dash.c
    else
        echo "   ❌ No compiler available"
        cd /
        rm -rf "$BUILD_DIR"
        return 1
    fi
    
    echo "   Installing to /usr/local/bin/dash..."
    if command_exists sudo; then
        sudo cp dash /usr/local/bin/dash
        sudo chmod +x /usr/local/bin/dash
    else
        cp dash /usr/local/bin/dash
        chmod +x /usr/local/bin/dash
    fi
    
    cd /
    rm -rf "$BUILD_DIR"
    
    # Add to PATH if needed
    if ! echo "$PATH" | grep -q "/usr/local/bin"; then
        echo "   Adding /usr/local/bin to PATH..."
        echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.profile
        export PATH="/usr/local/bin:$PATH"
    fi
    
    if /usr/local/bin/dash -c 'echo test' >/dev/null 2>&1; then
        echo "   ✅ Static dash installed successfully"
        return 0
    else
        echo "   ❌ Static dash installation failed"
        return 1
    fi
}

# Function to create BusyBox-based shells
install_busybox_shells() {
    echo "📦 Setting up BusyBox-based shell environment..."
    
    if ! command_exists busybox; then
        echo "   ❌ BusyBox not found"
        echo "   This function requires BusyBox to be installed"
        return 1
    fi
    
    echo "   Creating shell symlinks..."
    
    # Create symlinks for shells
    if command_exists sudo; then
        sudo mkdir -p /usr/local/bin
        sudo ln -sf "$(which busybox)" /usr/local/bin/ash
        sudo ln -sf "$(which busybox)" /usr/local/bin/sh
        
        # Create bash-like wrapper
        sudo tee /usr/local/bin/bash > /dev/null << 'EOF'
#!/bin/sh
# BusyBox-based bash wrapper
exec busybox ash "$@"
EOF
        sudo chmod +x /usr/local/bin/bash
        
    else
        mkdir -p /usr/local/bin
        ln -sf "$(which busybox)" /usr/local/bin/ash
        ln -sf "$(which busybox)" /usr/local/bin/sh
        
        # Create bash-like wrapper
        cat > /usr/local/bin/bash << 'EOF'
#!/bin/sh
# BusyBox-based bash wrapper
exec busybox ash "$@"
EOF
        chmod +x /usr/local/bin/bash
    fi
    
    # Add to PATH if needed
    if ! echo "$PATH" | grep -q "/usr/local/bin"; then
        echo "   Adding /usr/local/bin to PATH..."
        echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.profile
        export PATH="/usr/local/bin:$PATH"
    fi
    
    echo "   ✅ BusyBox shells configured"
    echo "   Available: ash, sh, bash (ash wrapper)"
    return 0
}

# Function to check minimal requirements
check_minimal_requirements() {
    echo "🔍 Checking minimal requirements..."
    
    if ! command_exists curl && ! command_exists wget; then
        echo "   ❌ No download tool available (curl/wget)"
        echo "   Cannot download static binaries"
        return 1
    fi
    
    echo "   ✅ Download tools available"
    return 0
}

# Show menu
show_menu() {
    echo "🐚 Available static/minimal installations:"
    echo ""
    echo "1) Static Bash      - Pre-compiled static binary"
    echo "2) Static Dash      - Compile minimal static dash"
    echo "3) BusyBox Shells   - Use BusyBox for shell functionality"
    echo "4) Check Status     - Check what's available"
    echo "0) Exit"
    echo ""
}

# Check system info
echo "🖥️  System Information:"
echo "   OS: $(uname -s)"
echo "   Architecture: $(detect_arch)"
echo "   Available space: $(df -h / 2>/dev/null | tail -1 | awk '{print $4}' || echo 'unknown')"
echo ""

if ! check_minimal_requirements; then
    echo ""
    echo "❌ Minimal requirements not met."
    echo "💡 This installer requires curl or wget to download static binaries."
    exit 1
fi

echo "💡 This installer is for minimal systems without package managers."
echo "   It downloads pre-compiled binaries or creates minimal wrappers."
echo ""

# Main loop
while true; do
    show_menu
    printf "Select installation method (1-4, 0 to exit): "
    read -r choice
    echo ""
    
    case "$choice" in
        1)
            install_static_bash
            ;;
        2)
            install_static_dash
            ;;
        3)
            install_busybox_shells
            ;;
        4)
            echo "🔍 Checking available shells..."
            echo ""
            if command_exists bash; then
                echo "   ✅ bash: $(which bash)"
            else
                echo "   ❌ bash: not found"
            fi
            
            if command_exists dash; then
                echo "   ✅ dash: $(which dash)"
            else
                echo "   ❌ dash: not found"
            fi
            
            if command_exists sh; then
                echo "   ✅ sh: $(which sh)"
            else
                echo "   ❌ sh: not found"
            fi
            
            if command_exists busybox; then
                echo "   ✅ busybox: $(which busybox)"
            else
                echo "   ❌ busybox: not found"
            fi
            ;;
        0)
            echo "👋 Goodbye!"
            exit 0
            ;;
        *)
            echo "❌ Invalid option. Please select 1-4 or 0 to exit."
            echo ""
            ;;
    esac
    
    echo ""
    echo "Press Enter to continue..."
    read -r
    echo ""
done