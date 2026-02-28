#!/bin/bash
# SMMA Skill Setup Script

echo "==================================="
echo "SMMA Clawdbot Skill Setup"
echo "==================================="
echo ""

# Check if API key is already set
if [ -n "$GETLATE_API_KEY" ]; then
    echo "✓ GETLATE_API_KEY is already configured"
else
    echo "⚠️  GETLATE_API_KEY is not set"
    echo ""
    echo "To set up your GetLate API key:"
    echo ""
    echo "1. Get your API key from https://getlate.dev"
    echo ""
    echo "2. Add to your shell configuration:"
    echo "   echo 'export GETLATE_API_KEY=\"your_api_key_here\"' >> ~/.bashrc"
    echo ""
    echo "3. Reload your shell:"
    echo "   source ~/.bashrc"
    echo ""
    read -p "Would you like to set it up now? (y/n): " setup_now
    
    if [ "$setup_now" = "y" ] || [ "$setup_now" = "Y" ]; then
        read -p "Enter your GetLate API key: " api_key
        
        if [ -n "$api_key" ]; then
            # Detect shell
            if [ -n "$ZSH_VERSION" ]; then
                shell_config="$HOME/.zshrc"
            elif [ -n "$BASH_VERSION" ]; then
                shell_config="$HOME/.bashrc"
            else
                shell_config="$HOME/.bashrc"
            fi
            
            # Add to config
            echo "" >> "$shell_config"
            echo "# GetLate API for SMMA Clawdbot skill" >> "$shell_config"
            echo "export GETLATE_API_KEY=\"$api_key\"" >> "$shell_config"
            
            echo "✓ Added GETLATE_API_KEY to $shell_config"
            echo ""
            echo "Run this command to apply changes:"
            echo "  source $shell_config"
            
            # Also export for current session
            export GETLATE_API_KEY="$api_key"
            echo "✓ API key set for current session"
        fi
    fi
fi

echo ""
echo "Checking Python dependencies..."

# Check for required Python packages
python3 -c "import requests, dotenv, click, rich, tabulate" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "Installing required Python packages..."
    pip install requests python-dotenv click rich tabulate
else
    echo "✓ All Python dependencies installed"
fi

echo ""
echo "Setup complete! You can now use the SMMA skill:"
echo "  clawdbot smma profiles list"
echo "  clawdbot smma accounts connect twitter"
echo "  clawdbot smma post"
echo ""