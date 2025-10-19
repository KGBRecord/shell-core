#!/bin/bash
# Simple Text Adventure Game
# A basic adventure game demonstrating shell scripting game mechanics

# Game state variables
player_health=100
player_gold=10
player_level=1
game_over=false

# Game functions
show_status() {
    echo ""
    echo "=================================="
    echo "     🏰 SHELL ADVENTURE GAME"
    echo "=================================="
    echo "Health: ❤️  $player_health/100"
    echo "Gold: 💰 $player_gold"
    echo "Level: ⭐ $player_level"
    echo "=================================="
    echo ""
}

intro() {
    clear
    echo "🏰 Welcome to the Shell Adventure Game!"
    echo "======================================="
    echo ""
    echo "You are a brave adventurer in a mystical land."
    echo "Your quest: Find the legendary Shell Scroll!"
    echo ""
    echo "Press Enter to begin your adventure..."
    read
}

forest_encounter() {
    show_status
    echo "🌲 You enter a dark forest..."
    echo ""
    echo "As you walk through the trees, you hear rustling!"
    echo "A wild goblin appears! 👹"
    echo ""
    echo "What do you do?"
    echo "1) ⚔️  Fight the goblin"
    echo "2) 🏃 Run away"
    echo "3) 💰 Offer gold (costs 5 gold)"
    echo ""
    echo -n "Choose your action (1-3): "
    read choice
    
    case $choice in
        1)
            echo ""
            echo "⚔️  You draw your sword and fight!"
            damage=$((RANDOM % 30 + 10))
            player_health=$((player_health - damage))
            
            if [[ $player_health -le 0 ]]; then
                echo "💀 The goblin defeats you! Game Over!"
                game_over=true
                return
            fi
            
            echo "You defeat the goblin but take $damage damage!"
            gold_found=$((RANDOM % 15 + 5))
            player_gold=$((player_gold + gold_found))
            echo "💰 You find $gold_found gold pieces!"
            ;;
        2)
            echo ""
            echo "🏃 You run away safely!"
            echo "Sometimes discretion is the better part of valor."
            ;;
        3)
            if [[ $player_gold -ge 5 ]]; then
                echo ""
                echo "💰 You offer 5 gold to the goblin."
                echo "The goblin grins and lets you pass peacefully."
                player_gold=$((player_gold - 5))
                echo "🎁 The grateful goblin gives you a health potion!"
                player_health=$((player_health + 20))
                if [[ $player_health -gt 100 ]]; then
                    player_health=100
                fi
            else
                echo ""
                echo "💸 You don't have enough gold!"
                echo "The goblin attacks!"
                damage=$((RANDOM % 20 + 5))
                player_health=$((player_health - damage))
                echo "You take $damage damage!"
            fi
            ;;
        *)
            echo "Invalid choice! The goblin attacks while you hesitate!"
            damage=15
            player_health=$((player_health - damage))
            echo "You take $damage damage!"
            ;;
    esac
    
    echo ""
    echo "Press Enter to continue..."
    read
}

village_encounter() {
    show_status
    echo "🏘️  You arrive at a peaceful village..."
    echo ""
    echo "The villagers welcome you warmly!"
    echo "An old merchant approaches you."
    echo ""
    echo "Merchant: 'Welcome, traveler! What can I do for you?'"
    echo ""
    echo "1) 🛒 Buy health potion (10 gold)"
    echo "2) 🗣️  Ask about the Shell Scroll"
    echo "3) 💼 Work for gold (earn 5-15 gold)"
    echo "4) 🚶 Leave the village"
    echo ""
    echo -n "Choose your action (1-4): "
    read choice
    
    case $choice in
        1)
            if [[ $player_gold -ge 10 ]]; then
                echo ""
                echo "🛒 You buy a health potion for 10 gold."
                player_gold=$((player_gold - 10))
                player_health=$((player_health + 30))
                if [[ $player_health -gt 100 ]]; then
                    player_health=100
                fi
                echo "❤️  Your health is restored!"
            else
                echo ""
                echo "💸 You don't have enough gold!"
            fi
            ;;
        2)
            echo ""
            echo "🗣️  Merchant: 'Ah, the legendary Shell Scroll!'"
            echo "    'It's said to be hidden in the Crystal Cave,'"
            echo "    'guarded by an ancient Shell Dragon!'"
            echo "    'You'll need to be well-prepared, brave one.'"
            ;;
        3)
            echo ""
            echo "💼 You help the villagers with their daily tasks."
            work_gold=$((RANDOM % 11 + 5))
            player_gold=$((player_gold + work_gold))
            echo "💰 You earn $work_gold gold for your hard work!"
            
            # Chance to level up
            if [[ $((RANDOM % 3)) -eq 0 ]]; then
                player_level=$((player_level + 1))
                echo "⭐ Your experience grows! You reached level $player_level!"
            fi
            ;;
        4)
            echo ""
            echo "🚶 You thank the villagers and continue your journey."
            ;;
        *)
            echo "The merchant looks confused by your response."
            ;;
    esac
    
    echo ""
    echo "Press Enter to continue..."
    read
}

