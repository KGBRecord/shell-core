#!/bin/bash
# Interactive Menu "Game"
# A simple menu-driven shell game

show_menu() {
    clear
    echo "========================================"
    echo "      INTERACTIVE SHELL GAME MENU"
    echo "========================================"
    echo ""
    echo "🎮 Game Options:"
    echo ""
    echo "  1) 🎲 Number Guessing Game"
    echo "  2) 🧮 Calculator"
    echo "  3) 📁 File Explorer"
    echo "  4) 🎨 ASCII Art Generator"
    echo "  5) ⏲️  Countdown Timer"
    echo "  6) 🔤 Word Scramble"
    echo "  7) 🌡️  System Monitor"
    echo "  8) 🚪 Exit Game"
    echo ""
    echo -n "Choose your adventure (1-8): "
}

number_guessing_game() {
    echo ""
    echo "🎲 NUMBER GUESSING GAME"
    echo "======================="
    
    target=$((RANDOM % 100 + 1))
    attempts=0
    
    echo "I'm thinking of a number between 1 and 100!"
    
    while true; do
        echo -n "Enter your guess: "
        read guess
        attempts=$((attempts + 1))
        
        if [[ $guess -eq $target ]]; then
            echo "🎉 Congratulations! You guessed it in $attempts attempts!"
            break
        elif [[ $guess -lt $target ]]; then
            echo "📈 Too low! Try higher."
        else
            echo "📉 Too high! Try lower."
        fi
    done
    
    echo "Press Enter to return to menu..."
    read
}

calculator() {
    echo ""
    echo "🧮 CALCULATOR"
    echo "============"
    
    echo -n "Enter first number: "
    read num1
    echo -n "Enter operation (+, -, *, /): "
    read op
    echo -n "Enter second number: "
    read num2
    
    case $op in
        +) result=$((num1 + num2)) ;;
        -) result=$((num1 - num2)) ;;
        \*) result=$((num1 * num2)) ;;
        /) 
            if [[ $num2 -eq 0 ]]; then
                echo "❌ Error: Division by zero!"
                echo "Press Enter to continue..."
                read
                return
            fi
            result=$((num1 / num2)) 
            ;;
        *) 
            echo "❌ Invalid operation!"
            echo "Press Enter to continue..."
            read
            return
            ;;
    esac
    
    echo "📊 Result: $num1 $op $num2 = $result"
    echo "Press Enter to return to menu..."
    read
}

file_explorer() {
    echo ""
    echo "📁 FILE EXPLORER"
    echo "==============="
    
    echo "Current directory: $(pwd)"
    echo ""
    echo "Contents:"
    ls -la
    
    echo ""
    echo "Disk usage:"
    du -sh * 2>/dev/null | head -10
    
    echo ""
    echo "Press Enter to return to menu..."
    read
}

ascii_art() {
    echo ""
    echo "🎨 ASCII ART GENERATOR"
    echo "====================="
    
    echo -n "Enter a word to make ASCII art: "
    read word
    
    echo ""
    echo "Your ASCII art:"
    
    # Simple ASCII art generator
    for char in $(echo "$word" | fold -w1); do
        case $char in
            A|a) echo " ▄▀█ " ;;
            B|b) echo " █▄▄ " ;;
            C|c) echo " █▀▀ " ;;
            D|d) echo " █▀▄ " ;;
            E|e) echo " █▀▀ " ;;
            F|f) echo " █▀▀ " ;;
            G|g) echo " █▀▀ " ;;
            H|h) echo " █ █ " ;;
            I|i) echo " █ " ;;
            J|j) echo "   █ " ;;
            *) echo " ▄▄▄ " ;;
        esac
    done | paste -s -d''
    
    echo ""
    echo "Press Enter to return to menu..."
    read
}

countdown_timer() {
    echo ""
    echo "⏲️  COUNTDOWN TIMER"
    echo "=================="
    
    echo -n "Enter countdown time in seconds: "
    read seconds
    
    if ! [[ "$seconds" =~ ^[0-9]+$ ]]; then
        echo "❌ Please enter a valid number!"
        echo "Press Enter to continue..."
        read
        return
    fi
    
    echo ""
    echo "Starting countdown..."
    
    for ((i=seconds; i>0; i--)); do
        echo -ne "\r⏰ Time remaining: $i seconds "
        sleep 1
    done
    
    echo ""
    echo "🔔 TIME'S UP! ⏰"
    echo ""
    echo "Press Enter to return to menu..."
    read
}

word_scramble() {
    echo ""
    echo "🔤 WORD SCRAMBLE"
    echo "==============="
    
    words=("computer" "keyboard" "monitor" "software" "program" "script" "shell" "terminal")
    word=${words[$RANDOM % ${#words[@]}]}
    scrambled=$(echo $word | fold -w1 | shuf | tr -d '\n')
    
    echo "Unscramble this word: $scrambled"
    echo ""
    echo -n "Your answer: "
    read answer
    
    if [[ "${answer,,}" == "$word" ]]; then
        echo "🎉 Correct! The word was '$word'"
    else
        echo "❌ Sorry! The correct word was '$word'"
    fi
    
    echo "Press Enter to return to menu..."
    read
}

system_monitor() {
    echo ""
    echo "🌡️  SYSTEM MONITOR"
    echo "=================="
    
    echo "⚡ CPU and Memory:"
    if command -v top >/dev/null 2>&1; then
        top -l 1 -n 0 | head -10
    else
        echo "CPU info not available"
    fi
    
    echo ""
    echo "💾 Memory Usage:"
    if command -v free >/dev/null 2>&1; then
        free -h
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        vm_stat | head -5
    fi
    
    echo ""
    echo "🌐 Network Connections:"
    if command -v netstat >/dev/null 2>&1; then
        netstat -an | head -10
    else
        echo "Network info not available"
    fi
    
    echo ""
    echo "Press Enter to return to menu..."
    read
}

# Main game loop
while true; do
    show_menu
    read choice
    
    case $choice in
        1) number_guessing_game ;;
        2) calculator ;;
        3) file_explorer ;;
        4) ascii_art ;;
        5) countdown_timer ;;
        6) word_scramble ;;
        7) system_monitor ;;
        8) 
            echo ""
            echo "🚪 Thanks for playing! Goodbye!"
            exit 0
            ;;
        *)
            echo ""
            echo "❌ Invalid choice! Please select 1-8."
            echo "Press Enter to continue..."
            read
            ;;
    esac
done