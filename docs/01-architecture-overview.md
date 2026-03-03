# Architecture Overview

This document describes the system architecture of the OpenClaw bot fleet.

## Components

### ClawdBot Gateway

The gateway is the central process. It's a Node.js application that:

- Polls the Telegram Bot API for each configured account
- Routes incoming messages to the correct Claude agent based on bindings
- Manages agent sessions, concurrency, and response streaming
- Exposes an RPC interface on port `18789` for health checks and management

One gateway process handles all bots. There is no per-bot process — the gateway multiplexes everything.

### Agents

Each bot is backed by a Claude agent with its own:

- **Workspace** — a directory on the filesystem the agent can read/write
- **Agent directory** — config and session data in `~/.clawdbot/agents/<agent-id>/`
- **Identity documents** — `SOUL.md` files that define personality and capabilities
- **Memory** — isolated per-agent memory via claude-mem

### Telegram Accounts

Each agent is bound to one Telegram bot account. The mapping is:

```
Telegram Account  →  Agent ID  →  Workspace
─────────────────────────────────────────────
production-smma   →  main      →  /root/clawd
production-cici   →  cici      →  /root/clawd/CiciCoder
reddit-scanner    →  reddit-scanner  →  /root/clawd/RedditScanner
production-openclaw → openclaw-monitor → /root/openclaw-monitor
```

### Memory System (claude-mem)

The `claude-mem` plugin provides persistent memory for all agents:

- Runs a worker process on port `37777`
- Each agent's memory is isolated via project scoping
- Memory auto-captures important context from conversations
- Web UI available at `http://localhost:37777` for inspection

### Watchdog

A systemd timer that runs every 5 minutes:

1. Calls `clawdbot gateway health` with a 15-second timeout
2. If the health check fails, restarts the gateway service
3. Includes a 60-second cooldown to prevent restart loops

### OpenClaw Monitor

A Python application that audits ecosystem health every 15 minutes:

- **7 check modules:** gateway, credentials, cron health, log scanning, system resources, dashboard, session coherence
- Produces text and JSON reports
- Sends critical findings via Telegram
- Reports stored in `/root/openclaw-monitor/reports/`

## Data Flow

```
User sends message to @socialmediasam112bot
  │
  ▼
Telegram Bot API
  │
  ▼
Gateway polls for updates
  │
  ▼
Gateway matches account "production-smma" → binding → agent "main"
  │
  ▼
Agent "main" processes message in workspace /root/clawd
  │
  ├──▶ claude-mem: reads/writes agent memory
  ├──▶ Skills: GetLate.dev, GitHub, Gemini Media
  └──▶ Tools: filesystem, bash, etc.
  │
  ▼
Agent response streamed back to Telegram
```

## Port Map

| Port | Service | Purpose |
|------|---------|---------|
| 18789 | ClawdBot Gateway | RPC interface (health checks, management) |
| 37777 | claude-mem worker | Memory storage, web UI |
| 3000 | Sam Dashboard | Web dashboard for SMMA clients (optional) |

## File Layout on Server

```
~/.clawdbot/
├── clawdbot.json              # Master configuration
├── tokens/                    # Bot API tokens (chmod 600)
│   ├── production-smma.token
│   ├── production-cici.token
│   ├── reddit-scanner.token
│   └── production-openclaw.token
├── agents/
│   ├── main/
│   ├── cici/
│   ├── reddit-scanner/
│   └── openclaw-monitor/
├── scripts/
│   └── gateway-watchdog.sh    # Health check script
├── logs/
│   ├── watchdog.log
│   └── .watchdog-last-restart
└── telegram-allowFrom.json    # Chat ID allowlist

~/clawd/                       # Main agent workspace
├── SOUL.md                    # Sam's identity
├── CiciCoder/                 # Cici's workspace
│   └── SOUL.md
└── RedditScanner/             # Reddit Scanner's workspace
    └── SOUL.md

~/openclaw-monitor/            # Monitor workspace
├── SOUL.md
├── monitor_agent.py
├── monitor_config.yaml
├── checks/                    # 7 check modules
└── reports/                   # Timestamped reports
```

## Next Steps

- [Prerequisites](02-prerequisites.md) — what you need to get started
- [Telegram Bot Setup](03-telegram-bot-setup.md) — create your first bot
