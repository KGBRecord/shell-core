#!/bin/sh
# From-scratch shell installer for ultra-minimal systems.
# Goal: install as many usable shells as possible without package managers.

set -eu

PREFIX="${PREFIX:-/usr/local}"
BIN_DIR="$PREFIX/bin"
TMP_DIR="${TMPDIR:-/tmp}/shell-scratch-$$"

mkdir -p "$TMP_DIR"
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT INT TERM

say() { echo "[INFO] $1"; }
ok() { echo "[OK]   $1"; }
warn() { echo "[WARN] $1"; }
err() { echo "[ERR]  $1"; }

has_cmd() { command -v "$1" >/dev/null 2>&1; }

detect_jobs() {
    if has_cmd nproc; then
        nproc
    else
        echo 2
    fi
}

download() {
    url="$1"
    out="$2"

    if has_cmd curl; then
        curl -fsSL -o "$out" "$url"
    elif has_cmd wget; then
        wget -O "$out" "$url"
    elif has_cmd busybox; then
        busybox wget -O "$out" "$url"
    elif has_cmd fetch; then
        fetch -o "$out" "$url"
    else
        return 1
    fi
}

run_install() {
    if has_cmd sudo; then
        sudo "$@"
    else
        "$@"
    fi
}

ensure_prefix() {
    run_install mkdir -p "$BIN_DIR"
}

add_path_hint() {
    case ":$PATH:" in
        *":$BIN_DIR:"*) ;;
        *)
            warn "$BIN_DIR is not in PATH for current session."
            echo "Add this line to your profile:"
            echo "export PATH=\"$BIN_DIR:\$PATH\""
            ;;
    esac
}

build_shell() {
    name="$1"
    version="$2"
    archive_url="$3"
    archive_name="$4"
    src_dir="$5"
    conf_flags="$6"

    say "Building $name $version from source..."
    cd "$TMP_DIR"
    download "$archive_url" "$archive_name" || return 1

    case "$archive_name" in
        *.tar.gz|*.tgz) tar -xzf "$archive_name" ;;
        *.tar.xz) tar -xJf "$archive_name" ;;
        *) err "Unsupported archive format: $archive_name"; return 1 ;;
    esac

    cd "$src_dir"
    ./configure --prefix="$PREFIX" $conf_flags
    make -j"$(detect_jobs)"
    run_install make install
    ok "$name installed"
    return 0
}

install_static_bash() {
    arch="$(uname -m)"
    case "$arch" in
        x86_64|amd64) file_name="bash-linux-x86_64" ;;
        i386|i686) file_name="bash-linux-i386" ;;
        aarch64|arm64) file_name="bash-linux-aarch64" ;;
        armv7l|armv7) file_name="bash-linux-armv7" ;;
        *)
            warn "No static bash mapping for arch: $arch"
            return 1
            ;;
    esac

    url="https://github.com/robxu9/bash-static/releases/download/5.1.016-1.2.3/$file_name"
    out="$TMP_DIR/bash.static"

    say "Trying static Bash fallback..."
    download "$url" "$out" || return 1
    chmod +x "$out"
    ensure_prefix
    run_install cp "$out" "$BIN_DIR/bash"
    ok "Static bash installed at $BIN_DIR/bash"
    return 0
}

setup_compat_wrappers() {
    say "Creating compatibility wrappers..."
    ensure_prefix

    if has_cmd busybox; then
        base_cmd="busybox sh"
    elif has_cmd sh; then
        base_cmd="sh"
    else
        warn "No base shell found for wrappers."
        return 1
    fi

    for shell_name in zsh fish dash; do
        wrapper="$TMP_DIR/$shell_name"
        cat > "$wrapper" <<EOF
#!/bin/sh
echo "$shell_name is not available, using fallback shell"
exec $base_cmd "\$@"
EOF
        chmod +x "$wrapper"
        run_install cp "$wrapper" "$BIN_DIR/$shell_name"
    done

    if ! has_cmd bash; then
        wrapper="$TMP_DIR/bash"
        cat > "$wrapper" <<EOF
#!/bin/sh
exec $base_cmd "\$@"
EOF
        chmod +x "$wrapper"
        run_install cp "$wrapper" "$BIN_DIR/bash"
    fi

    ok "Compatibility wrappers created in $BIN_DIR"
    return 0
}

print_status() {
    echo
    echo "Installed shells status:"
    for s in sh bash zsh dash fish; do
        if command -v "$s" >/dev/null 2>&1; then
            echo "  + $s => $(command -v "$s")"
        else
            echo "  - $s => not found"
        fi
    done
    echo
}

main() {
    echo "========================================"
    echo " FROM-SCRATCH SHELL INSTALLER"
    echo "========================================"
    echo
    say "Target prefix: $PREFIX"
    say "Architecture: $(uname -m)"
    echo

    source_tools_ok=0
    if has_cmd make && (has_cmd gcc || has_cmd clang) && has_cmd tar && (has_cmd curl || has_cmd wget || has_cmd busybox || has_cmd fetch); then
        source_tools_ok=1
    fi

    installed_any=0

    if [ "$source_tools_ok" -eq 1 ]; then
        build_shell "bash" "5.2.21" "https://ftp.gnu.org/gnu/bash/bash-5.2.21.tar.gz" "bash.tar.gz" "bash-5.2.21" "--enable-job-control" && installed_any=1 || warn "Failed to build bash"
        build_shell "dash" "0.5.12" "http://gondor.apana.org.au/~herbert/dash/files/dash-0.5.12.tar.gz" "dash.tar.gz" "dash-0.5.12" "" && installed_any=1 || warn "Failed to build dash"
        build_shell "zsh" "5.9" "https://www.zsh.org/pub/zsh-5.9.tar.xz" "zsh.tar.xz" "zsh-5.9" "" && installed_any=1 || warn "Failed to build zsh"
    else
        warn "Not enough tools for full source build."
        warn "Need: make + (gcc/clang) + tar + downloader"
    fi

    if [ "$installed_any" -eq 0 ]; then
        install_static_bash && installed_any=1 || warn "Static bash fallback failed"
    fi

    setup_compat_wrappers || true
    add_path_hint
    print_status

    if [ "$installed_any" -eq 0 ]; then
        err "Could not install full shells from source/static on this host."
        err "Fallback wrappers were created (if a base sh exists)."
        exit 1
    fi

    ok "From-scratch install flow completed."
}

main "$@"
