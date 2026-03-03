# OpenClaw Agents — ClawdBot Infrastructure

Documentation and configuration templates for the ClawdBot multi-agent system running 5 specialized Telegram bots.

## Architecture

```
┌──────────────────────────────────────────────────────────────────────┐
│                      ClawdBot Gateway (v2026.1.24-3)                │
│                        Port 18789 · systemd                         │
│                                                                      │
│  ┌──────────┐ ┌────────┐ ┌──────────────┐ ┌────────────┐ ┌────────────────┐
│  │   Sam    │ │  Cici  │ │    Reddit    │ │   Micro    │ │   Dashboard    │
│  │  (main)  │ │        │ │   Scanner    │ │  Monitor   │ │     Bot        │
│  └────┬─────┘ └───┬────┘ └──────┬───────┘ └─────┬──────┘ └───────┬────────┘
│       │           │             │                │                │
└───────┼───────────┼─────────────┼────────────────┼────────────────┼──────────┘
        │           │             │                │                │
   @socialmedia  @cicigogogo  @redditscanscan  @micromonitorrrrr   (web)
   sam112bot     _codebot     _bot             _bot
```

## Agents

| Agent | Telegram Bot | Role | Workspace |
|-------|-------------|------|-----------|
| **Sam** (main) | `@socialmediasam112bot` | SMMA marketing partner — content strategy, scheduling, client management | `/root/clawd` |
| **Cici** | `@cicigogogo_codebot` | Automation engineer — production systems for legal & hospitality clients | `/root/clawd/CiciCoder` |
| **Reddit Scanner** | `@redditscanscan_bot` | Reddit intelligence — daily scraping, trend analysis, reports | `/root/clawd/RedditScanner` |
| **MicroMonitor** | `@micromonitorrrrr_bot` | Ops watchdog — ecosystem health checks every 15 minutes | `/root/openclaw-monitor` |
| **Dashboard Bot** | *(client-facing web)* | SMMA dashboard assistant — content & analytics for clients | `/root/clawd/DashboardBot` |

## Key Components

- **Gateway**: Node.js service managed by systemd, auto-restarts on failure
- **Watchdog**: Health check every 5 min via systemd timer, auto-restarts gateway
- **Memory**: Per-agent isolated memory via `memory-core` plugin (MEMORY.md + memory/ subdirs)
- **Sandboxes**: 3 Docker configs — restricted (main), development (cici), content_creation (smma)
- **Cron**: 6 scheduled jobs (reviews, reports, monitoring, code summaries)
- **Skills**: GetLate (social scheduling), GitHub, Gemini Media (image/video generation)
- **Telegram**: 5 bot accounts, pairing DM policy + allowlist group policy

## Quick Start

```bash
# 1. Install ClawdBot (requires Node.js 18+)
npm install -g clawdbot

# 2. Clone and run setup
git clone https://github.com/jhulett18/openclaw-agents.git
cd openclaw-agents
./install.sh

# 3. Start the gateway
systemctl --user enable --now clawdbot-gateway.service
systemctl --user enable --now clawdbot-watchdog.timer

# 4. Verify
clawdbot gateway health
systemctl --user status clawdbot-gateway
```

## Common Commands

```bash
# Service management
systemctl --user status clawdbot-gateway       # Check gateway status
systemctl --user restart clawdbot-gateway       # Restart gateway
journalctl --user -u clawdbot-gateway -f        # Stream gateway logs

# Watchdog
systemctl --user status clawdbot-watchdog.timer # Check watchdog timer
cat /root/.clawdbot/logs/watchdog.log           # View restart history

# Agent management
clawdbot agent list                             # List all agents
clawdbot agent sessions <agent-id>              # View agent sessions

# Cron jobs
clawdbot cron list                              # List all cron jobs
clawdbot cron run <job-id>                      # Trigger a job manually

# Health
clawdbot gateway health --json                  # JSON health output
```

## Documentation

| Document | Description |
|----------|-------------|
| [Architecture](docs/ARCHITECTURE.md) | Gateway, agent routing, auth, sandboxes |
| [Agents](docs/AGENTS.md) | All 5 agents — config, purpose, memory, cron |
| [Telegram Setup](docs/TELEGRAM_SETUP.md) | Bot creation, tokens, policies, allowlists |
| [Memory System](docs/MEMORY_SYSTEM.md) | memory-core plugin, per-agent isolation |
| [Cron Jobs](docs/CRON_JOBS.md) | All 6 scheduled jobs with details |
| [Sandboxes](docs/SANDBOXES.md) | Docker sandbox configurations |
| [Monitoring](docs/MONITORING.md) | MicroMonitor agent + watchdog timer |

## Repository Structure

```
openclaw-agents/
├── README.md                          # This file
├── .env.example                       # GetLate API key template
├── .gitignore                         # Security-aware gitignore
├── install.sh                         # Setup script
├── docs/                              # Detailed documentation
│   ├── ARCHITECTURE.md
│   ├── AGENTS.md
│   ├── TELEGRAM_SETUP.md
│   ├── MEMORY_SYSTEM.md
│   ├── CRON_JOBS.md
│   ├── SANDBOXES.md
│   └── MONITORING.md
├── config-templates/                  # Sanitized config templates
│   ├── clawdbot.example.json
│   ├── agent-workspace/               # Template agent workspace
│   │   ├── AGENTS.md
│   │   ├── SOUL.md
│   │   ├── IDENTITY.md
│   │   ├── USER.md
│   │   ├── HEARTBEAT.md
│   │   ├── MEMORY.md
│   │   └── TOOLS.md
│   └── monitor_config.example.yaml
├── scripts/                           # Management scripts
│   ├── gateway-watchdog.sh
│   ├── docker-health-check.sh
│   └── setup-systemd.sh
└── systemd/                           # Service unit templates
    ├── clawdbot-gateway.service
    ├── clawdbot-watchdog.service
    └── clawdbot-watchdog.timer
```

## Security

- Bot tokens stored in `/root/.clawdbot/tokens/` — never committed
- Gateway auth via bearer token
- Anthropic OAuth per-agent profiles
- Telegram allowlist restricts to authorized user(s) only
- Docker sandboxes: `no_new_privileges`, capability drops, optional readonly rootfs
- All secrets excluded via `.gitignore`

## Version Info

| Component | Value |
|-----------|-------|
| ClawdBot | v2026.1.24-3 |
| Gateway Port | 18789 |
| Node Entry | `/usr/lib/node_modules/clawdbot/dist/entry.js` |
| Config | `/root/.clawdbot/clawdbot.json` |
