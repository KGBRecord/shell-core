#!/bin/bash
# Hello World "Game"
# A simple introduction to shell script gaming

echo "============================================="
echo "    Welcome to Shell Script Gaming!"
echo "============================================="
echo ""
echo "This is your first shell script 'game'!"
echo "Every .sh file is now a playable 'ROM'!"
echo ""

# Simple animation
for i in {1..5}; do
    echo "Loading... [$i/5]"
    sleep 1
done

echo ""
echo "🎮 Game Features:"
echo "  - Pure shell script execution"
echo "  - No Java required!"
echo "  - Cross-platform compatibility"
echo "  - RetroArch integration"
echo ""

echo "Press any key to continue..."
read -n 1 -s

echo ""
echo "Game completed successfully!"
echo "Exit code will be: 0"
echo ""
echo "Try running other example scripts:"
echo "  - system_info.sh"
echo "  - interactive_menu.sh"
echo "  - simple_game.sh"
echo ""
echo "Happy shell scripting! 🚀"