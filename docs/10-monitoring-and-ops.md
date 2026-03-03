# Monitoring & Ops

Health checks, the OpenClaw Monitor, and recovery procedures.

## Health Checks

### Gateway Health

The primary health check:

```bash
clawdbot gateway health
```

This sends an RPC request to `127.0.0.1:18789`. A healthy response includes:

- Gateway version and uptime
- Connected Telegram accounts and their status
- Agent states and session counts
- Memory plugin status

For JSON output (used by the monitor):

```bash
clawdbot gateway health --json
```

The health check result is cached for 60 seconds to avoid hammering the gateway.

### Watchdog Health Check

The watchdog (`clawdbot-watchdog.timer`) automates health checking:

- Runs every 5 minutes
- Timeout: 15 seconds
- On failure: restarts the gateway
- Cooldown: 60 seconds between restarts
- Logs to: `~/.clawdbot/logs/watchdog.log`

Check watchdog status:

```bash
# Timer status
systemctl --user status clawdbot-watchdog.timer

# Recent runs
systemctl --user list-timers clawdbot-watchdog.timer

# Watchdog log
tail -20 ~/.clawdbot/logs/watchdog.log
```

## OpenClaw Monitor

The OpenClaw Monitor is a Python application that performs deep ecosystem auditing every 15 minutes.

### 7 Check Modules

| Module | What It Checks |
|--------|---------------|
| **Gateway** | RPC health, response time, connected accounts |
| **Credentials** | Token files exist, permissions correct, API keys valid |
| **Cron Health** | Scheduled jobs running on time, overdue jobs |
| **Log Scanner** | Error patterns in gateway logs, watchdog restarts |
| **System Resources** | CPU load, memory usage, disk space |
| **Dashboard** | Sam's web dashboard responding, SQLite DB accessible |
| **Session Coherence** | Agent sessions not stale, session data consistent |

### Running Manually

```bash
cd /root/openclaw-monitor
python3 monitor_agent.py
```

### Reports

Reports are saved to `/root/openclaw-monitor/reports/` in both text and JSON formats:

```bash
ls /root/openclaw-monitor/reports/
# 2026-03-03T12-00-00Z.txt
# 2026-03-03T12-00-00Z.json
```

### Telegram Alerts

The monitor sends critical findings to Telegram via the Sam bot's token. Only issues at WARN or CRITICAL level are reported.

### Monitor Configuration

See [`examples/monitor_config.yaml.example`](../examples/monitor_config.yaml.example) for the full config template. Key thresholds:

| Threshold | Default | Description |
|-----------|---------|-------------|
| `response_time_ms` | 5000 | Gateway response time warning |
| `error_rate_per_day` | 50 | Log error count warning |
| `memory_percent` | 85 | System memory warning |
| `disk_percent` | 80 | Disk usage warning |
| `load_warn_multiplier` | 2.0 | Load average warning (N x CPU count) |

## Recovery Procedures

### Gateway Won't Start

1. Check the logs:
   ```bash
   journalctl --user -u clawdbot-gateway -n 50
   ```
2. Verify the config:
   ```bash
   cat ~/.clawdbot/clawdbot.json | python3 -m json.tool
   ```
3. Check for port conflicts:
   ```bash
   lsof -i :18789
   ```
4. Try starting manually:
   ```bash
   clawdbot gateway --port 18789
   ```

### Bot Not Responding

1. Check gateway health:
   ```bash
   clawdbot gateway health
   ```
2. Verify the bot's account is enabled in `clawdbot.json`
3. Check the token file exists and has correct permissions:
   ```bash
   ls -la ~/.clawdbot/tokens/
   ```
4. Check the allowlist:
   ```bash
   cat ~/.clawdbot/telegram-allowFrom.json
   ```
5. Restart the gateway:
   ```bash
   systemctl --user restart clawdbot-gateway
   ```

### Watchdog Restart Loop

If the watchdog keeps restarting the gateway:

1. Check the watchdog log for the failure reason:
   ```bash
   tail -50 ~/.clawdbot/logs/watchdog.log
   ```
2. The 60-second cooldown prevents rapid restarts, but if the underlying issue persists, the gateway will keep crashing
3. Stop the watchdog, fix the issue, then re-enable:
   ```bash
   systemctl --user stop clawdbot-watchdog.timer
   # Fix the issue
   systemctl --user start clawdbot-watchdog.timer
   ```

### Memory Worker Down

1. Check if the worker is running:
   ```bash
   lsof -i :37777
   ```
2. The memory worker is managed by the gateway — restarting the gateway should restart the worker
3. If memories are corrupted, check the agent's MEMORY.md files in their workspaces

## Operational Checklist

Daily:

- [ ] Glance at `clawdbot gateway health` output
- [ ] Check for CRITICAL entries in watchdog log

Weekly:

- [ ] Review OpenClaw Monitor reports for trends
- [ ] Check disk usage (`df -h`)
- [ ] Review allowlist for stale entries

Monthly:

- [ ] Rotate API keys if needed
- [ ] Review and prune agent memories
- [ ] Check for ClawdBot updates (`npm outdated -g clawdbot`)

## Next Steps

- [Troubleshooting](11-troubleshooting.md) — common failures and fixes
