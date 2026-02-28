#!/bin/bash
# OpenClaw Agents - Documentation Repository Setup
# This script helps set up ClawdBot and provides instructions for Telegram bot configuration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        log_warning "Node.js is not installed. Please install Node.js 18+ to use ClawdBot."
        echo "Visit: https://nodejs.org/"
    fi
    
    # Check npm
    if ! command -v npm &> /dev/null; then
        log_warning "npm is not installed. Please install npm."
    fi
    
    # Check ClawdBot
    if ! command -v clawdbot &> /dev/null; then
        log_warning "ClawdBot is not installed."
        echo ""
        echo "To install ClawdBot, run:"
        echo "  npm install -g clawdbot"
        echo ""
        read -p "Would you like to install ClawdBot now? (y/n): " install_clawd
        if [ "$install_clawd" = "y" ] || [ "$install_clawd" = "Y" ]; then
            install_clawdbot
        fi
    else
        log_success "ClawdBot is installed: $(clawdbot --version)"
    fi
}

# Install ClawdBot
install_clawdbot() {
    log_info "Installing ClawdBot..."
    
    if command -v npm &> /dev/null; then
        npm install -g clawdbot
        
        if command -v clawdbot &> /dev/null; then
            log_success "ClawdBot installed successfully"
            
            # Initialize ClawdBot
            log_info "Initializing ClawdBot..."
            clawdbot setup
        else
            log_error "Failed to install ClawdBot"
            exit 1
        fi
    else
        log_error "npm is required to install ClawdBot"
        exit 1
    fi
}

# Display Telegram bot setup instructions
show_telegram_setup() {
    echo ""
    echo "================================"
    echo "Telegram Bot Setup Instructions"
    echo "================================"
    echo ""
    echo "This repository contains DOCUMENTATION ONLY for setting up Telegram bots."
    echo "No executable code is included - just instructions and guides."
    echo ""
    echo "📚 Documentation Structure:"
    echo "  • telegram-setup/TELEGRAM_BOT_SETUP.md - Complete setup guide"
    echo "  • telegram-setup/BOT_CREATION.md - BotFather tutorial"
    echo "  • telegram-setup/CLAWDBOT_CONNECTION.md - Provider configuration"
    echo "  • telegram-setup/EXISTING_BOTS.md - Current bot configurations"
    echo ""
    echo "🤖 Quick Setup Steps:"
    echo ""
    echo "1. Create a Telegram bot:"
    echo "   • Open Telegram and message @BotFather"
    echo "   • Send /newbot and follow the prompts"
    echo "   • Save the bot token provided"
    echo ""
    echo "2. Add bot to ClawdBot:"
    echo "   clawdbot providers add \\"
    echo "     --provider telegram \\"
    echo "     --account mybotname \\"
    echo "     --token \"YOUR_BOT_TOKEN\""
    echo ""
    echo "3. Test the connection:"
    echo "   clawdbot message send \\"
    echo "     --provider telegram \\"
    echo "     --account mybotname \\"
    echo "     --to @channel \\"
    echo "     --message \"Hello!\""
    echo ""
}

# Show current bot status
check_current_bots() {
    if command -v clawdbot &> /dev/null; then
        echo ""
        echo "================================"
        echo "Current Bot Configuration"
        echo "================================"
        echo ""
        
        # Check if any Telegram bots are configured
        if clawdbot providers list 2>/dev/null | grep -q "Telegram"; then
            log_info "Found existing Telegram bots:"
            echo ""
            clawdbot providers list | grep "Telegram" || true
        else
            log_info "No Telegram bots configured yet."
        fi
    fi
}

# Setup monitoring (optional)
setup_monitoring() {
    echo ""
    echo "================================"
    echo "Monitoring Setup (Optional)"
    echo "================================"
    echo ""
    echo "Management scripts are available in the management/ directory:"
    echo "  • health-monitor.sh - Health monitoring"
    echo "  • auto-recovery.sh - Auto-recovery from failures"
    echo "  • monitoring-dashboard.sh - Status dashboard"
    echo "  • sandbox-setup.sh - Docker sandbox setup"
    echo ""
    
    # Make scripts executable
    if [ -d "management" ]; then
        chmod +x management/*.sh 2>/dev/null || true
        log_success "Management scripts are executable"
    fi
    
    echo "To set up automated monitoring (checks every 2 hours):"
    echo "  crontab -e"
    echo "  Add: 0 */2 * * * $(pwd)/management/health-monitor.sh"
    echo ""
}

# Print next steps
print_next_steps() {
    echo ""
    echo "================================"
    echo "✅ Setup Complete!"
    echo "================================"
    echo ""
    echo "📖 Next Steps:"
    echo ""
    echo "1. Read the documentation:"
    echo "   • Start with: telegram-setup/TELEGRAM_BOT_SETUP.md"
    echo "   • Bot creation: telegram-setup/BOT_CREATION.md"
    echo "   • Configuration: telegram-setup/CLAWDBOT_CONNECTION.md"
    echo ""
    echo "2. Create your Telegram bots:"
    echo "   • Visit @BotFather on Telegram"
    echo "   • Create bots for your needs (SMMA, support, monitoring, etc.)"
    echo ""
    echo "3. Configure ClawdBot:"
    echo "   • Add each bot using: clawdbot providers add"
    echo "   • Test connections with: clawdbot message send"
    echo ""
    echo "4. Set up monitoring (optional):"
    echo "   • Run: ./management/health-monitor.sh"
    echo "   • Configure cron jobs for automation"
    echo ""
    echo "📚 Full documentation available in this repository"
    echo "🔗 ClawdBot docs: https://docs.openclaw.ai/"
    echo "🤖 Telegram Bot API: https://core.telegram.org/bots"
    echo ""
}

# Main function
main() {
    clear
    echo ""
    echo "╔═══════════════════════════════════════════╗"
    echo "║   OpenClaw Agents - Documentation Setup   ║"
    echo "║                                           ║"
    echo "║   Telegram Bot Configuration Guide        ║"
    echo "╚═══════════════════════════════════════════╝"
    echo ""
    
    check_prerequisites
    show_telegram_setup
    check_current_bots
    setup_monitoring
    print_next_steps
    
    log_success "Documentation repository is ready!"
    echo ""
    echo "This repository contains instructions only - no running code."
    echo "All bot functionality is provided by ClawdBot's native Telegram provider."
    echo ""
}

# Run main function
main "$@"