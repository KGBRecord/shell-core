#!/bin/bash
# System Monitoring Dashboard
# A comprehensive system monitoring script

clear
echo "╔══════════════════════════════════════════════════════════════════════════════════════╗"
echo "║                            🖥️  SYSTEM MONITORING DASHBOARD                            ║"
echo "╚══════════════════════════════════════════════════════════════════════════════════════╝"
echo ""

# Function to get colored output
print_section() {
    echo "┌─ $1 ─────────────────────────────────────────────────────────────────────────────────"
}

print_section "📊 SYSTEM INFORMATION"
echo "🖥️  Hostname: $(hostname)"
echo "⚙️   OS: $(uname -s)"
echo "🔧 Kernel: $(uname -r)"
echo "🏗️  Architecture: $(uname -m)"
echo "⏰ Current Time: $(date)"
echo ""

print_section "💾 MEMORY USAGE"
if command -v free >/dev/null 2>&1; then
    free -h
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Memory Pressure:"
    vm_stat | head -5
else
    echo "Memory information not available on this system"
fi
echo ""

print_section "💿 DISK USAGE"
echo "Root filesystem:"
df -h / | tail -1
echo ""
echo "All mounted filesystems:"
df -h | head -10
echo ""

print_section "🔄 SYSTEM PROCESSES"
echo "Top processes by CPU usage:"
if command -v ps >/dev/null 2>&1; then
    ps aux --sort=-%cpu | head -6
else
    echo "Process information not available"
fi
echo ""

print_section "🌐 NETWORK INFORMATION"
echo "Network interfaces:"
if command -v ip >/dev/null 2>&1; then
    ip addr show | grep inet
elif command -v ifconfig >/dev/null 2>&1; then
    ifconfig | grep inet
else
    echo "Network information not available"
fi
echo ""

print_section "🔍 SYSTEM LOAD"
if command -v uptime >/dev/null 2>&1; then
    uptime
fi

if command -v w >/dev/null 2>&1; then
    echo ""
    echo "Current users:"
    w
fi
echo ""

print_section "📈 SYSTEM RESOURCES"
echo "Available commands for detailed monitoring:"
echo "  • htop - Interactive process viewer"
echo "  • iotop - I/O usage by process"
echo "  • netstat - Network connections"
echo "  • lsof - Open files by process"
echo ""

echo "╔══════════════════════════════════════════════════════════════════════════════════════╗"
echo "║                           ✅ System monitoring complete!                              ║"
echo "╚══════════════════════════════════════════════════════════════════════════════════════╝"