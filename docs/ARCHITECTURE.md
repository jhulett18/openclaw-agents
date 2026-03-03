# Architecture

## Overview

ClawdBot is a multi-agent gateway that routes Telegram messages to specialized AI agents. Each agent has its own workspace, memory, identity, and Telegram bot account.

## Gateway

- **Process**: Node.js (`/usr/lib/node_modules/clawdbot/dist/entry.js`)
- **Port**: 18789 (HTTP + RPC)
- **Mode**: local
- **Managed by**: systemd user service (`clawdbot-gateway.service`)
- **Auto-restart**: `Restart=always`, `RestartSec=5`
- **Config**: `/root/.clawdbot/clawdbot.json`

### HTTP Endpoints

- Chat completions endpoint enabled (`gateway.http.endpoints.chatCompletions`)
- Health check: `clawdbot gateway health` (RPC to 127.0.0.1:18789, cached 60s)

## Agent Routing

Messages are routed from Telegram accounts to agents via **bindings** in `clawdbot.json`:

```
Telegram Account          →  Agent
─────────────────────────────────────
production-smma           →  main (Sam)
production-cici           →  cici
reddit-scanner            →  reddit-scanner
production-openclaw       →  openclaw-monitor (MicroMonitor)
dashboard-bot             →  dashboard-bot
```

Each binding matches on `channel: telegram` + `accountId`. A message arriving on a specific Telegram bot is routed to the bound agent.

## Agent Defaults

```json
{
  "workspace": "/root/clawd",
  "userTimezone": "America/New_York",
  "compaction": { "mode": "safeguard" },
  "maxConcurrent": 4,
  "subagents": { "maxConcurrent": 8 }
}
```

Individual agents can override `workspace` and `agentDir`.

## Authentication

### Gateway Auth

Token-based authentication for HTTP API access:

```json
{
  "gateway": {
    "auth": {
      "mode": "token",
      "token": "<bearer-token>"
    }
  }
}
```

### Anthropic OAuth

Agents authenticate with Anthropic's API via OAuth profiles stored in each agent's `auth-profiles.json`. Most agents share a single OAuth session; Dashboard Bot has its own separate session.

- **Profile type**: `oauth`
- **Provider**: `anthropic`
- **Tokens**: access token (`sk-ant-oat01-...`) + refresh token (`sk-ant-ort01-...`)
- **Auto-refresh**: Tokens are refreshed automatically before expiry

### Device Identity

- **Device ID**: Ed25519 keypair stored in `/root/.clawdbot/identity/device.json`
- **Operator auth**: Token + scopes (`operator.admin`, `operator.approvals`, `operator.pairing`) in `device-auth.json`
- **Paired devices**: Tracked in `/root/.clawdbot/devices/paired.json`

## Telegram Channel

### Configuration

All 5 accounts share the same policies:

| Setting | Value |
|---------|-------|
| `dmPolicy` | `pairing` — DMs require pairing approval |
| `groupPolicy` | `allowlist` — groups must be explicitly allowed |
| `streamMode` | `partial` — partial message streaming |
| `ackReactionScope` | `group-mentions` — react to mentions in groups |

### Token Storage

Bot tokens are stored as plaintext files in `/root/.clawdbot/tokens/`:

```
/root/.clawdbot/tokens/
├── production-smma.token
├── production-cici.token
├── reddit-scanner.token
├── production-openclaw.token
└── dashboard-bot.token
```

### Allowlist

Only authorized Telegram user IDs can interact with bots:

```json
// /root/.clawdbot/credentials/telegram-allowFrom.json
{ "version": 1, "allowFrom": ["<user-id>"] }
```

## Sandboxes

Three Docker sandbox configurations for agent code execution:

| Sandbox | Mode | Resources | Security |
|---------|------|-----------|----------|
| `main` | restricted | 1GB RAM, 0.5 CPU | readonly rootfs, user: nobody, drop ALL caps |
| `cici` | development | 2GB RAM, 1.0 CPU | writable rootfs, user: developer, drop SYS_ADMIN/NET_ADMIN/SYS_MODULE |
| `smma` | content_creation | 1.5GB RAM, 0.75 CPU | writable rootfs, user: creator, drop SYS_ADMIN/NET_ADMIN |

All sandboxes:
- Image: `ubuntu:22.04`
- Network: `clawdbot-sandbox`
- `no_new_privileges: true`

## Skills & Plugins

### Skills (external integrations)

| Skill | Purpose | Auth |
|-------|---------|------|
| `getlate` | Social media scheduling via GetLate.dev | API key |
| `github` | GitHub repository operations | System auth (gh CLI) |
| `gemini-media` | Image/video generation via Google Gemini | API key |

### Plugins (core functionality)

| Plugin | Slot | Purpose |
|--------|------|---------|
| `telegram` | — | Telegram Bot API channel |
| `memory-core` | `memory` | Per-agent file-backed memory system |

### Hooks

| Hook | Type | Purpose |
|------|------|---------|
| `session-memory` | internal | Auto-saves session context on `/new` |

## Commands

ClawdBot supports native commands and native skills (both set to `auto` discovery mode).

## File Layout

```
/root/.clawdbot/
├── clawdbot.json              # Master configuration
├── agents/                    # Per-agent data
│   └── {id}/agent/
│       ├── auth-profiles.json # Anthropic OAuth tokens
│       ├── sessions.json      # Session index
│       └── sessions/          # Session transcript .jsonl files
├── cron/
│   ├── jobs.json              # 6 cron job definitions
│   └── runs/                  # Job run logs
├── credentials/               # Telegram allowlist + pairing
├── devices/                   # Paired device registry
├── identity/                  # Ed25519 keypair + operator token
├── logs/                      # Watchdog log
├── media/inbound/             # Received media files
├── sandboxes/{name}/          # Docker sandbox configs
├── scripts/                   # Management scripts
├── telegram/                  # Update offset files (per account)
└── tokens/                    # Bot token files
```
