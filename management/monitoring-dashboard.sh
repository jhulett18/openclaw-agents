#!/bin/bash
# ClawdBot Monitoring Dashboard
# Provides real-time status and health metrics

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    clear
    echo -e "${BLUE}🦞 ClawdBot Monitoring Dashboard${NC}"
    echo -e "${BLUE}=================================${NC}"
    echo "Last updated: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
}

check_daemon_health() {
    echo -e "${BLUE}📊 Daemon Status${NC}"
    echo "----------------"
    
    if clawdbot health &>/dev/null; then
        echo -e "Status: ${GREEN}✅ Running${NC}"
        
        # Get detailed daemon info
        local daemon_info=$(clawdbot daemon status 2>/dev/null)
        local pid=$(echo "$daemon_info" | grep "pid" | awk '{print $2}' | tr -d ',' || echo "unknown")
        local port=$(echo "$daemon_info" | grep "port.*18789" | head -1 || echo "Port: 18789 (default)")
        
        echo "PID: $pid"
        echo "Port: 18789"
        echo "Dashboard: http://127.0.0.1:18789/"
    else
        echo -e "Status: ${RED}❌ Down${NC}"
        echo "Last attempt to restart: $(date)"
    fi
    echo ""
}

check_providers() {
    echo -e "${BLUE}🔌 Provider Status${NC}"
    echo "------------------"
    
    local status_output=$(clawdbot status 2>/dev/null || echo "Failed to get status")
    
    # Parse Telegram status
    echo -e "${YELLOW}Telegram:${NC}"
    local telegram_bots=$(echo "$status_output" | grep -A10 "Telegram:" | grep "token:config" | wc -l || echo 0)
    echo "  Configured bots: $telegram_bots"
    echo "  - Scout (main)"
    echo "  - LovableBot" 
    echo "  - Resume Bot"
    echo "  - SMMA Bot"
    
    # Parse Discord status
    echo -e "${YELLOW}Discord:${NC}"
    if echo "$status_output" | grep -q "Discord.*configured"; then
        echo -e "  Status: ${GREEN}✅ Connected${NC}"
    else
        echo -e "  Status: ${RED}❌ Disconnected${NC}"
    fi
    
    # Parse WhatsApp status
    echo -e "${YELLOW}WhatsApp:${NC}"
    if echo "$status_output" | grep -q "not linked"; then
        echo -e "  Status: ${YELLOW}⚠️  Not linked${NC}"
    else
        echo -e "  Status: ${GREEN}✅ Connected${NC}"
    fi
    echo ""
}

check_sessions() {
    echo -e "${BLUE}💬 Session Status${NC}"
    echo "------------------"
    
    local status_output=$(clawdbot status 2>/dev/null || echo "")
    local active_sessions=$(echo "$status_output" | grep "Active sessions:" | awk '{print $3}' || echo "0")
    
    echo "Active sessions: $active_sessions"
    
    # Get recent session info
    echo "Recent sessions:"
    echo "$status_output" | grep -A5 "Recent sessions:" | tail -5 | while read line; do
        if [[ -n "$line" && "$line" != "Recent sessions:" ]]; then
            local session_id=$(echo "$line" | awk '{print $2}' | tr -d '[]')
            local time_ago=$(echo "$line" | grep -o '[0-9]*[mhd] ago' || echo "unknown")
            local tokens=$(echo "$line" | grep -o '[0-9]*k used' || echo "0k used")
            echo "  - $session_id ($time_ago, $tokens)"
        fi
    done
    echo ""
}

