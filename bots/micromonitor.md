# MicroMonitor — Ecosystem Health Auditor

| Field | Value |
|-------|-------|
| **Handle** | `@micromonitorrrrr_bot` |
| **Agent ID** | `openclaw-monitor` |
| **Account ID** | `production-openclaw` |
| **Workspace** | `/root/openclaw-monitor` |
| **SOUL.md** | `/root/openclaw-monitor/SOUL.md` |

## Purpose

MicroMonitor is an ops watchdog for the entire ClawdBot ecosystem. It runs an automated monitoring pipeline that audits gateway health, credentials, cron jobs, logs, system resources, and the dashboard — every 15 minutes via systemd timer.

## The 7 Check Modules

Located in `/root/openclaw-monitor/checks/`:

| Module | File | What It Checks |
|--------|------|---------------|
| **Gateway** | `gateway.py` | RPC health, response time, connected accounts |
| **Credentials** | `credentials.py` | Token files exist, permissions, API key validity |
| **Cron Health** | `cron_health.py` | Scheduled jobs running on time, overdue detection |
| **Log Scanner** | `log_scanner.py` | Error patterns in gateway logs, watchdog restarts |
| **System Resources** | `system_resources.py` | CPU load, memory usage, disk space |
| **Dashboard** | `dashboard.py` | Sam's web dashboard responding, SQLite accessible |
| **Session Coherence** | `session_coherence.py` | Agent sessions not stale, data consistency |

## How It Works

```
openclaw-monitor.timer (every 15 min)
        │
        ▼
  monitor_agent.py (orchestrator)
        │
        ├──▶ gateway.py         → Check RPC health
        ├──▶ credentials.py     → Validate tokens & API keys
        ├──▶ cron_health.py     → Check scheduled jobs
        ├──▶ log_scanner.py     → Scan for errors
        ├──▶ system_resources.py → CPU, memory, disk
        ├──▶ dashboard.py       → Web dashboard health
        └──▶ session_coherence.py → Session staleness
        │
        ▼
  Generate report (text + JSON)
        │
        ├──▶ Save to reports/
        └──▶ Send critical findings to Telegram
```

## Configuration

The monitor reads `monitor_config.yaml` for all paths, thresholds, and bot definitions. See [`examples/monitor_config.yaml.example`](../examples/monitor_config.yaml.example) for the full template.

### Key Thresholds

| Metric | Threshold | Level |
|--------|-----------|-------|
| Gateway response time | > 5000ms | WARN |
| Log errors per day | > 50 | WARN |
| Memory usage | > 85% | WARN |
| Disk usage | > 80% | WARN |
| System load | > 2x CPU count | WARN |
| Sam session staleness | > 90 min | INFO |
| Other agent sessions | > 24 hours | INFO |

### Credential Validation

The monitor actively validates:

- **Telegram tokens:** Files exist and have correct permissions (chmod 600)
- **Apify API key:** Makes a test call to `https://api.apify.com/v2/users/me`
- **GetLate API key:** Cross-checks the key in `.env` against `clawdbot.json`

## Reports

Reports are saved as timestamped files in `/root/openclaw-monitor/reports/`:

```
reports/
├── 2026-03-03T12-00-00Z.txt    # Human-readable
├── 2026-03-03T12-00-00Z.json   # Machine-parseable
├── 2026-03-03T12-15-00Z.txt
└── ...
```

### Telegram Alerts

Critical findings are sent to the admin via Telegram using Sam's bot token. The admin chat ID is configured in `monitor_config.yaml`.

## Personality (from SOUL.md)

- **Terse and status-oriented.** Leads with OK, WARN, or CRITICAL. Details only if needed.
- **Direct.** "Gateway: OK. 4/4 bots connected. Cron: 2 overdue jobs. Disk: 73%."
- **Structured.** Uses consistent formatting — tables, bullet lists, status codes.
- **Proactive about anomalies.** Flags patterns before they become critical (e.g., disk usage trending up).
- **Honest about scope.** Only monitors what its check modules cover.

## Companion Documents

The monitor workspace includes several reference files:

| File | Purpose |
|------|---------|
| `SOUL.md` | Core identity and behavior |
| `IDENTITY.md` | Short identity card (name, vibe, emoji) |
| `AGENTS.md` | Reference for sibling agents |
| `TOOLS.md` | Available tools and capabilities |
| `HEARTBEAT.md` | Heartbeat check procedures |
| `BOOTSTRAP.md` | Setup and bootstrap instructions |
| `USER.md` | User/admin information |

## How MicroMonitor Was Set Up

1. Created the bot via BotFather (`@micromonitorrrrr_bot`)
2. Saved the token to `~/.clawdbot/tokens/production-openclaw.token`
3. Added the `production-openclaw` account to `clawdbot.json`
4. Created agent `openclaw-monitor` with workspace `/root/openclaw-monitor`
5. Added binding: `production-openclaw` → `openclaw-monitor`
6. Wrote `SOUL.md` defining the ops watchdog personality
7. Built the Python monitoring pipeline with 7 check modules
8. Created `monitor_config.yaml` with paths, thresholds, and bot definitions
9. Set up `openclaw-monitor.timer` for 15-minute intervals

## Files

| File | Purpose |
|------|---------|
| `/root/openclaw-monitor/SOUL.md` | Monitor's identity document |
| `/root/openclaw-monitor/monitor_agent.py` | Main orchestrator |
| `/root/openclaw-monitor/monitor_config.yaml` | Configuration |
| `/root/openclaw-monitor/checks/` | 7 check modules |
| `/root/openclaw-monitor/reports/` | Timestamped reports |
| `~/.clawdbot/tokens/production-openclaw.token` | Bot API token |
