#!/bin/bash
# File Manager Script
# A text-based file management interface

current_dir="$PWD"
show_hidden=false

show_menu() {
    clear
    echo "╔══════════════════════════════════════════════════════════════════════════════════════╗"
    echo "║                              📁 SHELL FILE MANAGER                                   ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "📍 Current Directory: $current_dir"
    echo ""
    
    # List directory contents
    if [ "$show_hidden" = true ]; then
        ls -la "$current_dir"
    else
        ls -l "$current_dir"
    fi
    
    echo ""
    echo "┌─ COMMANDS ────────────────────────────────────────────────────────────────────────────"
    echo "│ 1) 📂 Change directory        │ 6) 🗑️  Delete file/directory"
    echo "│ 2) 📄 Create file             │ 7) 🔍 Search files"
    echo "│ 3) 📁 Create directory        │ 8) 👁️  Toggle hidden files"
    echo "│ 4) 📋 Copy file/directory     │ 9) 📊 Disk usage"
    echo "│ 5) ✂️  Move/rename            │ 0) 🚪 Exit"
    echo "└───────────────────────────────────────────────────────────────────────────────────────"
    echo ""
    echo -n "Choose option (0-9): "
}

change_directory() {
    echo ""
    echo "📂 CHANGE DIRECTORY"
    echo "Current: $current_dir"
    echo ""
    echo "Options:"
    echo "  . = Stay in current directory"
    echo " .. = Go to parent directory"
    echo "  ~ = Go to home directory"
    echo "  / = Go to root directory"
    echo ""
    echo -n "Enter path: "
    read new_dir
    
    if [ -z "$new_dir" ]; then
        return
    fi
    
    case "$new_dir" in
        ".")
            # Stay in current directory
            ;;
        "..")
            current_dir="$(dirname "$current_dir")"
            ;;
        "~")
            current_dir="$HOME"
            ;;
        "/")
            current_dir="/"
            ;;
        /*)
            # Absolute path
            if [ -d "$new_dir" ]; then
                current_dir="$new_dir"
            else
                echo "❌ Directory not found: $new_dir"
                read -p "Press Enter to continue..."
            fi
            ;;
        *)
            # Relative path
            target="$current_dir/$new_dir"
            if [ -d "$target" ]; then
                current_dir="$target"
            else
                echo "❌ Directory not found: $target"
                read -p "Press Enter to continue..."
            fi
            ;;
    esac
}

create_file() {
    echo ""
    echo "📄 CREATE FILE"
    echo -n "Enter filename: "
    read filename
    
    if [ -z "$filename" ]; then
        echo "❌ No filename provided"
        read -p "Press Enter to continue..."
        return
    fi
    
    filepath="$current_dir/$filename"
    
    if [ -f "$filepath" ]; then
        echo "⚠️  File already exists: $filename"
        echo -n "Overwrite? (y/n): "
        read confirm
        if [ "$confirm" != "y" ]; then
            return
        fi
    fi
    
    echo -n "Enter file content (empty for empty file): "
    read content
    
    echo "$content" > "$filepath"
    echo "✅ File created: $filename"
    read -p "Press Enter to continue..."
}

create_directory() {
    echo ""
    echo "📁 CREATE DIRECTORY"
    echo -n "Enter directory name: "
    read dirname
    
    if [ -z "$dirname" ]; then
        echo "❌ No directory name provided"
        read -p "Press Enter to continue..."
        return
    fi
    
    dirpath="$current_dir/$dirname"
    
    if [ -d "$dirpath" ]; then
        echo "❌ Directory already exists: $dirname"
        read -p "Press Enter to continue..."
        return
    fi
    
    mkdir "$dirpath"
    echo "✅ Directory created: $dirname"
    read -p "Press Enter to continue..."
}

copy_item() {
    echo ""
    echo "📋 COPY FILE/DIRECTORY"
    echo -n "Enter source path: "
    read source
    echo -n "Enter destination path: "
    read dest
    
    if [ -z "$source" ] || [ -z "$dest" ]; then
        echo "❌ Source and destination required"
        read -p "Press Enter to continue..."
        return
    fi
    
    # Add current directory if relative paths
    if [[ "$source" != /* ]]; then
        source="$current_dir/$source"
    fi
    if [[ "$dest" != /* ]]; then
        dest="$current_dir/$dest"
    fi
    
    if [ ! -e "$source" ]; then
        echo "❌ Source not found: $source"
        read -p "Press Enter to continue..."
        return
    fi
    
    cp -r "$source" "$dest"
    echo "✅ Copied: $source → $dest"
    read -p "Press Enter to continue..."
}

move_item() {
    echo ""
    echo "✂️  MOVE/RENAME"
    echo -n "Enter source path: "
    read source
    echo -n "Enter destination path: "
    read dest
    
    if [ -z "$source" ] || [ -z "$dest" ]; then
        echo "❌ Source and destination required"
        read -p "Press Enter to continue..."
        return
    fi
    
    # Add current directory if relative paths
    if [[ "$source" != /* ]]; then
        source="$current_dir/$source"
    fi
    if [[ "$dest" != /* ]]; then
        dest="$current_dir/$dest"
    fi
    
    if [ ! -e "$source" ]; then
        echo "❌ Source not found: $source"
        read -p "Press Enter to continue..."
        return
    fi
    
    mv "$source" "$dest"
    echo "✅ Moved: $source → $dest"
    read -p "Press Enter to continue..."
}

delete_item() {
    echo ""
    echo "🗑️  DELETE FILE/DIRECTORY"
    echo "⚠️  WARNING: This action cannot be undone!"
    echo -n "Enter path to delete: "
    read target
    
    if [ -z "$target" ]; then
        echo "❌ No path provided"
        read -p "Press Enter to continue..."
        return
    fi
    
    # Add current directory if relative path
    if [[ "$target" != /* ]]; then
        target="$current_dir/$target"
    fi
    
    if [ ! -e "$target" ]; then
        echo "❌ Path not found: $target"
        read -p "Press Enter to continue..."
        return
    fi
    
    echo "About to delete: $target"
    echo -n "Are you sure? (type 'yes' to confirm): "
    read confirm
    
    if [ "$confirm" = "yes" ]; then
        rm -rf "$target"
        echo "✅ Deleted: $target"
    else
        echo "❌ Delete cancelled"
    fi
    read -p "Press Enter to continue..."
}

search_files() {
    echo ""
    echo "🔍 SEARCH FILES"
    echo -n "Enter search pattern: "
    read pattern
    
    if [ -z "$pattern" ]; then
        echo "❌ No pattern provided"
        read -p "Press Enter to continue..."
        return
    fi
    
    echo ""
    echo "Searching for '$pattern' in $current_dir..."
    echo ""
    find "$current_dir" -name "*$pattern*" -type f 2>/dev/null
    echo ""
    read -p "Press Enter to continue..."
}

toggle_hidden() {
    if [ "$show_hidden" = true ]; then
        show_hidden=false
        echo "Hidden files: OFF"
    else
        show_hidden=true
        echo "Hidden files: ON"
    fi
    sleep 1
}

disk_usage() {
    echo ""
    echo "📊 DISK USAGE"
    echo ""
    echo "Current directory usage:"
    du -sh "$current_dir"/* 2>/dev/null | sort -hr | head -10
    echo ""
    echo "Total directory size:"
    du -sh "$current_dir"
    echo ""
    read -p "Press Enter to continue..."
}

# Main loop
while true; do
    show_menu
    read choice
    
    case $choice in
        1) change_directory ;;
        2) create_file ;;
        3) create_directory ;;
        4) copy_item ;;
        5) move_item ;;
        6) delete_item ;;
        7) search_files ;;
        8) toggle_hidden ;;
        9) disk_usage ;;
        0) 
            echo ""
            echo "👋 Thanks for using Shell File Manager!"
            exit 0
            ;;
        *)
            echo ""
            echo "❌ Invalid option: $choice"
            read -p "Press Enter to continue..."
            ;;
    esac
done