check_cron_jobs() {
    echo -e "${BLUE}⏰ Cron Jobs${NC}"
    echo "-------------"
    
    local cron_list=$(clawdbot cron list 2>/dev/null || echo "Failed to get cron jobs")
    
    local total_jobs=$(echo "$cron_list" | grep -v "ID.*Name.*Schedule" | grep -v "^$" | wc -l || echo 0)
    local failed_jobs=$(echo "$cron_list" | grep "error" | wc -l || echo 0)
    local running_jobs=$(echo "$cron_list" | grep -v "error" | grep -v "ID.*Name.*Schedule" | grep -v "^$" | wc -l || echo 0)
    
    echo "Total jobs: $total_jobs"
    if [[ $failed_jobs -gt 0 ]]; then
        echo -e "Failed jobs: ${RED}$failed_jobs ❌${NC}"
    else
        echo -e "Failed jobs: ${GREEN}0 ✅${NC}"
    fi
    echo "Running jobs: $running_jobs"
    
    # Show recent cron activity
    if [[ $failed_jobs -gt 0 ]]; then
        echo -e "${YELLOW}Failed jobs:${NC}"
        echo "$cron_list" | grep "error" | head -3 | while read line; do
            local job_name=$(echo "$line" | awk '{print $2}' | tr -d '[]')
            echo "  - $job_name"
        done
    fi
    echo ""
}

check_resource_usage() {
    echo -e "${BLUE}💾 Resource Usage${NC}"
    echo "------------------"
    
    # Memory usage
    local memory_info=$(free -h | grep '^Mem:' | awk '{print $3 "/" $2}')
    echo "Memory: $memory_info"
    
    # CPU load
    local cpu_load=$(uptime | awk -F'load average:' '{print $2}' | tr -d ' ')
    echo "CPU Load: $cpu_load"
    
    # Disk usage for clawdbot directory
    local disk_usage=$(du -sh ~/.clawdbot 2>/dev/null | awk '{print $1}' || echo "unknown")
    echo "ClawdBot data: $disk_usage"
    
    # Log file sizes
    local log_size=$(du -sh /tmp/clawdbot-*.log 2>/dev/null | awk '{sum += $1} END {print sum "M"}' || echo "0M")
    echo "Log files: $log_size"
    echo ""
}

check_security_status() {
    echo -e "${BLUE}🔒 Security Status${NC}"
    echo "------------------"
    
    local config_file="$HOME/.clawdbot/clawdbot.json"
    if [[ -f "$config_file" ]]; then
        # Check DM policies
        local telegram_dm_policy=$(jq -r '.telegram.dmPolicy // "unknown"' "$config_file")
        local discord_dm_policy=$(jq -r '.discord.dm.policy // "unknown"' "$config_file")
        
        echo "Telegram DM Policy: $telegram_dm_policy"
        if [[ "$telegram_dm_policy" == "pairing" ]]; then
            echo -e "  ${GREEN}✅ Secure (pairing required)${NC}"
        else
            echo -e "  ${YELLOW}⚠️  Open to all users${NC}"
        fi
        
        echo "Discord DM Policy: $discord_dm_policy"
        if [[ "$discord_dm_policy" == "pairing" ]]; then
            echo -e "  ${GREEN}✅ Secure (pairing required)${NC}"
        else
            echo -e "  ${YELLOW}⚠️  Open to all users${NC}"
        fi
        
        # Check tool restrictions
        local default_tools=$(jq -r '.agents.defaults.tools.allowlist[]?' "$config_file" 2>/dev/null | wc -l || echo 0)
        echo "Default tool allowlist: $default_tools tools"
        if [[ $default_tools -gt 0 ]]; then
            echo -e "  ${GREEN}✅ Tool restrictions active${NC}"
        else
            echo -e "  ${YELLOW}⚠️  No tool restrictions${NC}"
        fi
    else
        echo -e "${RED}❌ Config file not found${NC}"
    fi
    echo ""
}

