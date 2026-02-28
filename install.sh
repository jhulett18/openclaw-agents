#!/bin/bash
# OpenClaw Agents Installer
# One-click installation script for all OpenClaw agents

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
    
    # Check Python
    if ! command -v python3 &> /dev/null; then
        log_error "Python 3 is not installed. Please install Python 3.8 or higher."
        exit 1
    fi
    
    # Check pip
    if ! command -v pip3 &> /dev/null && ! command -v pip &> /dev/null; then
        log_error "pip is not installed. Please install pip."
        exit 1
    fi
    
    # Check ClawdBot
    if ! command -v clawdbot &> /dev/null; then
        log_warning "ClawdBot is not installed. Installing..."
        install_clawdbot
    fi
    
    log_success "Prerequisites check completed"
}

# Install ClawdBot if not present
install_clawdbot() {
    log_info "Installing ClawdBot..."
    
    # Check if npm is available
    if command -v npm &> /dev/null; then
        npm install -g @anthropic/clawdbot
    else
        log_error "npm is not installed. Please install Node.js and npm first."
        exit 1
    fi
    
    if command -v clawdbot &> /dev/null; then
        log_success "ClawdBot installed successfully"
    else
        log_error "Failed to install ClawdBot"
        exit 1
    fi
}

# Install Python dependencies
install_python_deps() {
    log_info "Installing Python dependencies..."
    
    # Check if virtual environment should be used
    if [ "$USE_VENV" = "true" ]; then
        log_info "Creating virtual environment..."
        python3 -m venv venv
        source venv/bin/activate
    fi
    
    # Install SMMA dependencies
    if [ -f "skills/smma/requirements.txt" ]; then
        pip install -r skills/smma/requirements.txt
        log_success "Python dependencies installed"
    else
        log_warning "requirements.txt not found, skipping Python dependencies"
    fi
}

# Install SMMA skill
install_smma_skill() {
    log_info "Installing SMMA skill..."
    
    # Make scripts executable
    chmod +x skills/smma/smma
    chmod +x skills/smma/smma.py
    chmod +x skills/smma/setup.sh
    
    # Register with ClawdBot
    SKILL_PATH="$(pwd)/skills/smma"
    clawdbot mcp add smma "$SKILL_PATH" || {
        log_warning "Failed to register with clawdbot mcp, trying alternative method..."
        # Alternative installation method if mcp is not available
        mkdir -p ~/.clawdbot/skills/
        cp -r skills/smma ~/.clawdbot/skills/
        log_info "Copied skill to ~/.clawdbot/skills/"
    }
    
    log_success "SMMA skill installed"
}

# Setup environment variables
setup_environment() {
    log_info "Setting up environment variables..."
    
    # Check if GETLATE_API_KEY is already set
    if [ -z "$GETLATE_API_KEY" ]; then
        echo ""
        echo "================================"
        echo "GetLate API Key Setup"
        echo "================================"
        echo "To use the SMMA bot, you need a GetLate API key."
        echo "Get your API key from: https://getlate.dev"
        echo ""
        read -p "Enter your GetLate API key (or press Enter to skip): " api_key
        
        if [ -n "$api_key" ]; then
            # Add to current session
            export GETLATE_API_KEY="$api_key"
            
            # Add to bashrc
            echo "" >> ~/.bashrc
            echo "# GetLate API Key for OpenClaw SMMA" >> ~/.bashrc
            echo "export GETLATE_API_KEY=\"$api_key\"" >> ~/.bashrc
            
            # Also add to .env file
            echo "GETLATE_API_KEY=$api_key" > .env
            
            log_success "API key configured"
        else
            log_warning "API key not set. You'll need to set GETLATE_API_KEY environment variable later."
        fi
    else
        log_success "GETLATE_API_KEY already configured"
    fi
}

