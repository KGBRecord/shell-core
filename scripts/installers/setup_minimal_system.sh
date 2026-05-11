#!/bin/sh
# Minimal System Shell Setup
# For containers, embedded systems, and ultra-minimal Linux

echo "========================================"
echo "  MINIMAL SYSTEM SHELL SETUP"
echo "========================================"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect system type
detect_system_type() {
    if [ -f /.dockerenv ]; then
        echo "docker"
    elif [ -f /etc/alpine-release ]; then
        echo "alpine"
    elif command_exists busybox; then
        echo "busybox"
    elif [ "$(ls /bin | wc -l)" -lt 20 ]; then
        echo "minimal"
    else
        echo "standard"
    fi
}

# Function to setup BusyBox aliases
setup_busybox_aliases() {
    echo "📦 Setting up BusyBox shell aliases..."
    
    ALIAS_DIR="/usr/local/bin"
    mkdir -p "$ALIAS_DIR"
    
    # Create bash alias that uses ash
    cat > "$ALIAS_DIR/bash" << 'EOF'
#!/bin/sh
# BusyBox bash compatibility wrapper
if command -v busybox >/dev/null 2>&1; then
    exec busybox ash "$@"
else
    exec ash "$@"
fi
EOF
    chmod +x "$ALIAS_DIR/bash"
    
    # Create zsh alias
    cat > "$ALIAS_DIR/zsh" << 'EOF'
#!/bin/sh
# BusyBox zsh compatibility wrapper
echo "Zsh not available, using ash instead"
if command -v busybox >/dev/null 2>&1; then
    exec busybox ash "$@"
else
    exec ash "$@"
fi
EOF
    chmod +x "$ALIAS_DIR/zsh"
    
    # Create dash alias  
    cat > "$ALIAS_DIR/dash" << 'EOF'
#!/bin/sh
# BusyBox dash compatibility wrapper
if command -v busybox >/dev/null 2>&1; then
    exec busybox ash "$@"
else
    exec ash "$@"
fi
EOF
    chmod +x "$ALIAS_DIR/dash"
    
    # Create fish alias
    cat > "$ALIAS_DIR/fish" << 'EOF'
#!/bin/sh
# BusyBox fish compatibility wrapper
echo "Fish not available, using ash instead"
if command -v busybox >/dev/null 2>&1; then
    exec busybox ash "$@"
else
    exec ash "$@"
fi
EOF
    chmod +x "$ALIAS_DIR/fish"
    
    echo "   ✅ Shell compatibility wrappers created"
    echo "   Available shells: bash, zsh, dash, fish (all using ash)"
}

# Function to create a simple shell chooser
create_shell_chooser() {
    echo "📦 Creating shell environment chooser..."
    
    cat > /usr/local/bin/shell-chooser << 'EOF'
#!/bin/sh
# Shell environment chooser for minimal systems

echo "=== Shell Environment Chooser ==="
echo ""
echo "Available shells on this system:"

shells=""
count=1

if command -v bash >/dev/null 2>&1; then
    echo "$count) bash - $(which bash)"
    shells="$shells:bash"
    count=$((count + 1))
fi

if command -v ash >/dev/null 2>&1; then
    echo "$count) ash - $(which ash)"
    shells="$shells:ash"
    count=$((count + 1))
fi

if command -v sh >/dev/null 2>&1; then
    echo "$count) sh - $(which sh)"
    shells="$shells:sh"
    count=$((count + 1))
fi

if command -v dash >/dev/null 2>&1; then
    echo "$count) dash - $(which dash)"
    shells="$shells:dash"
    count=$((count + 1))
fi

if command -v zsh >/dev/null 2>&1; then
    echo "$count) zsh - $(which zsh)"
    shells="$shells:zsh"
    count=$((count + 1))
fi

if command -v fish >/dev/null 2>&1; then
    echo "$count) fish - $(which fish)"
    shells="$shells:fish"
    count=$((count + 1))
fi

echo ""
printf "Choose a shell (1-$((count-1))): "
read choice

case "$choice" in
    1) exec bash ;;
    2) exec ash ;;
    3) exec sh ;;
    4) exec dash ;;
    5) exec zsh ;;
    6) exec fish ;;
    *) echo "Invalid choice, using default shell"; exec sh ;;
