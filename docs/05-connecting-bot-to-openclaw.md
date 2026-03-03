# Connecting a Bot to OpenClaw

How to add a new Telegram bot to the ClawdBot gateway and bind it to an agent.

## Overview

Connecting a bot requires three things:

1. **A token file** — the Telegram bot token saved to disk
2. **A Telegram account entry** — added to `clawdbot.json` under `channels.telegram.accounts`
3. **A binding** — maps the Telegram account to a Claude agent

## Step 1: Save the Bot Token

If you haven't already (see [Telegram Bot Setup](03-telegram-bot-setup.md)):

```bash
echo "YOUR_TOKEN_HERE" > ~/.clawdbot/tokens/my-bot.token
chmod 600 ~/.clawdbot/tokens/my-bot.token
```

## Step 2: Add the Telegram Account

Open `~/.clawdbot/clawdbot.json` and add an entry under `channels.telegram.accounts`:

```json
{
  "channels": {
    "telegram": {
      "enabled": true,
      "accounts": {
        "my-bot": {
          "name": "My Bot Description",
          "enabled": true,
          "dmPolicy": "pairing",
          "tokenFile": "/root/.clawdbot/tokens/my-bot.token",
          "groupPolicy": "allowlist",
          "streamMode": "partial"
        }
      }
    }
  }
}
```

### Account Fields

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Human-readable description of the account |
| `enabled` | boolean | Whether this account is active |
| `dmPolicy` | string | How to handle DMs: `"pairing"` (request access), `"open"`, or `"disabled"` |
| `tokenFile` | string | Absolute path to the token file |
| `groupPolicy` | string | How to handle group messages: `"allowlist"`, `"open"`, or `"disabled"` |
| `streamMode` | string | Response streaming: `"partial"` (stream chunks) or `"complete"` (send when done) |

## Step 3: Create the Agent

Add the agent to the `agents.list` array:

```json
{
  "agents": {
    "list": [
      {
        "id": "my-agent",
        "name": "my-agent",
        "workspace": "/root/clawd/MyAgent",
        "agentDir": "/root/.clawdbot/agents/my-agent/agent"
      }
    ]
  }
}
```

Create the workspace directory:

```bash
mkdir -p /root/clawd/MyAgent
```

## Step 4: Bind Account to Agent

Add a binding that maps the Telegram account to the agent:

```json
{
  "bindings": [
    {
      "agentId": "my-agent",
      "match": {
        "channel": "telegram",
        "accountId": "my-bot"
      }
    }
  ]
}
```

This tells the gateway: "When a message arrives on the `my-bot` Telegram account, route it to the `my-agent` agent."

## Step 5: Restart the Gateway

After changing `clawdbot.json`, restart the gateway to pick up the new config:

```bash
systemctl --user restart clawdbot-gateway
```

## Step 6: Test

1. Send a message to your bot on Telegram
2. Check that the gateway received it:
   ```bash
   clawdbot gateway health
   ```
3. The bot should respond through Telegram

## The Complete `channels.telegram` Block

Here's what the full Telegram channel config looks like with all 4 bots:

```json
{
  "channels": {
    "telegram": {
      "enabled": true,
      "dmPolicy": "pairing",
      "groupPolicy": "allowlist",
      "streamMode": "partial",
      "accounts": {
        "production-smma": {
          "name": "Production Social Media Marketer",
          "enabled": true,
          "dmPolicy": "pairing",
          "tokenFile": "/root/.clawdbot/tokens/production-smma.token",
          "groupPolicy": "allowlist",
          "streamMode": "partial"
        },
        "production-cici": {
          "name": "Cici - Automation Engineer",
          "enabled": true,
          "dmPolicy": "pairing",
          "tokenFile": "/root/.clawdbot/tokens/production-cici.token",
          "groupPolicy": "allowlist",
          "streamMode": "partial"
        },
        "reddit-scanner": {
          "name": "Reddit Scanner",
          "enabled": true,
          "dmPolicy": "pairing",
          "tokenFile": "/root/.clawdbot/tokens/reddit-scanner.token",
          "groupPolicy": "allowlist",
          "streamMode": "partial"
        },
        "production-openclaw": {
          "name": "MicroMonitor",
          "enabled": true,
          "dmPolicy": "pairing",
          "tokenFile": "/root/.clawdbot/tokens/production-openclaw.token",
          "groupPolicy": "allowlist",
          "streamMode": "partial"
        }
      }
    }
  }
}
```

Account-level policies (`dmPolicy`, `groupPolicy`, `streamMode`) override the channel-level defaults.

## Next Steps

- [Chat ID Pairing](06-chat-id-pairing.md) — control who can talk to your bots
- [Agent Configuration](07-agent-configuration.md) — set up agent workspaces and identity
