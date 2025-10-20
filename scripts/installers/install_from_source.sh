#!/bin/sh
# Source-based Shell Installer
# For systems without package managers or when package managers fail

echo "========================================"
echo "   SOURCE-BASED SHELL INSTALLER"
echo "========================================"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check build tools
check_build_tools() {
    echo "🔧 Checking build tools..."
    
    missing_tools=""
    
    if ! command_exists "make"; then
        missing_tools="$missing_tools make"
    fi
    
    if ! command_exists "gcc" && ! command_exists "clang"; then
        missing_tools="$missing_tools gcc/clang"
    fi
    
    if ! command_exists "curl" && ! command_exists "wget"; then
        missing_tools="$missing_tools curl/wget"
    fi
    
    if ! command_exists "tar"; then
        missing_tools="$missing_tools tar"
    fi
    
    if [ -n "$missing_tools" ]; then
        echo "   ❌ Missing required tools:$missing_tools"
        echo "   Please install these tools first or use a system with a package manager."
        return 1
    else
        echo "   ✅ All required build tools found"
        return 0
    fi
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

# Function to install Bash from source
install_bash_source() {
    echo "📦 Installing Bash from source..."
    
    BASH_VERSION="5.2.21"
    BASH_URL="https://ftp.gnu.org/gnu/bash/bash-${BASH_VERSION}.tar.gz"
    BUILD_DIR="/tmp/bash-build-$$"
    
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR" || return 1
    
    echo "   Downloading Bash ${BASH_VERSION}..."
    if ! download_file "$BASH_URL" "bash-${BASH_VERSION}.tar.gz"; then
        echo "   ❌ Failed to download Bash"
        return 1
    fi
    
    echo "   Extracting..."
    tar -xzf "bash-${BASH_VERSION}.tar.gz"
    cd "bash-${BASH_VERSION}" || return 1
    
    echo "   Configuring..."
    ./configure --prefix=/usr/local --enable-job-control --enable-alias
    
    echo "   Compiling... (this may take a while)"
    make -j$(nproc 2>/dev/null || echo 2)
    
    echo "   Installing..."
    if command_exists sudo; then
        sudo make install
    else
        make install
    fi
    
    # Add to PATH if needed
    if ! echo "$PATH" | grep -q "/usr/local/bin"; then
        echo "   Adding /usr/local/bin to PATH..."
        echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.profile
        export PATH="/usr/local/bin:$PATH"
    fi
    
    cd /
    rm -rf "$BUILD_DIR"
    
    if command_exists bash; then
        echo "   ✅ Bash installed successfully"
        return 0
    else
        echo "   ❌ Bash installation failed"
        return 1
    fi
}

# Function to install Zsh from source  
install_zsh_source() {
    echo "📦 Installing Zsh from source..."
    
    ZSH_VERSION="5.9"
    ZSH_URL="https://sourceforge.net/projects/zsh/files/zsh/${ZSH_VERSION}/zsh-${ZSH_VERSION}.tar.xz/download"
    BUILD_DIR="/tmp/zsh-build-$$"
    
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR" || return 1
    
    echo "   Downloading Zsh ${ZSH_VERSION}..."
    if ! download_file "$ZSH_URL" "zsh-${ZSH_VERSION}.tar.xz"; then
        echo "   ❌ Failed to download Zsh"
        return 1
    fi
    
    echo "   Extracting..."
    if command_exists xz; then
        tar -xJf "zsh-${ZSH_VERSION}.tar.xz"
    else
        echo "   ❌ xz not available, trying alternative download..."
        # Try alternative URL with .gz
        ZSH_URL_ALT="https://www.zsh.org/pub/zsh-${ZSH_VERSION}.tar.gz"
        if ! download_file "$ZSH_URL_ALT" "zsh-${ZSH_VERSION}.tar.gz"; then
            echo "   ❌ Failed to download Zsh alternative"
            return 1
        fi
        tar -xzf "zsh-${ZSH_VERSION}.tar.gz"
    fi
    
    cd "zsh-${ZSH_VERSION}" || return 1
    
    echo "   Configuring..."
    ./configure --prefix=/usr/local
    
    echo "   Compiling... (this may take a while)"
    make -j$(nproc 2>/dev/null || echo 2)
    
    echo "   Installing..."
    if command_exists sudo; then
        sudo make install
    else
        make install
    fi
    
    # Add to PATH if needed
    if ! echo "$PATH" | grep -q "/usr/local/bin"; then
        echo "   Adding /usr/local/bin to PATH..."
        echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.profile
        export PATH="/usr/local/bin:$PATH"
    fi
    
    cd /
    rm -rf "$BUILD_DIR"
    
    if command_exists zsh; then
        echo "   ✅ Zsh installed successfully"
        return 0
    else
        echo "   ❌ Zsh installation failed"
        return 1
    fi
}

# Function to install Dash from source
install_dash_source() {
    echo "📦 Installing Dash from source..."
    
    DASH_VERSION="0.5.12"
    DASH_URL="http://gondor.apana.org.au/~herbert/dash/files/dash-${DASH_VERSION}.tar.gz"
    BUILD_DIR="/tmp/dash-build-$$"
    
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR" || return 1
    
    echo "   Downloading Dash ${DASH_VERSION}..."
    if ! download_file "$DASH_URL" "dash-${DASH_VERSION}.tar.gz"; then
        echo "   ❌ Failed to download Dash"
        return 1
    fi
    
    echo "   Extracting..."
    tar -xzf "dash-${DASH_VERSION}.tar.gz"
    cd "dash-${DASH_VERSION}" || return 1
    
    echo "   Configuring..."
    ./configure --prefix=/usr/local
    
    echo "   Compiling..."
    make -j$(nproc 2>/dev/null || echo 2)
    
    echo "   Installing..."
    if command_exists sudo; then
        sudo make install
    else
        make install
    fi
    
    # Add to PATH if needed
    if ! echo "$PATH" | grep -q "/usr/local/bin"; then
        echo "   Adding /usr/local/bin to PATH..."
        echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.profile
        export PATH="/usr/local/bin:$PATH"
    fi
    
    cd /
    rm -rf "$BUILD_DIR"
    
    if command_exists dash; then
        echo "   ✅ Dash installed successfully"
        return 0
    else
        echo "   ❌ Dash installation failed"
        return 1
    fi
}

# Function to install Fish from source
install_fish_source() {
    echo "📦 Installing Fish from source..."
    echo "   ⚠️  Fish requires additional dependencies (cmake, ncurses-dev)"
    echo "   This installation may be complex on minimal systems."
    
    FISH_VERSION="3.6.1"
    FISH_URL="https://github.com/fish-shell/fish-shell/releases/download/${FISH_VERSION}/fish-${FISH_VERSION}.tar.xz"
    BUILD_DIR="/tmp/fish-build-$$"
    
    # Check for cmake
    if ! command_exists cmake; then
        echo "   ❌ cmake not found. Fish requires cmake to build."
        echo "   Please install cmake first or choose a different shell."
        return 1
    fi
    
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR" || return 1
    
    echo "   Downloading Fish ${FISH_VERSION}..."
    if ! download_file "$FISH_URL" "fish-${FISH_VERSION}.tar.xz"; then
        echo "   ❌ Failed to download Fish"
        return 1
    fi
    
    echo "   Extracting..."
    if command_exists xz; then
        tar -xJf "fish-${FISH_VERSION}.tar.xz"
    else
        echo "   ❌ xz not available for extraction"
        return 1
    fi
    
    cd "fish-${FISH_VERSION}" || return 1
    
    echo "   Configuring with cmake..."
    mkdir build
    cd build
    cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local
    
    echo "   Compiling... (this may take a while)"
    make -j$(nproc 2>/dev/null || echo 2)
    
    echo "   Installing..."
    if command_exists sudo; then
        sudo make install
    else
        make install
    fi
    
    # Add to PATH if needed
    if ! echo "$PATH" | grep -q "/usr/local/bin"; then
        echo "   Adding /usr/local/bin to PATH..."
        echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.profile
        export PATH="/usr/local/bin:$PATH"
    fi
    
    cd /
    rm -rf "$BUILD_DIR"
    
    if command_exists fish; then
        echo "   ✅ Fish installed successfully"
        return 0
    else
        echo "   ❌ Fish installation failed"
        return 1
    fi
}

# Main installation menu
show_menu() {
    echo "🐚 Available shells for source installation:"
    echo ""
    echo "1) Bash     - GNU Bourne Again Shell (recommended)"
    echo "2) Zsh      - Z Shell"
    echo "3) Dash     - Fast POSIX shell"
    echo "4) Fish     - Modern shell (requires cmake)"
    echo "0) Exit"
    echo ""
}

# Check system compatibility
echo "🖥️  System Information:"
echo "   OS: $(uname -s)"
echo "   Architecture: $(uname -m)"
echo "   Kernel: $(uname -r)"
echo ""

if ! check_build_tools; then
    echo ""
    echo "❌ Cannot proceed without required build tools."
    echo "💡 Try installing on a system with a package manager first."
    exit 1
fi

echo ""
echo "⚠️  WARNING: Source installation takes time and requires build tools."
echo "   This method should only be used when package managers are unavailable."
echo ""

# Main loop
while true; do
    show_menu
    printf "Select shell to install (1-4, 0 to exit): "
    read -r choice
    echo ""
    
    case "$choice" in
        1)
            install_bash_source
            ;;
        2) 
            install_zsh_source
            ;;
        3)
            install_dash_source
            ;;
        4)
            install_fish_source
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