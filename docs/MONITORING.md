# Monitoring

ClawdBot monitoring has two layers: the **MicroMonitor agent** (application-level) and the **gateway watchdog** (systemd-level).

## MicroMonitor Agent

MicroMonitor (`openclaw-monitor`) is a dedicated agent that monitors the entire ClawdBot ecosystem.

### Overview

| Field | Value |
|-------|-------|
| Agent ID | `openclaw-monitor` |
| Workspace | `/root/openclaw-monitor` |
| Bot | `@micromonitorrrrr_bot` |
| Schedule | Every 15 minutes via `openclaw-monitor.timer` |
| Nightly report | Daily 10 PM ET via cron |

### Monitor Script

```bash
# Full check
python3 /root/openclaw-monitor/monitor_agent.py

# JSON output
python3 /root/openclaw-monitor/monitor_agent.py --json

# Save report to /root/openclaw-monitor/reports/
python3 /root/openclaw-monitor/monitor_agent.py --save

# Quiet mode (errors only)
python3 /root/openclaw-monitor/monitor_agent.py --quiet

# Send to Telegram
python3 /root/openclaw-monitor/monitor_agent.py --telegram
```

### 7 Check Modules

1. **Gateway** — Health check response time, HTTP status, port availability
2. **Credentials** — OAuth token validity, expiry checks, token file permissions
3. **Cron** — Job execution status, missed runs, stale jobs
4. **Logs** — Error rate analysis, pattern detection, log rotation status
5. **System Resources** — CPU, memory, disk usage, system load
6. **Dashboard** — Sam dashboard health (localhost:3000), SQLite integrity
7. **Session Coherence** — Agent session state, stuck sessions, memory consistency

### Alert Thresholds

| Metric | Warning Threshold |
|--------|-------------------|
| Gateway response time | > 5000 ms |
| Log errors per day | > 50 |
| Memory usage | > 85% |
| Disk usage | > 80% |
| System load | > 2x CPU count |
| Stale reports | > 30 minutes old |

### Sibling Bots Monitored

MicroMonitor tracks the health of all other bots:
- Sam (`@socialmediasam112bot`)
- Cici (`@cicigogogo_codebot`)
- Reddit Scanner (`@redditscanscan_bot`)

### Reports

Reports are saved to `/root/openclaw-monitor/reports/` with timestamps. The nightly cron job produces a comprehensive end-of-day summary.

### Configuration

Monitor config at `/root/openclaw-monitor/monitor_config.yaml` defines:
- Check intervals
- Alert thresholds
- Notification targets
- Sibling bot definitions

---

## Gateway Watchdog

The watchdog is a systemd timer that runs every 5 minutes to verify the gateway is healthy and auto-restarts it on failure.

### Components

| Component | Path |
|-----------|------|
| Timer unit | `~/.config/systemd/user/clawdbot-watchdog.timer` |
| Service unit | `~/.config/systemd/user/clawdbot-watchdog.service` |
| Script | `/root/.clawdbot/scripts/gateway-watchdog.sh` |
| Log | `/root/.clawdbot/logs/watchdog.log` |

### How It Works

```
Every 5 min:
  watchdog.timer triggers → watchdog.service (oneshot)
    → gateway-watchdog.sh
      → timeout 15s: clawdbot gateway health
        → PASS: exit 0 (healthy)
        → FAIL: check 60s cooldown
          → cooldown elapsed: systemctl --user restart clawdbot-gateway
          → cooldown active: skip restart, log warning
```

### Timer Configuration

```ini
[Timer]
OnBootSec=2min          # First check 2 min after boot
OnUnitActiveSec=5min    # Subsequent checks every 5 min
AccuracySec=30s         # Allow 30s scheduling jitter
```

### Script Parameters

| Parameter | Value |
|-----------|-------|
| Health timeout | 15 seconds |
| Restart cooldown | 60 seconds |
| Log file | `/root/.clawdbot/logs/watchdog.log` |
| Cooldown file | `/root/.clawdbot/logs/.watchdog-last-restart` |

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Healthy |
| 124 | Health check timed out |
| Other | Health check failed |

### Management Commands

```bash
# Check timer status
systemctl --user status clawdbot-watchdog.timer

# Check last watchdog run
systemctl --user status clawdbot-watchdog.service

# View restart history
cat /root/.clawdbot/logs/watchdog.log

# Manually trigger a check
systemctl --user start clawdbot-watchdog.service

# Disable watchdog temporarily
systemctl --user stop clawdbot-watchdog.timer

# Re-enable
systemctl --user start clawdbot-watchdog.timer
```

---

## Combined Monitoring Strategy

| Layer | Scope | Frequency | Action |
|-------|-------|-----------|--------|
| Watchdog timer | Gateway process health | Every 5 min | Auto-restart gateway |
| MicroMonitor timer | Full ecosystem health | Every 15 min | Log + alert |
| MicroMonitor cron | Nightly comprehensive report | Daily 10 PM ET | Telegram summary |
| Agent heartbeats | Per-agent health checks | On wake | Agent-specific checks |

The watchdog handles the critical path (keeping the gateway alive), while MicroMonitor provides visibility into the broader ecosystem health.
