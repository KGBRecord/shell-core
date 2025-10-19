#!/bin/bash
# System Information "Game"
# Displays system information as a game

echo "========================================"
echo "    SYSTEM INFORMATION EXPLORER"
echo "========================================"
echo ""

echo "🖥️  System Details:"
echo "   Hostname: $(hostname)"
echo "   OS: $(uname -s)"
echo "   Kernel: $(uname -r)"
echo "   Architecture: $(uname -m)"
echo ""

echo "⏰ Current Time:"
echo "   Date: $(date)"
echo "   Uptime: $(uptime | cut -d',' -f1 | cut -d' ' -f4-)"
echo ""

echo "💾 Memory Information:"
if command -v free >/dev/null 2>&1; then
    free -h | head -2
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "   Available: $(vm_stat | grep "Pages free" | awk '{print $3}' | tr -d '.')*4KB"
else
    echo "   Memory info not available on this system"
fi
echo ""

echo "💿 Disk Usage:"
df -h / | tail -1 | awk '{print "   Root: "$3" used, "$4" available ("$5" used)"}'
echo ""

echo "🌐 Network Information:"
if command -v ip >/dev/null 2>&1; then
    ip route | grep default | awk '{print "   Gateway: "$3}'
elif command -v route >/dev/null 2>&1; then
    route -n get default 2>/dev/null | grep gateway | awk '{print "   Gateway: "$2}'
else
    echo "   Network info not available"
fi
echo ""

echo "👤 User Information:"
echo "   Current user: $USER"
echo "   Home directory: $HOME"
echo "   Shell: $SHELL"
echo ""

echo "🔧 Environment:"
echo "   PATH has $(echo $PATH | tr ':' '\n' | wc -l) directories"
echo "   Shell variables: $(env | wc -l)"
echo ""

echo "Game completed! All system information displayed."
echo "This script demonstrates system monitoring capabilities."