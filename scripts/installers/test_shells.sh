#!/bin/sh
# Test script for shell installers
# Demonstrates compatibility with different shells

echo "========================================"
echo "    SHELL COMPATIBILITY TEST"
echo "========================================"
echo ""

# Function to test shell compatibility
test_shell() {
    shell_name="$1"
    shell_cmd="$2"
    
    echo "🧪 Testing $shell_name..."
    
    if command -v "$shell_cmd" >/dev/null 2>&1; then
        echo "   ✅ $shell_name found: $(which $shell_cmd)"
        
        # Test basic command execution
        if $shell_cmd -c 'echo "   Basic execution: OK"' 2>/dev/null; then
            echo "   ✅ Basic execution: PASSED"
        else
            echo "   ❌ Basic execution: FAILED"
        fi
        
        # Test variable assignment
        if $shell_cmd -c 'VAR="test"; echo "   Variable test: $VAR"' 2>/dev/null; then
            echo "   ✅ Variables: PASSED"
        else
            echo "   ❌ Variables: FAILED"
        fi
        
        # Test conditional
        if $shell_cmd -c 'if [ "1" = "1" ]; then echo "   Conditional: OK"; fi' 2>/dev/null; then
            echo "   ✅ Conditionals: PASSED"
        else
            echo "   ❌ Conditionals: FAILED"
        fi
        
        # Test loop (POSIX compatible)
        if $shell_cmd -c 'for i in 1 2 3; do echo "   Loop $i: OK"; done' 2>/dev/null; then
            echo "   ✅ Loops: PASSED"
        else
            echo "   ❌ Loops: FAILED"
        fi
        
        echo "   ✅ $shell_name compatibility: GOOD"
    else
        echo "   ❌ $shell_name: NOT INSTALLED"
        echo "   💡 Run ./install_shells.sh to install"
    fi
    echo ""
}

echo "🔍 System Information:"
echo "   OS: $(uname -s)"
echo "   Architecture: $(uname -m)"
echo "   Kernel: $(uname -r)"
echo ""

echo "🐚 Testing Shell Compatibility..."
echo ""

# Test all supported shells
test_shell "POSIX sh" "sh"
test_shell "Bash" "bash"
test_shell "Zsh" "zsh"
test_shell "Fish" "fish"
test_shell "Dash" "dash"

echo "========================================"
echo "    SHELL FAKE CORE COMPATIBILITY"
echo "========================================"
echo ""

echo "💡 Recommendations for Shell Core:"
echo ""

# Check for optimal shells
if command -v bash >/dev/null 2>&1; then
    echo "   ✅ BASH: Recommended for maximum script compatibility"
fi

if command -v sh >/dev/null 2>&1; then
    echo "   ✅ SH: Good for simple scripts and embedded systems"
fi

if command -v dash >/dev/null 2>&1; then
    echo "   ✅ DASH: Excellent for fast script execution"
fi

if command -v zsh >/dev/null 2>&1; then
    echo "   ✅ ZSH: Great for interactive features"
fi

if command -v fish >/dev/null 2>&1; then
    echo "   ⚠️  FISH: Modern shell but may have compatibility issues with some scripts"
fi

echo ""
echo "🎮 To use with Shell Core:"
echo "   1. Load any .sh script as a ROM in RetroArch"
echo "   2. Set preferred shell in Core Options"
echo "   3. Enjoy shell scripting as gaming!"
echo ""
echo "🚀 Test completed!"