cave_encounter() {
    show_status
    echo "🕳️  You stand before the Crystal Cave..."
    echo ""
    echo "The cave entrance glows with mystical energy."
    echo "You can feel the presence of the Shell Dragon within!"
    echo ""
    echo "What do you do?"
    echo "1) ⚔️  Enter and fight the dragon"
    echo "2) 🧘 Meditate to gain strength first"
    echo "3) 🏃 Return to the village"
    echo ""
    echo -n "Choose your action (1-3): "
    read choice
    
    case $choice in
        1)
            echo ""
            echo "⚔️  You bravely enter the cave!"
            echo ""
            echo "🐉 The Shell Dragon emerges from the shadows!"
            echo "   'Who dares disturb my eternal slumber?'"
            echo ""
            
            # Boss fight
            dragon_health=50
            echo "🥊 BOSS FIGHT: Shell Dragon!"
            echo ""
            
            while [[ $dragon_health -gt 0 && $player_health -gt 0 ]]; do
                echo "Dragon Health: $dragon_health | Your Health: $player_health"
                echo "1) ⚔️  Attack  2) 🛡️  Defend  3) 🎯 Special Attack"
                echo -n "Your action: "
                read action
                
                case $action in
                    1)
                        damage=$((RANDOM % 20 + 5))
                        dragon_health=$((dragon_health - damage))
                        echo "You deal $damage damage!"
                        ;;
                    2)
                        echo "You defend and take reduced damage!"
                        dragon_damage=$((RANDOM % 10 + 5))
                        ;;
                    3)
                        if [[ $player_level -ge 2 ]]; then
                            damage=$((RANDOM % 30 + 10))
                            dragon_health=$((dragon_health - damage))
                            echo "💥 Special attack! You deal $damage damage!"
                        else
                            echo "You need to be level 2 for special attacks!"
                            damage=$((RANDOM % 15 + 3))
                            dragon_health=$((dragon_health - damage))
                            echo "Regular attack deals $damage damage!"
                        fi
                        ;;
                    *)
                        echo "Invalid action! You miss your turn!"
                        ;;
                esac
                
                if [[ $dragon_health -gt 0 ]]; then
                    if [[ $action -eq 2 ]]; then
                        player_health=$((player_health - dragon_damage))
                    else
                        dragon_damage=$((RANDOM % 25 + 10))
                        player_health=$((player_health - dragon_damage))
                    fi
                    echo "Dragon attacks for $dragon_damage damage!"
                fi
                
                echo ""
            done
            
            if [[ $player_health -le 0 ]]; then
                echo "💀 You have been defeated! Game Over!"
                game_over=true
                return
            else
                echo "🎉 You defeated the Shell Dragon!"
                echo ""
                echo "🏆 CONGRATULATIONS!"
                echo "You have found the legendary Shell Scroll!"
                echo "The scroll contains the ancient wisdom of shell scripting!"
                echo ""
                echo "💰 You also find a treasure chest with 100 gold!"
                player_gold=$((player_gold + 100))
                echo ""
                echo "🎮 GAME COMPLETED SUCCESSFULLY!"
                game_over=true
                return
            fi
            ;;
        2)
            echo ""
            echo "🧘 You sit and meditate outside the cave..."
            echo "Your inner strength grows!"
            player_health=$((player_health + 15))
            if [[ $player_health -gt 100 ]]; then
                player_health=100
            fi
            echo "❤️  Health restored!"
            
            if [[ $((RANDOM % 2)) -eq 0 ]]; then
                player_level=$((player_level + 1))
                echo "⭐ Your wisdom increases! Level up to $player_level!"
            fi
            ;;
        3)
            echo ""
            echo "🏃 You decide to retreat and prepare better."
            echo "Sometimes strategy is better than bravery!"
            ;;
        *)
            echo "You stand confused. The dragon senses your hesitation!"
            ;;
    esac
    
    echo ""
    echo "Press Enter to continue..."
    read
}

game_over_screen() {
    show_status
    echo "🎮 GAME OVER"
    echo "============"
    echo ""
    
    if [[ $player_health -le 0 ]]; then
        echo "💀 You have fallen in battle!"
        echo "   But your adventure will be remembered!"
    else
        echo "🏆 Victory is yours!"
        echo "   The Shell Scroll is now in your possession!"
        echo "   You have mastered the art of shell adventures!"
    fi
    
    echo ""
    echo "Final Stats:"
    echo "  Health: $player_health"
    echo "  Gold: $player_gold"
    echo "  Level: $player_level"
    echo ""
    echo "Thanks for playing the Shell Adventure Game!"
    echo "This demonstrates the power of shell script gaming!"
}

# Main game loop
intro

while [[ $game_over == false ]]; do
    show_status
    echo "🗺️  Where would you like to go?"
    echo ""
    echo "1) 🌲 Dark Forest"
    echo "2) 🏘️  Peaceful Village"
    echo "3) 🕳️  Crystal Cave"
    echo "4) 🚪 Quit Game"
    echo ""
    echo -n "Choose your destination (1-4): "
    read destination
    
    case $destination in
        1) forest_encounter ;;
        2) village_encounter ;;
        3) cave_encounter ;;
        4) 
            echo ""
            echo "Thanks for playing! Your adventure ends here."
            game_over=true
            ;;
        *)
            echo ""
            echo "❌ Invalid destination! Try again."
            echo "Press Enter to continue..."
            read
            ;;
    esac
    
    # Check if player health is too low
    if [[ $player_health -le 0 ]]; then
        game_over=true
    fi
done

game_over_screen