#!/bin/bash
# Network Utilities Script
# Various network testing and diagnostic tools

show_main_menu() {
    clear
    echo "╔══════════════════════════════════════════════════════════════════════════════════════╗"
    echo "║                              🌐 NETWORK UTILITIES                                    ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "📡 Network Diagnostic and Testing Tools"
    echo ""
    echo "┌─ NETWORK TOOLS ───────────────────────────────────────────────────────────────────────"
    echo "│ 1) 🏓 Ping Test               │ 6) 🔍 DNS Lookup"
    echo "│ 2) 🌍 Speed Test              │ 7) 📊 Network Statistics"
    echo "│ 3) 🔗 Port Scanner            │ 8) 🔧 IP Configuration"
    echo "│ 4) 🗺️  Traceroute             │ 9) 📈 Bandwidth Monitor"
    echo "│ 5) 💻 Local Network Scan      │ 0) 🚪 Exit"
    echo "└───────────────────────────────────────────────────────────────────────────────────────"
    echo ""
    echo -n "Choose tool (0-9): "
}

ping_test() {
    echo ""
    echo "🏓 PING TEST"
    echo "Test connectivity to a host"
    echo ""
    echo "Common targets:"
    echo "  • google.com"
    echo "  • 8.8.8.8 (Google DNS)"
    echo "  • 1.1.1.1 (Cloudflare DNS)"
    echo ""
    echo -n "Enter host to ping: "
    read host
    
    if [ -z "$host" ]; then
        echo "❌ No host provided"
        read -p "Press Enter to continue..."
        return
    fi
    
    echo ""
    echo "Pinging $host (Press Ctrl+C to stop)..."
    echo ""
    
    if command -v ping >/dev/null 2>&1; then
        # Different ping syntax for different systems
        if [[ "$OSTYPE" == "darwin"* ]]; then
            ping -c 5 "$host"
        else
            ping -c 5 "$host"
        fi
    else
        echo "❌ Ping command not available"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

speed_test() {
    echo ""
    echo "🌍 INTERNET SPEED TEST"
    echo "Testing download speed using curl..."
    echo ""
    
    # Test download speed using a known fast server
    test_url="http://speedtest.ftp.otenet.gr/files/test1Mb.db"
    
    echo "Downloading 1MB test file..."
    echo ""
    
    if command -v curl >/dev/null 2>&1; then
        start_time=$(date +%s.%N)
        curl -o /tmp/speedtest.tmp -w "Downloaded: %{size_download} bytes\nTime: %{time_total}s\nSpeed: %{speed_download} bytes/s\n" "$test_url" 2>/dev/null
        rm -f /tmp/speedtest.tmp
    elif command -v wget >/dev/null 2>&1; then
        wget -O /tmp/speedtest.tmp "$test_url"
        rm -f /tmp/speedtest.tmp
    else
        echo "❌ Neither curl nor wget available for speed test"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

port_scanner() {
    echo ""
    echo "🔗 PORT SCANNER"
    echo "Scan common ports on a host"
    echo ""
    echo -n "Enter host to scan: "
    read host
    
    if [ -z "$host" ]; then
        echo "❌ No host provided"
        read -p "Press Enter to continue..."
        return
    fi
    
    echo ""
    echo "Scanning common ports on $host..."
    echo ""
    
    # Common ports to check
    ports=(22 23 25 53 80 110 143 443 993 995)
    
    for port in "${ports[@]}"; do
        if command -v nc >/dev/null 2>&1; then
            if nc -z -w1 "$host" "$port" 2>/dev/null; then
                echo "✅ Port $port: OPEN"
            else
                echo "❌ Port $port: CLOSED"
            fi
        elif command -v telnet >/dev/null 2>&1; then
            # Fallback to telnet (less reliable)
            timeout 1 telnet "$host" "$port" 2>&1 | grep -q "Connected" && echo "✅ Port $port: OPEN" || echo "❌ Port $port: CLOSED"
        else
            echo "❌ No port scanning tools available (nc, telnet)"
            break
        fi
    done
    
    echo ""
    read -p "Press Enter to continue..."
}

traceroute_test() {
    echo ""
    echo "🗺️  TRACEROUTE"
    echo "Trace the path packets take to reach a destination"
    echo ""
    echo -n "Enter destination host: "
    read host
    
    if [ -z "$host" ]; then
        echo "❌ No host provided"
        read -p "Press Enter to continue..."
        return
    fi
    
    echo ""
    echo "Tracing route to $host..."
    echo ""
    
    if command -v traceroute >/dev/null 2>&1; then
        traceroute "$host"
    elif command -v tracert >/dev/null 2>&1; then
        tracert "$host"
    else
        echo "❌ Traceroute command not available"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

network_scan() {
    echo ""
    echo "💻 LOCAL NETWORK SCAN"
    echo "Discover devices on local network"
    echo ""
    
    # Get local network range
    if command -v ip >/dev/null 2>&1; then
        local_ip=$(ip route get 8.8.8.8 | awk '{print $7; exit}')
        network=$(echo "$local_ip" | cut -d. -f1-3).0/24
    elif command -v ifconfig >/dev/null 2>&1; then
        local_ip=$(ifconfig | grep 'inet ' | grep -v 127.0.0.1 | head -1 | awk '{print $2}')
        network=$(echo "$local_ip" | cut -d. -f1-3).0/24
    else
        echo "❌ Cannot determine local network"
        read -p "Press Enter to continue..."
        return
    fi
    
    echo "Local IP: $local_ip"
    echo "Scanning network: $network"
    echo ""
    
    if command -v nmap >/dev/null 2>&1; then
        nmap -sn "$network"
    elif command -v ping >/dev/null 2>&1; then
        # Fallback: ping sweep
        base=$(echo "$local_ip" | cut -d. -f1-3)
        echo "Performing ping sweep..."
        for i in {1..254}; do
            ip="$base.$i"
            if ping -c 1 -W 1 "$ip" >/dev/null 2>&1; then
                echo "✅ $ip is alive"
            fi
        done
    else
        echo "❌ No network scanning tools available"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

dns_lookup() {
    echo ""
    echo "🔍 DNS LOOKUP"
    echo "Perform DNS queries"
    echo ""
    echo -n "Enter domain name: "
    read domain
    
    if [ -z "$domain" ]; then
        echo "❌ No domain provided"
        read -p "Press Enter to continue..."
        return
    fi
    
    echo ""
    echo "DNS information for $domain:"
    echo ""
    
    if command -v dig >/dev/null 2>&1; then
        echo "A Records:"
        dig +short "$domain" A
        echo ""
        echo "MX Records:"
        dig +short "$domain" MX
        echo ""
        echo "NS Records:"
        dig +short "$domain" NS
    elif command -v nslookup >/dev/null 2>&1; then
        nslookup "$domain"
    elif command -v host >/dev/null 2>&1; then
        host "$domain"
    else
        echo "❌ No DNS lookup tools available"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

network_stats() {
    echo ""
    echo "📊 NETWORK STATISTICS"
    echo ""
    
    echo "Network Interfaces:"
    if command -v ip >/dev/null 2>&1; then
        ip addr show
    elif command -v ifconfig >/dev/null 2>&1; then
        ifconfig
    fi
    
    echo ""
    echo "Routing Table:"
    if command -v ip >/dev/null 2>&1; then
        ip route show
    elif command -v route >/dev/null 2>&1; then
        route -n
    fi
    
    echo ""
    echo "Active Connections:"
    if command -v ss >/dev/null 2>&1; then
        ss -tuln
    elif command -v netstat >/dev/null 2>&1; then
        netstat -tuln
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

ip_config() {
    echo ""
    echo "🔧 IP CONFIGURATION"
    echo ""
    
    echo "Current IP Configuration:"
    if command -v ip >/dev/null 2>&1; then
        echo "IPv4 addresses:"
        ip -4 addr show
        echo ""
        echo "IPv6 addresses:"
        ip -6 addr show
    elif command -v ifconfig >/dev/null 2>&1; then
        ifconfig
    fi
    
    echo ""
    echo "Default Gateway:"
    if command -v ip >/dev/null 2>&1; then
        ip route | grep default
    elif command -v route >/dev/null 2>&1; then
        route -n | grep '^0.0.0.0'
    fi
    
    echo ""
    echo "DNS Servers:"
    if [ -f /etc/resolv.conf ]; then
        grep nameserver /etc/resolv.conf
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

bandwidth_monitor() {
    echo ""
    echo "📈 BANDWIDTH MONITOR"
    echo "Monitor network interface traffic"
    echo ""
    
    if command -v vnstat >/dev/null 2>&1; then
        vnstat
    elif command -v iftop >/dev/null 2>&1; then
        echo "Starting iftop (Press 'q' to quit)..."
        sudo iftop
    else
        echo "Basic network statistics:"
        if [ -f /proc/net/dev ]; then
            cat /proc/net/dev
        else
            echo "❌ Network statistics not available"
        fi
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

# Main loop
while true; do
    show_main_menu
    read choice
    
    case $choice in
        1) ping_test ;;
        2) speed_test ;;
        3) port_scanner ;;
        4) traceroute_test ;;
        5) network_scan ;;
        6) dns_lookup ;;
        7) network_stats ;;
        8) ip_config ;;
        9) bandwidth_monitor ;;
        0) 
            echo ""
            echo "👋 Thanks for using Network Utilities!"
            exit 0
            ;;
        *)
            echo ""
            echo "❌ Invalid option: $choice"
            read -p "Press Enter to continue..."
            ;;
    esac
done