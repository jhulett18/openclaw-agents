# Prerequisites

What you need before setting up the OpenClaw bot fleet.

## Server Requirements

- **OS:** Linux (Ubuntu 22.04+ recommended)
- **RAM:** 4 GB minimum (8 GB recommended for all 4 bots)
- **Disk:** 20 GB free space
- **Network:** Outbound HTTPS access (Telegram Bot API, Anthropic API, Apify, GetLate.dev)
- **User:** Root or a user with systemd `--user` support (`loginctl enable-linger <user>`)

## Software

### Node.js (v20+)

ClawdBot requires Node.js 20 or later.

```bash
# Install via nvm (recommended)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.bashrc
nvm install 20
nvm use 20
```

### Python (3.10+)

Required for OpenClaw Monitor.

```bash
# Ubuntu
sudo apt update && sudo apt install -y python3 python3-pip python3-venv
```

### ClawdBot

```bash
npm install -g clawdbot
```

Verify installation:

```bash
clawdbot --version
# Should output: 2026.x.x-x
```

### systemd (user services)

The gateway, watchdog, and monitor all run as systemd user services. Enable lingering so services persist after logout:

```bash
sudo loginctl enable-linger $(whoami)
```

Verify:

```bash
systemctl --user status
# Should show your user's systemd instance
```

## API Keys & Accounts

| Service | Purpose | Where to Get It |
|---------|---------|-----------------|
| **Telegram Bot API** | Bot tokens | [@BotFather](https://t.me/BotFather) on Telegram |
| **Anthropic API** | Claude agent backend | [console.anthropic.com](https://console.anthropic.com) |
| **Apify** (optional) | Reddit scraping | [apify.com](https://apify.com) |
| **GetLate.dev** (optional) | Social media posting | [getlate.dev](https://getlate.dev) |

## Directory Setup

Create the base directories:

```bash
mkdir -p ~/.clawdbot/tokens
mkdir -p ~/.clawdbot/agents
mkdir -p ~/.clawdbot/scripts
mkdir -p ~/.clawdbot/logs
mkdir -p ~/clawd
```

## Next Steps

- [Telegram Bot Setup](03-telegram-bot-setup.md) — create your first bot with BotFather
