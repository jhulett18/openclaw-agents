#!/bin/bash
# setup-systemd.sh — Install ClawdBot systemd user units
#
# Installs:
#   - clawdbot-gateway.service (main gateway process)
#   - clawdbot-watchdog.service (health check oneshot)
#   - clawdbot-watchdog.timer (triggers watchdog every 5 min)
#
# Usage:
#   ./setup-systemd.sh [--enable] [--start]

set -euo pipefail

SYSTEMD_DIR="$HOME/.config/systemd/user"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== ClawdBot Systemd Setup ==="
echo "Installing to: $SYSTEMD_DIR"
echo ""

# Create systemd user directory
mkdir -p "$SYSTEMD_DIR"

# Copy unit files
cp "$REPO_DIR/systemd/clawdbot-gateway.service" "$SYSTEMD_DIR/"
cp "$REPO_DIR/systemd/clawdbot-watchdog.service" "$SYSTEMD_DIR/"
cp "$REPO_DIR/systemd/clawdbot-watchdog.timer" "$SYSTEMD_DIR/"

echo "Installed:"
echo "  - clawdbot-gateway.service"
echo "  - clawdbot-watchdog.service"
echo "  - clawdbot-watchdog.timer"
echo ""

# Reload systemd
systemctl --user daemon-reload
echo "Reloaded systemd user daemon"
echo ""

# Enable if requested
if [[ "${1:-}" == "--enable" ]] || [[ "${2:-}" == "--enable" ]]; then
    systemctl --user enable clawdbot-gateway.service
    systemctl --user enable clawdbot-watchdog.timer
    echo "Enabled: gateway service + watchdog timer"
    echo ""
fi

# Start if requested
if [[ "${1:-}" == "--start" ]] || [[ "${2:-}" == "--start" ]]; then
    systemctl --user start clawdbot-gateway.service
    systemctl --user start clawdbot-watchdog.timer
    echo "Started: gateway service + watchdog timer"
    echo ""
fi

echo "=== Done ==="
echo ""
echo "Next steps:"
echo "  systemctl --user enable --now clawdbot-gateway.service"
echo "  systemctl --user enable --now clawdbot-watchdog.timer"
echo "  systemctl --user status clawdbot-gateway"