# Setup monitoring
setup_monitoring() {
    log_info "Setting up monitoring scripts..."
    
    # Make management scripts executable
    chmod +x management/*.sh
    
    echo ""
    echo "================================"
    echo "Monitoring Setup (Optional)"
    echo "================================"
    echo "Would you like to set up automated health monitoring?"
    echo "This will check ClawdBot health every 2 hours and auto-recover from failures."
    echo ""
    read -p "Setup monitoring? (y/n): " setup_monitor
    
    if [ "$setup_monitor" = "y" ] || [ "$setup_monitor" = "Y" ]; then
        # Get absolute path to scripts
        MONITOR_PATH="$(pwd)/management/health-monitor.sh"
        RECOVERY_PATH="$(pwd)/management/auto-recovery.sh"
        
        # Add to crontab
        (crontab -l 2>/dev/null; echo "0 */2 * * * $MONITOR_PATH") | crontab -
        (crontab -l 2>/dev/null; echo "30 */2 * * * $RECOVERY_PATH --full") | crontab -
        
        log_success "Monitoring scheduled (runs every 2 hours)"
        log_info "View cron jobs with: crontab -l"
    else
        log_info "Monitoring setup skipped"
    fi
}

# Setup Docker sandbox (optional)
setup_sandbox() {
    echo ""
    echo "================================"
    echo "Docker Sandbox Setup (Optional)"
    echo "================================"
    echo "Would you like to set up Docker sandboxing for secure execution?"
    echo ""
    read -p "Setup Docker sandbox? (y/n): " setup_docker
    
    if [ "$setup_docker" = "y" ] || [ "$setup_docker" = "Y" ]; then
        if command -v docker &> /dev/null; then
            ./management/sandbox-setup.sh
            log_success "Docker sandbox configured"
        else
            log_warning "Docker is not installed. Skipping sandbox setup."
            log_info "Install Docker and run: ./management/sandbox-setup.sh"
        fi
    else
        log_info "Docker sandbox setup skipped"
    fi
}

# Verify installation
verify_installation() {
    log_info "Verifying installation..."
    
    # Check if clawdbot command works
    if clawdbot smma --help &> /dev/null; then
        log_success "SMMA skill is accessible"
    else
        log_warning "SMMA skill may not be properly installed"
    fi
    
    # Check Python dependencies
    python3 -c "import requests, click, rich, dotenv, tabulate" 2>/dev/null && {
        log_success "Python dependencies verified"
    } || {
        log_warning "Some Python dependencies may be missing"
    }
}

# Print usage instructions
print_usage() {
    echo ""
    echo "================================"
    echo "Installation Complete!"
    echo "================================"
    echo ""
    echo "Quick Start Guide:"
    echo ""
    echo "1. Set your API key (if not done):"
    echo "   export GETLATE_API_KEY=\"your_api_key_here\""
    echo ""
    echo "2. Create a profile:"
    echo "   clawdbot smma profiles create \"My Brand\""
    echo ""
    echo "3. Connect social media accounts:"
    echo "   clawdbot smma accounts connect twitter"
    echo "   clawdbot smma accounts connect instagram"
    echo ""
    echo "4. Create your first post:"
    echo "   clawdbot smma post"
    echo ""
    echo "For more information, see README.md"
    echo ""
    echo "Management Tools:"
    echo "- Health check: ./management/health-monitor.sh"
    echo "- Dashboard: ./management/monitoring-dashboard.sh"
    echo "- Auto-recovery: ./management/auto-recovery.sh"
    echo ""
}

# Main installation flow
main() {
    echo ""
    echo "================================"
    echo "OpenClaw Agents Installer"
    echo "================================"
    echo ""
    
    # Check if we should use virtual environment
    if [ "$1" = "--venv" ]; then
        USE_VENV=true
        log_info "Using virtual environment"
    fi
    
    check_prerequisites
    install_python_deps
    install_smma_skill
    setup_environment
    setup_monitoring
    setup_sandbox
    verify_installation
    print_usage
    
    log_success "Installation completed successfully!"
}

# Run main function
main "$@"