esac
EOF
    chmod +x /usr/local/bin/shell-chooser
    
    echo "   ✅ Shell chooser created at /usr/local/bin/shell-chooser"
}

# Function to optimize for containers
setup_container_environment() {
    echo "📦 Setting up container-optimized shell environment..."
    
    # Create minimal .profile
    cat > /etc/profile.d/shell-core.sh << 'EOF'
# Shell Core environment setup
export PATH="/usr/local/bin:$PATH"

# Set default shell for Shell Core
if [ -z "$SHELL_CORE_DEFAULT" ]; then
    if command -v bash >/dev/null 2>&1; then
        export SHELL_CORE_DEFAULT="bash"
    elif command -v ash >/dev/null 2>&1; then
        export SHELL_CORE_DEFAULT="ash"
    else
        export SHELL_CORE_DEFAULT="sh"
    fi
fi

# Alias for convenience
alias shells='shell-chooser'
alias shell-test='sh /usr/local/bin/test_shells.sh'
EOF
    
    echo "   ✅ Container environment configured"
}

# Function to test minimal setup
test_minimal_setup() {
    echo "🧪 Testing minimal shell setup..."
    echo ""
    
    shells="sh bash zsh dash fish ash"
    
    for shell in $shells; do
        if command -v "$shell" >/dev/null 2>&1; then
            printf "   ✅ %-8s" "$shell"
            if $shell -c 'echo "OK"' 2>/dev/null; then
                echo " - Working"
            else
                echo " - Error"
            fi
        else
            printf "   ❌ %-8s" "$shell"
            echo " - Not found"
        fi
    done
    
    echo ""
echo "🎯 Shell Core compatibility:"
    
    if command -v bash >/dev/null 2>&1; then
        echo "   ✅ bash - Recommended for Shell Core"
    elif command -v ash >/dev/null 2>&1; then
        echo "   ✅ ash - Good for Shell Core (BusyBox)"
    elif command -v sh >/dev/null 2>&1; then
        echo "   ✅ sh - Basic Shell Core compatibility"
    else
        echo "   ❌ No compatible shell found"
    fi
}

# Main setup
echo "🔍 System Analysis:"
SYSTEM_TYPE=$(detect_system_type)
echo "   System type: $SYSTEM_TYPE"
echo "   Available shells: $(command -v sh >/dev/null && echo 'sh') $(command -v bash >/dev/null && echo 'bash') $(command -v ash >/dev/null && echo 'ash') $(command -v dash >/dev/null && echo 'dash')"
echo "   BusyBox: $(command -v busybox >/dev/null && echo 'Yes' || echo 'No')"
echo ""

case "$SYSTEM_TYPE" in
    "docker"|"minimal")
        echo "🐳 Detected minimal/container environment"
        echo "   Setting up compatibility layer..."
        setup_busybox_aliases
        create_shell_chooser
        setup_container_environment
        ;;
    "alpine"|"busybox")
        echo "🏔️  Detected Alpine/BusyBox system"
        echo "   Setting up BusyBox optimizations..."
        setup_busybox_aliases
        create_shell_chooser
        ;;
    "standard")
        echo "🖥️  Detected standard system"
        echo "   Basic setup only..."
        create_shell_chooser
        ;;
esac

echo ""
test_minimal_setup

echo ""
echo "📝 Usage instructions:"
echo "   - Run 'shell-chooser' to select shell interactively"
echo "   - Run scripts directly: './script.sh'"
echo "   - Use in Shell Core with any configured shell"
echo ""
echo "🚀 Minimal shell setup completed!"

# Add to PATH
if ! echo "$PATH" | grep -q "/usr/local/bin"; then
    echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.profile
    export PATH="/usr/local/bin:$PATH"
fi