#!/usr/bin/env bash
# gateway-watchdog.sh — Health check + auto-restart for clawdbot-gateway
# Run by clawdbot-watchdog.timer every 5 minutes.
#
# Exit codes:
#   0   = healthy, no action needed
#   124 = health check timed out (restart attempted)
#   *   = health check failed (restart attempted)

set -euo pipefail

LOGFILE="/root/.clawdbot/logs/watchdog.log"
COOLDOWN_FILE="/root/.clawdbot/logs/.watchdog-last-restart"
COOLDOWN_SECONDS=60
HEALTH_TIMEOUT=15

log() {
    echo "$(date -u +%Y-%m-%dT%H:%M:%SZ)  $*" >> "$LOGFILE"
}

mkdir -p "$(dirname "$LOGFILE")"

# Run health check with timeout
if timeout "$HEALTH_TIMEOUT" clawdbot gateway health >/dev/null 2>&1; then
    exit 0
fi

EXIT_CODE=$?
log "Health check failed (exit $EXIT_CODE)"

# Check cooldown — don't restart if we restarted recently
if [[ -f "$COOLDOWN_FILE" ]]; then
    LAST_RESTART=$(cat "$COOLDOWN_FILE")
    NOW=$(date +%s)
    ELAPSED=$((NOW - LAST_RESTART))
    if (( ELAPSED < COOLDOWN_SECONDS )); then
        log "SKIP — cooldown active (${ELAPSED}s < ${COOLDOWN_SECONDS}s since last restart)"
        exit 0
    fi
fi

# Restart the gateway
log "RESTART — health check failed (exit $EXIT_CODE)"
date +%s > "$COOLDOWN_FILE"
systemctl --user restart clawdbot-gateway
