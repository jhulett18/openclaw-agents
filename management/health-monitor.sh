#!/bin/bash
# ClawdBot Simple Health Monitor
# Can be run independently or via cron

LOG_FILE="/tmp/clawdbot-health-$(date +%Y%m%d).log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Quick health check
if ! clawdbot health &>/dev/null; then
    log "❌ ClawdBot daemon is down - attempting restart"
    clawdbot daemon restart
    sleep 10
    if clawdbot health &>/dev/null; then
        log "✅ Daemon restarted successfully"
    else
        log "❌ Failed to restart daemon"
        exit 1
    fi
fi

# Check for failed cron jobs
failed_crons=$(clawdbot cron list | grep "error" | wc -l)
if [[ $failed_crons -gt 0 ]]; then
    log "⚠️  Found $failed_crons failed cron jobs"
fi

# Run full recovery if needed
if [[ "${1:-}" == "--full" ]] || [[ $failed_crons -gt 2 ]]; then
    log "🔄 Running full auto-recovery script"
    bash /home/kawalski/Documents/github/clawdbot-auto-recovery.sh
fi

log "✅ Health check complete"