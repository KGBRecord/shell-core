#!/bin/bash
# Setup ROM collection for Shell Core
# Creates a ready-to-use RetroArch Shell-Scripts library.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DEFAULT_TARGET="$HOME/RetroArch/ROMs/Shell-Scripts"
TARGET_DIR="${1:-$DEFAULT_TARGET}"

print_info() {
    echo "[INFO] $1"
}

print_ok() {
    echo "[OK]   $1"
}

print_warn() {
    echo "[WARN] $1"
}

copy_scripts() {
    local source_dir="$1"
    local dest_dir="$2"

    if [ ! -d "$source_dir" ]; then
        print_warn "Source directory not found: $source_dir"
        return
    fi

    mkdir -p "$dest_dir"
    cp "$source_dir"/*.sh "$dest_dir"/
    chmod +x "$dest_dir"/*.sh
    print_ok "Copied scripts to $dest_dir"
}

print_info "Shell Core ROM collection setup"
print_info "Project root: $PROJECT_ROOT"
print_info "Target ROM directory: $TARGET_DIR"
echo

mkdir -p "$TARGET_DIR"/Installers
mkdir -p "$TARGET_DIR"/Games
mkdir -p "$TARGET_DIR"/Utilities
mkdir -p "$TARGET_DIR"/System

copy_scripts "$PROJECT_ROOT/scripts/installers" "$TARGET_DIR/Installers"
copy_scripts "$PROJECT_ROOT/scripts/examples" "$TARGET_DIR/Games"

print_info "Moving utility scripts into Utilities category..."
for utility in system_info.sh system_monitor.sh file_manager.sh network_utils.sh; do
    if [ -f "$TARGET_DIR/Games/$utility" ]; then
        mv "$TARGET_DIR/Games/$utility" "$TARGET_DIR/Utilities/"
    fi
done
print_ok "Utilities organized"

print_info "Creating starter system scripts..."
cat > "$TARGET_DIR/System/maintenance.sh" <<'EOF'
#!/bin/bash
echo "=== System Maintenance ==="
echo "1) Disk usage"
echo "2) Running processes"
echo "3) Exit"
read -r -p "Choose option: " choice
case "$choice" in
  1) df -h ;;
  2) ps aux | head -n 20 ;;
  *) echo "Exit" ;;
esac
read -r -p "Press Enter to continue..."
EOF

cat > "$TARGET_DIR/System/monitoring.sh" <<'EOF'
#!/bin/bash
echo "=== Quick Monitoring ==="
echo "Hostname: $(hostname)"
echo "Uptime: $(uptime)"
echo "Memory:"
if command -v free >/dev/null 2>&1; then
  free -h
else
  vm_stat 2>/dev/null || echo "Memory stats command not available"
fi
read -r -p "Press Enter to continue..."
EOF

cat > "$TARGET_DIR/System/backup_scripts.sh" <<'EOF'
#!/bin/bash
echo "=== Backup Helper ==="
read -r -p "Source directory: " src
read -r -p "Destination directory: " dst
if [ -d "$src" ] && [ -d "$dst" ]; then
  cp -R "$src" "$dst/"
  echo "Backup completed"
else
  echo "Invalid source or destination"
fi
read -r -p "Press Enter to continue..."
EOF

chmod +x "$TARGET_DIR/System/"*.sh
print_ok "Starter system scripts created"

echo
print_ok "ROM collection is ready"
echo "You can now load content from: $TARGET_DIR"
