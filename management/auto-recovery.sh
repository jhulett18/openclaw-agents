#!/bin/bash
# ClawdBot Auto-Recovery Script
# Runs every 2 hours to check and recover from common failures

set -e

LOG_FILE="/tmp/clawdbot-recovery-$(date +%Y%m%d).log"
RECOVERY_ATTEMPTS_FILE="/tmp/clawdbot-recovery-attempts.json"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

get_recovery_count() {
    local key="$1"
    if [[ -f "$RECOVERY_ATTEMPTS_FILE" ]]; then
        jq -r ".\"$key\" // 0" "$RECOVERY_ATTEMPTS_FILE" 2>/dev/null || echo 0
    else
        echo 0
    fi
}

increment_recovery_count() {
    local key="$1"
    local current=$(get_recovery_count "$key")
    local new_count=$((current + 1))
    
    if [[ ! -f "$RECOVERY_ATTEMPTS_FILE" ]]; then
        echo '{}' > "$RECOVERY_ATTEMPTS_FILE"
    fi
    
    jq ".\"$key\" = $new_count" "$RECOVERY_ATTEMPTS_FILE" > "${RECOVERY_ATTEMPTS_FILE}.tmp" \
        && mv "${RECOVERY_ATTEMPTS_FILE}.tmp" "$RECOVERY_ATTEMPTS_FILE"
}

reset_recovery_count() {
    local key="$1"
    if [[ -f "$RECOVERY_ATTEMPTS_FILE" ]]; then
        jq ".\"$key\" = 0" "$RECOVERY_ATTEMPTS_FILE" > "${RECOVERY_ATTEMPTS_FILE}.tmp" \
            && mv "${RECOVERY_ATTEMPTS_FILE}.tmp" "$RECOVERY_ATTEMPTS_FILE"
    fi
}

check_daemon_status() {
    log "🔍 Checking ClawdBot daemon status..."
    
    if ! clawdbot health &>/dev/null; then
        log "❌ Daemon is not responding"
        
        local attempts=$(get_recovery_count "daemon")
        if [[ $attempts -ge 3 ]]; then
            log "⚠️  Too many daemon restart attempts ($attempts), skipping"
            return 1
        fi
        
        log "🔄 Restarting ClawdBot daemon..."
        clawdbot daemon restart || {
            log "❌ Failed to restart daemon"
            increment_recovery_count "daemon"
            return 1
        }
        
        sleep 10
        if clawdbot health &>/dev/null; then
            log "✅ Daemon restarted successfully"
            reset_recovery_count "daemon"
        else
            log "❌ Daemon still not responding after restart"
            increment_recovery_count "daemon"
            return 1
        fi
    else
        log "✅ Daemon is running"
        reset_recovery_count "daemon"
    fi
}

check_provider_connectivity() {
    log "🔍 Checking provider connectivity..."
    
    # Check Telegram bots
    local telegram_status=$(clawdbot status | grep -E "Telegram:|@.*Bot" || true)
    if echo "$telegram_status" | grep -q "error\|failed\|disconnected"; then
        log "⚠️  Telegram provider issues detected"
        
        local attempts=$(get_recovery_count "telegram")
        if [[ $attempts -ge 2 ]]; then
            log "⚠️  Too many Telegram recovery attempts ($attempts), skipping"
        else
            log "🔄 Attempting Telegram provider recovery..."
            # Restart telegram providers by reloading config
            touch ~/.clawdbot/clawdbot.json  # Trigger config reload
            increment_recovery_count "telegram"
            sleep 5
        fi
    else
        reset_recovery_count "telegram"
    fi
    
    # Check Discord bot
    local discord_status=$(clawdbot status | grep -E "Discord:|@.*Bot" || true)
    if echo "$discord_status" | grep -q "error\|failed\|disconnected"; then
        log "⚠️  Discord provider issues detected"
        
        local attempts=$(get_recovery_count "discord")
        if [[ $attempts -ge 2 ]]; then
            log "⚠️  Too many Discord recovery attempts ($attempts), skipping"
        else
            log "🔄 Attempting Discord provider recovery..."
            touch ~/.clawdbot/clawdbot.json  # Trigger config reload
            increment_recovery_count "discord"
            sleep 5
        fi
    else
        reset_recovery_count "discord"
    fi
}