check_docker_status() {
    echo -e "${BLUE}🐳 Docker Sandbox Status${NC}"
    echo "------------------------"
    
    if command -v docker &>/dev/null; then
        if docker info &>/dev/null; then
            echo -e "Docker: ${GREEN}✅ Running${NC}"
            
            # Check sandbox containers
            local containers=$(docker ps --filter "name=clawdbot-" --format "{{.Names}}" | wc -l)
            echo "Active sandbox containers: $containers"
            
            # Check sandbox network
            if docker network inspect clawdbot-sandbox &>/dev/null; then
                echo -e "Sandbox network: ${GREEN}✅ Available${NC}"
            else
                echo -e "Sandbox network: ${YELLOW}⚠️  Missing${NC}"
            fi
        else
            echo -e "Docker: ${RED}❌ Not running${NC}"
        fi
    else
        echo -e "Docker: ${YELLOW}⚠️  Not installed${NC}"
        echo "Run setup script: ./clawdbot-sandbox-setup.sh"
    fi
    echo ""
}

show_quick_actions() {
    echo -e "${BLUE}🔧 Quick Actions${NC}"
    echo "----------------"
    echo "r) Refresh dashboard"
    echo "s) Run health check script"
    echo "t) Test recovery script"
    echo "c) Show cron job details" 
    echo "l) View recent logs"
    echo "q) Quit"
    echo ""
    echo -n "Choose action (r/s/t/c/l/q): "
}

view_recent_logs() {
    echo -e "${BLUE}📋 Recent Logs${NC}"
    echo "-------------"
    
    local log_file="/tmp/clawdbot/clawdbot-$(date +%Y-%m-%d).log"
    if [[ -f "$log_file" ]]; then
        echo "Last 10 log entries:"
        tail -10 "$log_file" | while read line; do
            echo "  $line"
        done
    else
        echo "No log file found: $log_file"
    fi
    
    echo ""
    echo -n "Press Enter to continue..."
    read
}

show_cron_details() {
    echo -e "${BLUE}⏰ Cron Job Details${NC}"
    echo "==================="
    
    clawdbot cron list || echo "Failed to get cron job list"
    
    echo ""
    echo -n "Press Enter to continue..."
    read
}

run_health_check() {
    echo -e "${BLUE}🏥 Running Health Check${NC}"
    echo "======================"
    
    if [[ -f "/home/kawalski/Documents/github/clawdbot-health-monitor.sh" ]]; then
        bash /home/kawalski/Documents/github/clawdbot-health-monitor.sh
    else
        echo "Health monitor script not found!"
    fi
    
    echo ""
    echo -n "Press Enter to continue..."
    read
}

test_recovery() {
    echo -e "${BLUE}🔄 Testing Recovery Script${NC}"
    echo "=========================="
    
    if [[ -f "/home/kawalski/Documents/github/clawdbot-auto-recovery.sh" ]]; then
        echo "Running auto-recovery script in test mode..."
        bash /home/kawalski/Documents/github/clawdbot-auto-recovery.sh
    else
        echo "Auto-recovery script not found!"
    fi
    
    echo ""
    echo -n "Press Enter to continue..."
    read
}

main() {
    while true; do
        print_header
        check_daemon_health
        check_providers
        check_sessions
        check_cron_jobs
        check_resource_usage
        check_security_status
        check_docker_status
        show_quick_actions
        
        read -r action
        echo ""
        
        case $action in
            r|R)
                continue
                ;;
            s|S)
                run_health_check
                ;;
            t|T)
                test_recovery
                ;;
            c|C)
                show_cron_details
                ;;
            l|L)
                view_recent_logs
                ;;
            q|Q)
                echo "Goodbye!"
                break
                ;;
            *)
                echo "Invalid option. Press Enter to continue..."
                read
                ;;
        esac
    done
}

# Check if running interactively
if [[ "${1:-}" == "--monitor" ]]; then
    # Non-interactive mode - just show status once
    print_header
    check_daemon_health
    check_providers
    check_sessions
    check_cron_jobs
    check_resource_usage
    check_security_status
    check_docker_status
else
    # Interactive mode
    main "$@"
fi