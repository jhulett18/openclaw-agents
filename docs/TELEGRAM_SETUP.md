# Telegram Setup

Guide for creating and configuring Telegram bots for ClawdBot.

## Bot Creation

### 1. Create a Bot via BotFather

1. Open Telegram and message [@BotFather](https://t.me/botfather)
2. Send `/newbot`
3. Choose a display name (e.g., "Sam - SMMA Bot")
4. Choose a username (must end in `bot`, e.g., `socialmediasam112bot`)
5. Save the bot token — you'll need it for ClawdBot config

### 2. Configure Bot Settings (Optional)

With BotFather:
- `/setdescription` — What users see before starting a chat
- `/setabouttext` — Short bio in the bot's profile
- `/setuserpic` — Bot's profile picture
- `/setcommands` — Command menu (ClawdBot handles this via native commands)

## Token Management

### Storage

Bot tokens are stored as plaintext files with restrictive permissions:

```
/root/.clawdbot/tokens/
├── production-smma.token         # Sam
├── production-cici.token         # Cici
├── reddit-scanner.token          # Reddit Scanner
├── production-openclaw.token     # MicroMonitor
└── dashboard-bot.token           # Dashboard Bot
```

### Adding a New Token

```bash
# Write token to file
echo -n "1234567890:ABCdefGHIjklMNOpqrsTUVwxyz" > /root/.clawdbot/tokens/my-bot.token

# Set permissions
chmod 600 /root/.clawdbot/tokens/my-bot.token
```

### Token Rotation

1. Generate new token via BotFather (`/revoke`)
2. Update the token file
3. Restart the gateway: `systemctl --user restart clawdbot-gateway`

## ClawdBot Configuration

### Adding a Telegram Account

In `clawdbot.json`, add to `channels.telegram.accounts`:

```json
{
  "my-account": {
    "name": "My Bot Description",
    "enabled": true,
    "dmPolicy": "pairing",
    "tokenFile": "/root/.clawdbot/tokens/my-account.token",
    "groupPolicy": "allowlist",
    "streamMode": "partial"
  }
}
```

### Binding to an Agent

Add to the `bindings` array:

```json
{
  "agentId": "my-agent",
  "match": {
    "channel": "telegram",
    "accountId": "my-account"
  }
}
```

## Current Bot Accounts

| Account ID | Display Name | Bot Username | Agent |
|------------|-------------|-------------|-------|
| `production-smma` | Production Social Media Marketer | `@socialmediasam112bot` | main (Sam) |
| `production-cici` | Cici - Automation Engineer | `@cicigogogo_codebot` | cici |
| `reddit-scanner` | Reddit Scanner | `@redditscanscan_bot` | reddit-scanner |
| `production-openclaw` | MicroMonitor | `@micromonitorrrrr_bot` | openclaw-monitor |
| `dashboard-bot` | Dashboard Bot | *(client-facing)* | dashboard-bot |

## Policies

### DM Policy: `pairing`

Direct messages require pairing approval before the bot responds. This prevents unauthorized users from interacting with bots.

Pairing state is tracked in `/root/.clawdbot/credentials/telegram-pairing.json`.

### Group Policy: `allowlist`

Bots only respond in groups that are explicitly allowed. The allowlist is in `/root/.clawdbot/credentials/telegram-allowFrom.json`:

```json
{
  "version": 1,
  "allowFrom": ["<telegram-user-id>"]
}
```

### Stream Mode: `partial`

Messages are streamed partially — the bot shows typing indicator and sends partial responses as they're generated.

### Ack Reaction Scope: `group-mentions`

In group chats, the bot reacts (acknowledges) only when explicitly mentioned.

## Update Offsets

Telegram uses update offsets to track which messages have been processed. These are stored per-account:

```
/root/.clawdbot/telegram/
├── update-offset-production-smma.json
├── update-offset-production-cici.json
├── update-offset-reddit-scanner.json
├── update-offset-production-openclaw.json
└── update-offset-dashboard-bot.json
```

These are managed automatically by ClawdBot. Do not edit manually.

## Troubleshooting

### Bot Not Responding

1. Check gateway is running: `systemctl --user status clawdbot-gateway`
2. Verify token file exists and is non-empty: `ls -la /root/.clawdbot/tokens/`
3. Check the account is enabled in `clawdbot.json`
4. Check the binding exists for the account → agent
5. Review logs: `journalctl --user -u clawdbot-gateway --since "5 min ago"`

### Pairing Issues

1. Check pairing state: `cat /root/.clawdbot/credentials/telegram-pairing.json`
2. Verify allowFrom includes your Telegram user ID
3. Restart gateway after making changes

### Rate Limiting

Telegram Bot API has rate limits. If you're hitting them:
- Reduce `streamMode` frequency
- Avoid sending many messages in rapid succession
- Check for retry-after headers in logs