check_api_limits() {
    log "🔍 Checking API limits and session states..."
    
    # Check for sessions with high token usage
    local sessions=$(clawdbot sessions list --json 2>/dev/null || echo '[]')
    
    if echo "$sessions" | jq -r '.[] | select(.tokens.used > .tokens.total * 0.9) | .id' | grep -q .; then
        log "⚠️  Found sessions approaching token limits"
        
        # Compact high-usage sessions
        echo "$sessions" | jq -r '.[] | select(.tokens.used > .tokens.total * 0.9) | .id' | while read session_id; do
            log "🗜️  Compacting session: $session_id"
            clawdbot sessions compact "$session_id" || log "❌ Failed to compact $session_id"
        done
    fi
    
    # Check for failed cron jobs and retry them
    local failed_crons=$(clawdbot cron list | grep "error" | awk '{print $1}' || true)
    if [[ -n "$failed_crons" ]]; then
        log "⚠️  Found failed cron jobs, attempting recovery..."
        
        echo "$failed_crons" | while read cron_id; do
            local attempts=$(get_recovery_count "cron_$cron_id")
            if [[ $attempts -ge 2 ]]; then
                log "⚠️  Too many retry attempts for cron $cron_id ($attempts), skipping"
                continue
            fi
            
            log "🔄 Retrying failed cron job: $cron_id"
            if clawdbot cron run "$cron_id" &>/dev/null; then
                log "✅ Cron job $cron_id recovered"
                reset_recovery_count "cron_$cron_id"
            else
                log "❌ Failed to recover cron job $cron_id"
                increment_recovery_count "cron_$cron_id"
            fi
        done
    fi
}

check_docker_sandboxes() {
    log "🔍 Checking Docker sandbox health..."
    
    if command -v docker &>/dev/null; then
        # Check if Docker is running
        if ! docker info &>/dev/null; then
            log "⚠️  Docker is not running, attempting to start..."
            sudo systemctl start docker || log "❌ Failed to start Docker"
            return
        fi
        
        # Clean up old/failed containers
        local old_containers=$(docker ps -a --filter "name=clawdbot-" --filter "status=exited" --format "{{.Names}}" | wc -l)
        if [[ $old_containers -gt 0 ]]; then
            log "🧹 Cleaning up $old_containers old sandbox containers"
            docker ps -a --filter "name=clawdbot-" --filter "status=exited" --format "{{.Names}}" | xargs -r docker rm
        fi
        
        # Check sandbox network
        if ! docker network inspect clawdbot-sandbox &>/dev/null; then
            log "🔧 Creating missing sandbox network"
            docker network create clawdbot-sandbox || log "❌ Failed to create sandbox network"
        fi
    else
        log "ℹ️  Docker not installed, skipping sandbox checks"
    fi
}

cleanup_old_logs() {
    log "🧹 Cleaning up old logs..."
    
    # Remove recovery logs older than 7 days
    find /tmp -name "clawdbot-recovery-*.log" -mtime +7 -delete 2>/dev/null || true
    
    # Truncate main clawdbot logs if they're too large (>100MB)
    local log_files=(/tmp/clawdbot/*.log)
    for log_file in "${log_files[@]}"; do
        if [[ -f "$log_file" ]] && [[ $(stat -c%s "$log_file" 2>/dev/null || echo 0) -gt 104857600 ]]; then
            log "🗜️  Truncating large log file: $(basename "$log_file")"
            tail -n 1000 "$log_file" > "${log_file}.tmp" && mv "${log_file}.tmp" "$log_file"
        fi
    done
}

send_health_report() {
    local status="$1"
    local details="$2"
    
    # Simple health report - could be extended to send to monitoring systems
    log "📊 Health Report: $status"
    if [[ -n "$details" ]]; then
        log "Details: $details"
    fi
}

exponential_backoff() {
    local attempt="$1"
    local base_delay="${2:-60}"
    local max_delay="${3:-3600}"
    
    local delay=$((base_delay * (2 ** attempt)))
    if [[ $delay -gt $max_delay ]]; then
        delay=$max_delay
    fi
    
    log "⏳ Waiting ${delay}s before next attempt..."
    sleep "$delay"
}

main() {
    log "🦞 ClawdBot Auto-Recovery Starting"
    log "=================================="
    
    local overall_status="healthy"
    local issues=()
    
    # Run health checks
    check_daemon_status || {
        overall_status="degraded"
        issues+=("daemon")
    }
    
    check_provider_connectivity || {
        overall_status="degraded"
        issues+=("providers")
    }
    
    check_api_limits || {
        overall_status="degraded"
        issues+=("api_limits")
    }
    
    check_docker_sandboxes || {
        issues+=("sandboxes")
    }
    
    cleanup_old_logs
    
    # Send health report
    if [[ ${#issues[@]} -eq 0 ]]; then
        send_health_report "healthy" "All systems operational"
    else
        send_health_report "$overall_status" "Issues found: ${issues[*]}"
    fi
    
    log "🎉 Auto-Recovery Complete"
    log "========================"
}

# Run main function with error handling
if main "$@"; then
    exit 0
else
    log "❌ Auto-recovery encountered errors"
    exit 1
fi