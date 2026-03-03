#!/bin/bash
# OpenClaw Agents - ClawdBot Infrastructure Setup
# Sets up ClawdBot gateway, systemd units, watchdog, and directory structure.

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAWDBOT_DIR="$HOME/.clawdbot"

check_prerequisites() {
    log_info "Checking prerequisites..."

    if ! command -v node &>/dev/null; then
        log_error "Node.js is not installed. Please install Node.js 18+."
        echo "  Visit: https://nodejs.org/"
        exit 1
    fi
    log_success "Node.js $(node --version)"

    if ! command -v npm &>/dev/null; then
        log_error "npm is not installed."
        exit 1
    fi
    log_success "npm $(npm --version)"

    if ! command -v clawdbot &>/dev/null; then
        log_warning "ClawdBot is not installed."
        read -p "Install ClawdBot now? (y/n): " install_choice
        if [[ "$install_choice" =~ ^[Yy]$ ]]; then
            npm install -g clawdbot
            log_success "ClawdBot installed: $(clawdbot --version)"
        else
            log_error "ClawdBot is required. Install with: npm install -g clawdbot"
            exit 1
        fi
    else
        log_success "ClawdBot $(clawdbot --version)"
    fi
}

create_directories() {
    log_info "Creating directory structure..."

    mkdir -p "$CLAWDBOT_DIR"/{agents,cron/runs,credentials,devices,identity,logs,media/inbound,sandboxes/{main,cici,smma},scripts,telegram,tokens}
    mkdir -p "$HOME/clawd"/{CiciCoder,RedditScanner,DashboardBot}
    mkdir -p "$HOME/openclaw-monitor/reports"

    log_success "Directory structure created"
}

install_scripts() {
    log_info "Installing management scripts..."

    cp "$SCRIPT_DIR/scripts/gateway-watchdog.sh" "$CLAWDBOT_DIR/scripts/"
    chmod +x "$CLAWDBOT_DIR/scripts/gateway-watchdog.sh"

    cp "$SCRIPT_DIR/scripts/docker-health-check.sh" "$CLAWDBOT_DIR/"
    chmod +x "$CLAWDBOT_DIR/docker-health-check.sh"

    log_success "Scripts installed to $CLAWDBOT_DIR/scripts/"
}

install_systemd() {
    log_info "Installing systemd user units..."

    SYSTEMD_DIR="$HOME/.config/systemd/user"
    mkdir -p "$SYSTEMD_DIR"

    cp "$SCRIPT_DIR/systemd/clawdbot-gateway.service" "$SYSTEMD_DIR/"
    cp "$SCRIPT_DIR/systemd/clawdbot-watchdog.service" "$SYSTEMD_DIR/"
    cp "$SCRIPT_DIR/systemd/clawdbot-watchdog.timer" "$SYSTEMD_DIR/"

    systemctl --user daemon-reload
    log_success "Systemd units installed"
}

setup_telegram_allowlist() {
    local ALLOW_FILE="$CLAWDBOT_DIR/credentials/telegram-allowFrom.json"
    if [[ ! -f "$ALLOW_FILE" ]]; then
        log_info "Setting up Telegram allowlist..."
        read -p "Enter your Telegram user ID (or press Enter to skip): " telegram_id
        if [[ -n "$telegram_id" ]]; then
            echo "{\"version\":1,\"allowFrom\":[\"$telegram_id\"]}" > "$ALLOW_FILE"
            log_success "Allowlist created with user ID: $telegram_id"
        else
            echo '{"version":1,"allowFrom":[]}' > "$ALLOW_FILE"
            log_warning "Empty allowlist created — edit $ALLOW_FILE to add your Telegram user ID"
        fi
    else
        log_success "Telegram allowlist already exists"
    fi

    local PAIRING_FILE="$CLAWDBOT_DIR/credentials/telegram-pairing.json"
    if [[ ! -f "$PAIRING_FILE" ]]; then
        echo '{"version":1,"requests":[]}' > "$PAIRING_FILE"
    fi
}

print_summary() {
    echo ""
    echo "========================================"
    echo "  ClawdBot Infrastructure Setup Complete"
    echo "========================================"
    echo ""
    echo "Next steps:"
    echo ""
    echo "  1. Add your config:"
    echo "     cp $SCRIPT_DIR/config-templates/clawdbot.example.json $CLAWDBOT_DIR/clawdbot.json"
    echo "     # Edit clawdbot.json — fill in tokens and API keys"
    echo ""
    echo "  2. Add bot tokens:"
    echo "     echo -n 'YOUR_TOKEN' > $CLAWDBOT_DIR/tokens/production-smma.token"
    echo "     chmod 600 $CLAWDBOT_DIR/tokens/*.token"
    echo ""
    echo "  3. Enable and start services:"
    echo "     systemctl --user enable --now clawdbot-gateway.service"
    echo "     systemctl --user enable --now clawdbot-watchdog.timer"
    echo ""
    echo "  4. Verify:"
    echo "     clawdbot gateway health"
    echo "     systemctl --user status clawdbot-gateway"
    echo ""
    echo "Documentation: $SCRIPT_DIR/docs/"
    echo ""
}

main() {
    echo ""
    echo "=========================================="
    echo "  OpenClaw Agents — ClawdBot Setup"
    echo "  5 Agents | Systemd | Watchdog | Docker"
    echo "=========================================="
    echo ""

    check_prerequisites
    create_directories
    install_scripts
    install_systemd
    setup_telegram_allowlist
    print_summary

    log_success "Setup complete!"
}

main "$@"
