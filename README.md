# OpenClaw Agents

Self-hosted Telegram bot fleet powered by [ClawdBot](https://github.com/clawdbot/clawdbot) — a Node.js gateway that multiplexes multiple Telegram bots through a single process, each backed by its own Claude agent.

## Architecture

```
Telegram Cloud
     │
     │  (Bot API polling)
     ▼
┌─────────────────────────────────────────────────┐
│  ClawdBot Gateway  (Node.js, port 18789)        │
│                                                 │
│  ┌───────────┐ ┌───────────┐ ┌───────────────┐ │
│  │ Account:  │ │ Account:  │ │ Account:      │ │
│  │ prod-smma │ │ prod-cici │ │ reddit-scanner│ │     ┌──────────────┐
│  └─────┬─────┘ └─────┬─────┘ └──────┬────────┘ │     │  claude-mem  │
│        │              │              │          │────▶│  (port 37777)│
│  ┌─────┴─────┐ ┌─────┴─────┐ ┌──────┴────────┐ │     │  Per-agent   │
│  │ Agent:    │ │ Agent:    │ │ Agent:        │ │     │  memory      │
│  │ main     │ │ cici      │ │ reddit-scanner│ │     └──────────────┘
│  └───────────┘ └───────────┘ └───────────────┘ │
│                                                 │
│  ┌──────────────────┐                           │
│  │ Account:         │                           │
│  │ prod-openclaw    │                           │
│  └────────┬─────────┘                           │
│  ┌────────┴─────────┐                           │
│  │ Agent:           │                           │
│  │ openclaw-monitor │                           │
│  └──────────────────┘                           │
└─────────────────────────────────────────────────┘
     │                              │
     │ systemd                      │ systemd
     ▼                              ▼
┌──────────────┐            ┌───────────────────┐
│  Watchdog    │            │  OpenClaw Monitor  │
│  (5-min timer)│            │  (15-min timer)    │
│  Health check │            │  7 check modules   │
│  + restart   │            │  + Telegram reports │
└──────────────┘            └───────────────────┘
```

## Bot Fleet

| Bot | Telegram Handle | Agent ID | Purpose |
|-----|-----------------|----------|---------|
| **Sam** | `@socialmediasam112bot` | `main` | Social media marketing assistant via GetLate.dev |
| **Cici** | `@cicigogogo_codebot` | `cici` | Automation engineer and code assistant |
| **Reddit Scanner** | `@redditscanscan_bot` | `reddit-scanner` | Reddit scraping and trend reports via Apify |
| **MicroMonitor** | `@micromonitorrrrr_bot` | `openclaw-monitor` | Ecosystem health auditor (7 check modules) |

See [`bots/`](bots/) for deep dives on each bot.

## Quick Start

> New to the stack? Follow these guides in order.

1. **[Architecture Overview](docs/01-architecture-overview.md)** — understand how the pieces fit together
2. **[Prerequisites](docs/02-prerequisites.md)** — server requirements, Node.js, Python, systemd
3. **[Telegram Bot Setup](docs/03-telegram-bot-setup.md)** — create a bot with BotFather, get your chat ID
4. **[ClawdBot Installation](docs/04-clawdbot-installation.md)** — install ClawdBot on your server
5. **[Connecting a Bot to OpenClaw](docs/05-connecting-bot-to-openclaw.md)** — wire up tokens, agents, and bindings
6. **[Chat ID Pairing](docs/06-chat-id-pairing.md)** — allowlists, DM pairing, access control
7. **[Agent Configuration](docs/07-agent-configuration.md)** — create agents, workspaces, SOUL.md identity docs
8. **[Memory System](docs/08-memory-system.md)** — claude-mem setup and per-agent isolation
9. **[Systemd Services](docs/09-systemd-services.md)** — gateway, watchdog, and monitor timers
10. **[Monitoring & Ops](docs/10-monitoring-and-ops.md)** — health checks, OpenClaw Monitor, recovery
11. **[Troubleshooting](docs/11-troubleshooting.md)** — common failures, diagnostics, fixes

## Example Configs

The [`examples/`](examples/) directory contains sanitized templates you can copy and customize:

- `clawdbot.json.example` — annotated gateway configuration
- `gateway.service.example` — systemd unit for the gateway
- `watchdog.service.example` / `watchdog.timer.example` — health check automation
- `watchdog.sh.example` — the watchdog health check script
- `monitor_config.yaml.example` — OpenClaw Monitor configuration

## Security

**This repo contains no secrets.** All tokens, API keys, and chat IDs use placeholder values (`YOUR_TOKEN_HERE`, `YOUR_CHAT_ID`, etc.). Real credentials live on the server in:

- `~/.clawdbot/tokens/` — Telegram bot tokens (chmod 600)
- `~/.clawdbot/clawdbot.json` — master config (not committed)
- Environment variables and `.env` files for third-party APIs

Never commit real credentials. See [docs/03-telegram-bot-setup.md](docs/03-telegram-bot-setup.md) for token storage best practices.

## Project Structure

```
openclaw-agents/
├── README.md                              # This file
├── docs/
│   ├── 01-architecture-overview.md        # System architecture & data flow
│   ├── 02-prerequisites.md                # Server requirements
│   ├── 03-telegram-bot-setup.md           # BotFather, tokens, chat IDs
│   ├── 04-clawdbot-installation.md        # Installing ClawdBot
│   ├── 05-connecting-bot-to-openclaw.md   # Config, tokens, agent bindings
│   ├── 06-chat-id-pairing.md              # Access control & allowlists
│   ├── 07-agent-configuration.md          # Agents, workspaces, identity
│   ├── 08-memory-system.md                # claude-mem & per-agent memory
│   ├── 09-systemd-services.md             # Service units & timers
│   ├── 10-monitoring-and-ops.md           # Health checks & recovery
│   └── 11-troubleshooting.md              # Diagnostics & fixes
├── bots/
│   ├── sam.md                             # Sam — SMMA bot
│   ├── cici.md                            # Cici — code assistant
│   ├── reddit-scanner.md                  # Reddit Scanner — Apify pipeline
│   ├── micromonitor.md                    # MicroMonitor — ops watchdog
│   └── improvements.md                    # Recommended improvements
├── examples/
│   ├── clawdbot.json.example              # Annotated config template
│   ├── gateway.service.example            # systemd unit template
│   ├── watchdog.service.example           # Watchdog oneshot
│   ├── watchdog.timer.example             # 5-minute timer
│   ├── watchdog.sh.example                # Health check script
│   └── monitor_config.yaml.example        # Monitor config template
└── .gitignore
```

## License

Private repository. Not for redistribution.
