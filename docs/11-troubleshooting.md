# Troubleshooting

Common failures, diagnostics, and fixes.

## Quick Diagnostics

Run these commands to get a snapshot of system health:

```bash
# Gateway status
systemctl --user status clawdbot-gateway

# Gateway health check
clawdbot gateway health

# All ClawdBot units
systemctl --user list-units 'clawdbot-*' 'openclaw-*'

# Active timers
systemctl --user list-timers

# Recent gateway logs
journalctl --user -u clawdbot-gateway -n 30 --no-pager

# Watchdog log
tail -20 ~/.clawdbot/logs/watchdog.log

# System resources
free -h && df -h / && uptime
```

## Common Issues

### "Gateway health check failed"

**Symptom:** `clawdbot gateway health` returns an error or times out.

**Causes:**
1. Gateway not running → `systemctl --user start clawdbot-gateway`
2. Port 18789 blocked or in use → `lsof -i :18789`
3. Gateway crashed → check `journalctl --user -u clawdbot-gateway -n 50`

**Fix:** Restart the gateway. If it keeps crashing, check logs for the root cause (usually a malformed config or missing token file).

### "Bot doesn't respond to messages"

**Symptom:** You send a message on Telegram, but the bot never replies.

**Checklist:**
1. Is the gateway running? → `systemctl --user status clawdbot-gateway`
2. Is the account enabled? → Check `clawdbot.json` → `channels.telegram.accounts.<id>.enabled`
3. Does the token file exist? → `ls -la ~/.clawdbot/tokens/`
4. Is the token valid? → `curl -s "https://api.telegram.org/bot$(cat ~/.clawdbot/tokens/YOUR_ACCOUNT.token)/getMe"`
5. Is your chat ID in the allowlist? → `cat ~/.clawdbot/telegram-allowFrom.json`
6. Is the binding correct? → Check `clawdbot.json` → `bindings` array

### "Permission denied on token file"

**Symptom:** Gateway logs show permission errors reading token files.

**Fix:**
```bash
chmod 600 ~/.clawdbot/tokens/*.token
chown $(whoami) ~/.clawdbot/tokens/*.token
```

### "Agent not found" or "No binding for account"

**Symptom:** Gateway logs show that a Telegram account has no matching agent.

**Fix:** Check that:
1. The agent exists in `agents.list` with the correct `id`
2. A binding exists mapping the account to the agent
3. The `accountId` in the binding matches the key in `channels.telegram.accounts`

### "Memory not persisting across sessions"

**Symptom:** The agent forgets everything between conversations.

**Checklist:**
1. Is claude-mem enabled? → Check `plugins.entries.claude-mem.enabled`
2. Is the memory slot set? → Check `plugins.slots.memory` is `"claude-mem"`
3. Is the worker running? → `lsof -i :37777`
4. Is `syncMemoryFile` true? → Check the claude-mem config
5. Is the `session-memory` hook disabled? → Having both causes conflicts

### "Watchdog keeps restarting the gateway"

**Symptom:** Watchdog log shows repeated restarts.

**Diagnosis:**
```bash
# Check why the health check is failing
tail -50 ~/.clawdbot/logs/watchdog.log

# Look for crash patterns
journalctl --user -u clawdbot-gateway --since "1 hour ago" | grep -i "error\|crash\|fatal"
```

**Common causes:**
- Config syntax error in `clawdbot.json`
- Invalid or expired token
- Out of memory (check `free -h`)
- Node.js crash (check for stack traces in logs)

### "systemctl --user doesn't work"

**Symptom:** `Failed to connect to bus: No medium found` or similar.

**Fix:**
```bash
# Enable lingering for your user
sudo loginctl enable-linger $(whoami)

# Set the runtime directory
export XDG_RUNTIME_DIR=/run/user/$(id -u)
```

### "Port already in use"

**Symptom:** Gateway fails to start because port 18789 is already bound.

**Fix:**
```bash
# Find what's using the port
lsof -i :18789

# Kill the stale process if needed
kill $(lsof -t -i :18789)

# Then restart
systemctl --user restart clawdbot-gateway
```

### "Monitor reports stale sessions"

**Symptom:** OpenClaw Monitor flags sessions as stale.

**Context:** Each agent has a `session_stale_minutes` threshold. Sam's is 90 minutes; others are 24 hours. If a session hasn't been touched in that window, it's flagged.

**Fix:** Usually informational — stale sessions are cleaned up automatically. If an agent is stuck mid-session, restart the gateway.

## Log Locations

| Log | Path | Rotated? |
|-----|------|----------|
| Gateway stdout/stderr | `journalctl --user -u clawdbot-gateway` | Yes (journald) |
| Gateway application logs | `/tmp/clawdbot/clawdbot-YYYY-MM-DD.log` | Daily by filename |
| Watchdog log | `~/.clawdbot/logs/watchdog.log` | No (manual) |
| Monitor reports | `/root/openclaw-monitor/reports/` | No (timestamped files) |

## Getting Help

If you're stuck:

1. Check the logs (see above)
2. Run `clawdbot gateway health --json` and read the full output
3. Run the OpenClaw Monitor manually: `cd /root/openclaw-monitor && python3 monitor_agent.py`
4. Review this repo's [docs/](.) for the relevant guide
