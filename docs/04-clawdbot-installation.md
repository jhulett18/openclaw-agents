# ClawdBot Installation

How to install ClawdBot and perform initial configuration.

## Install ClawdBot

```bash
npm install -g clawdbot
```

Verify:

```bash
clawdbot --version
```

## Initial Configuration

ClawdBot reads its configuration from `~/.clawdbot/clawdbot.json`. Create this file with the minimum required config:

```bash
mkdir -p ~/.clawdbot
```

See [`examples/clawdbot.json.example`](../examples/clawdbot.json.example) for a fully annotated template. At minimum, you need:

```json
{
  "agents": {
    "defaults": {
      "workspace": "/root/clawd"
    },
    "list": [
      { "id": "main" }
    ]
  },
  "channels": {
    "telegram": {
      "enabled": true,
      "accounts": {
        "my-bot": {
          "name": "My Bot",
          "enabled": true,
          "tokenFile": "/root/.clawdbot/tokens/my-bot.token"
        }
      }
    }
  },
  "bindings": [
    {
      "agentId": "main",
      "match": {
        "channel": "telegram",
        "accountId": "my-bot"
      }
    }
  ],
  "gateway": {
    "mode": "local"
  }
}
```

## Directory Structure

After installation, your `.clawdbot` directory should look like:

```
~/.clawdbot/
├── clawdbot.json          # Master configuration
├── tokens/                # Bot API tokens
│   └── my-bot.token       # chmod 600
├── agents/                # Agent data (auto-created)
│   └── main/
│       ├── agent/
│       └── sessions/
├── scripts/               # Watchdog and utility scripts
└── logs/                  # Watchdog and gateway logs
```

## Test the Gateway

Start the gateway manually to verify everything works:

```bash
clawdbot gateway --port 18789
```

You should see output indicating the gateway is polling Telegram. Send a message to your bot — if the agent responds, the basic setup is working.

Stop it with `Ctrl+C` — you'll set up systemd to run it permanently in [Systemd Services](09-systemd-services.md).

## Health Check

With the gateway running, test the health check:

```bash
clawdbot gateway health
```

This sends an RPC request to `127.0.0.1:18789`. A healthy gateway returns status info including connected accounts and agent states.

## Next Steps

- [Connecting a Bot to OpenClaw](05-connecting-bot-to-openclaw.md) — add accounts, tokens, and agent bindings
- [Systemd Services](09-systemd-services.md) — run the gateway as a persistent service
