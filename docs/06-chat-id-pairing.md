# Chat ID Pairing

How to control who can talk to your bots using allowlists and the DM pairing flow.

## Overview

ClawdBot uses **chat ID-based access control** to restrict who can interact with your bots. This is important — without it, anyone who discovers your bot's username could start sending it messages (and consuming your API credits).

There are two mechanisms:

1. **Allowlist** (`telegram-allowFrom.json`) — a static list of approved chat IDs
2. **DM Pairing** (`dmPolicy: "pairing"`) — a flow where new users can request access

## The Allowlist

The allowlist file lives at:

```
~/.clawdbot/telegram-allowFrom.json
```

### Format

```json
{
  "allowFrom": [
    {
      "chatId": "YOUR_CHAT_ID",
      "note": "Your Name — admin"
    },
    {
      "chatId": "ANOTHER_CHAT_ID",
      "note": "Team Member — read-only"
    }
  ]
}
```

- `chatId` — the Telegram chat ID (string, see [Getting Your Chat ID](03-telegram-bot-setup.md#getting-your-chat-id))
- `note` — a human-readable label (not used by the system, just for your reference)

### How It Works

When a message arrives, the gateway checks if the sender's chat ID is in the allowlist. If not:

- **DMs:** Behavior depends on the `dmPolicy` setting
- **Groups:** Behavior depends on the `groupPolicy` setting

### Adding Your Chat ID

1. Get your chat ID (see [Telegram Bot Setup](03-telegram-bot-setup.md#getting-your-chat-id))
2. Add it to the allowlist:

```bash
cat > ~/.clawdbot/telegram-allowFrom.json << 'EOF'
{
  "allowFrom": [
    {
      "chatId": "YOUR_CHAT_ID",
      "note": "Your Name"
    }
  ]
}
EOF
```

3. Restart the gateway:

```bash
systemctl --user restart clawdbot-gateway
```

## DM Pairing Flow

When `dmPolicy` is set to `"pairing"` (the default for all bots), new users who message the bot get a pairing flow instead of being silently ignored.

### How Pairing Works

1. A new user (not in the allowlist) sends a DM to the bot
2. The bot responds with a pairing request — essentially asking "who are you?"
3. The admin (you) receives a notification about the pairing request
4. You can approve or deny the request
5. If approved, the user's chat ID is added to the allowlist

### DM Policy Options

Set per-account in `clawdbot.json`:

```json
{
  "dmPolicy": "pairing"
}
```

| Policy | Behavior |
|--------|----------|
| `"pairing"` | New users get a pairing flow; admin approves/denies |
| `"open"` | Anyone can DM the bot (no access control) |
| `"disabled"` | Bot ignores all DMs from unknown users |

## Group Policy

Controls how the bot behaves in Telegram groups:

```json
{
  "groupPolicy": "allowlist"
}
```

| Policy | Behavior |
|--------|----------|
| `"allowlist"` | Bot only responds in groups whose chat ID is in the allowlist |
| `"open"` | Bot responds in any group it's added to |
| `"disabled"` | Bot ignores all group messages |

### Adding a Group to the Allowlist

1. Add the bot to the group
2. Get the group's chat ID (it's a negative number, e.g., `-1001234567890`):
   - Send a message in the group, then check `getUpdates`:
     ```bash
     curl -s "https://api.telegram.org/botYOUR_BOT_TOKEN/getUpdates" | python3 -m json.tool
     ```
   - Look for `"chat": {"id": -1001234567890, "type": "supergroup"}`
3. Add the group's chat ID to `telegram-allowFrom.json`:
   ```json
   {
     "chatId": "-1001234567890",
     "note": "Team Chat Group"
   }
   ```
4. Restart the gateway

## Security Recommendations

- **Start with `"pairing"` for DMs and `"allowlist"` for groups.** This is the safest default.
- **Never use `"open"` in production** unless you specifically want public access (and understand the API cost implications).
- **Review the allowlist periodically.** Remove users who no longer need access.
- **Use descriptive notes** in the allowlist so you remember why each chat ID was added.

## Next Steps

- [Agent Configuration](07-agent-configuration.md) — set up agent workspaces and identity docs
