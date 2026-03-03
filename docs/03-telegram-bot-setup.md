# Telegram Bot Setup

How to create a Telegram bot, get your token, and find your chat ID.

## Creating a Bot with BotFather

1. Open Telegram and search for **@BotFather** (the official Telegram bot for managing bots)
2. Send `/newbot`
3. Choose a **display name** for your bot (e.g., "My Assistant")
4. Choose a **username** — must end in `bot` (e.g., `my_assistant_bot`)
5. BotFather will respond with your **bot token**:
   ```
   Use this token to access the HTTP API:
   123456789:ABCdefGHIjklMNOpqrsTUVwxyz
   ```
6. **Save this token immediately.** You'll need it for the ClawdBot config.

### Bot Settings (Optional)

While in BotFather, you can configure:

- `/setdescription` — what users see before starting a chat
- `/setabouttext` — the bot's "About" section
- `/setuserpic` — upload a profile photo
- `/setcommands` — register slash commands visible in the Telegram UI

## Saving the Token

Store the token in a file with restricted permissions:

```bash
# Create the tokens directory if it doesn't exist
mkdir -p ~/.clawdbot/tokens

# Save the token (replace with your actual token)
echo "YOUR_TOKEN_HERE" > ~/.clawdbot/tokens/my-bot.token

# Restrict permissions — only the owner can read it
chmod 600 ~/.clawdbot/tokens/my-bot.token
```

Each bot gets its own token file. The naming convention is `<account-id>.token`, where `<account-id>` matches what you'll use in `clawdbot.json`.

**Current bot token files:**

```
~/.clawdbot/tokens/
├── production-smma.token       # Sam
├── production-cici.token       # Cici
├── reddit-scanner.token        # Reddit Scanner
└── production-openclaw.token   # MicroMonitor
```

## Getting Your Chat ID

You need your Telegram chat ID to configure allowlists and receive bot messages. There are two ways to find it.

### Method 1: Use @userinfobot (Easiest)

1. Open Telegram and search for **@userinfobot**
2. Send any message to it
3. It replies with your user info, including your **chat ID** (a number like `123456789`)
4. Save this number — you'll use it in `telegram-allowFrom.json`

### Method 2: Use the getUpdates API

If you've already created a bot and sent it a message:

```bash
# Replace YOUR_BOT_TOKEN with the actual token
curl -s "https://api.telegram.org/botYOUR_BOT_TOKEN/getUpdates" | python3 -m json.tool
```

Look for `"chat": {"id": 123456789}` in the response. That number is the chat ID of the user who messaged the bot.

> **Note:** If `getUpdates` returns an empty result, send a message to your bot first, then try again.

### Method 3: Forward a Message

1. Forward any message from the target user to @userinfobot
2. It will show their chat ID

## Understanding Chat IDs

- **User chat IDs** are positive numbers (e.g., `123456789`)
- **Group chat IDs** are negative numbers (e.g., `-1001234567890`)
- **Supergroup/channel IDs** start with `-100` followed by the group number
- Chat IDs are permanent — they don't change if a user changes their username

## Next Steps

- [ClawdBot Installation](04-clawdbot-installation.md) — install and set up ClawdBot
- [Chat ID Pairing](06-chat-id-pairing.md) — configure who can talk to your bots
