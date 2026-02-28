# Telegram Bot Setup for ClawdBot

## Overview
ClawdBot connects directly to the Telegram Bot API without any third-party services. Your bots run on your own machine and communicate directly with Telegram's servers.

## Architecture
```
Your Server (ClawdBot Gateway) ←→ Telegram Bot API ←→ Telegram Users
```

## Prerequisites
- ClawdBot installed and running (`npm install -g clawdbot`)
- Telegram account
- Access to @BotFather on Telegram
- Bot tokens for each bot you want to run

## Step 1: Create a Telegram Bot

1. Open Telegram and search for **@BotFather**
2. Start a chat and send `/newbot`
3. Follow the prompts:
   - **Name your bot**: e.g., "SMMA Marketing Bot"
   - **Choose a username**: Must end in 'bot', e.g., "smma_marketing_bot"
4. BotFather will provide a bot token like: `1234567890:ABCdefGHIjklMNOpqrsTUVwxyz`
5. **SAVE THIS TOKEN SECURELY** - you'll need it to connect the bot

## Step 2: Add Bot to ClawdBot

### Method A: Direct Token (Quick Setup)
```bash
clawdbot providers add \
  --provider telegram \
  --account smma \
  --name "SMMA Bot" \
  --token "YOUR_BOT_TOKEN_HERE"
```

### Method B: Token File (More Secure)
```bash
# Create a secure token file
mkdir -p ~/.clawdbot/tokens
echo "YOUR_BOT_TOKEN_HERE" > ~/.clawdbot/tokens/smma_bot.token
chmod 600 ~/.clawdbot/tokens/smma_bot.token

# Add bot using token file
clawdbot providers add \
  --provider telegram \
  --account smma \
  --name "SMMA Bot" \
  --token-file ~/.clawdbot/tokens/smma_bot.token
```

## Step 3: Verify Bot Connection

```bash
# List all providers to confirm bot is configured
clawdbot providers list | grep telegram

# Check bot status
clawdbot status

# Send a test message (replace @channel_name with your channel)
clawdbot message send \
  --provider telegram \
  --account smma \
  --to @channel_name \
  --message "Hello from SMMA Bot!"
```

## Step 4: Configure Bot Features in Telegram

Go back to @BotFather and use these commands to configure your bot:

1. `/mybots` - Select your bot
2. Configure these settings:
   - **Edit Description**: What users see in bot profile
   - **Edit About**: Short description shown before starting chat
   - **Edit Commands**: Add custom commands like `/help`, `/status`
   - **Edit Bot Privacy**: Disable for group chat access
   - **Edit Inline Mode**: Enable if bot needs inline queries

## Step 5: Set Up Multiple Bots

Repeat Steps 1-4 for each bot you need. Common bot types:

- **System Bot** (default): Monitoring and alerts
- **SMMA Bot**: Marketing automation
- **Support Bot**: Customer service
- **Events Bot**: Event management
- **Admin Bot**: Administrative tasks

## Bot Management Commands

```bash
# List all configured Telegram bots
clawdbot providers list | grep telegram

# Remove a bot
clawdbot providers remove --provider telegram --account smma

# Update bot token
clawdbot providers add \
  --provider telegram \
  --account smma \
  --token "NEW_TOKEN_HERE"

# Send message from specific bot
clawdbot message send \
  --provider telegram \
  --account smma \
  --to @channel_or_user \
  --message "Your message here"
```

## Security Best Practices

1. **Never commit tokens to Git**
2. **Use token files instead of command-line tokens**
3. **Set restrictive permissions on token files** (`chmod 600`)
4. **Rotate tokens periodically** via @BotFather
5. **Use environment variables for production**:
   ```bash
   export TELEGRAM_BOT_TOKEN_SMMA="your_token_here"
   clawdbot providers add \
     --provider telegram \
     --account smma \
     --use-env
   ```

## Troubleshooting

### Bot not responding
```bash
# Check gateway status
clawdbot gateway status

# Restart gateway
clawdbot daemon restart

# Check logs
clawdbot logs --tail 50
```

### Invalid token error
1. Verify token with @BotFather (use `/mybots`)
2. Check for extra spaces or characters in token
3. Regenerate token if needed: `/revoke` in @BotFather

### Connection issues
```bash
# Test gateway connection
clawdbot doctor

# Deep status check
clawdbot status --deep
```

## Advanced Configuration

### Running Multiple Bot Accounts
```bash
# Add multiple bots with different account IDs
clawdbot providers add --provider telegram --account bot1 --token "TOKEN1"
clawdbot providers add --provider telegram --account bot2 --token "TOKEN2"
clawdbot providers add --provider telegram --account bot3 --token "TOKEN3"
```

### Webhook vs Polling
ClawdBot handles this automatically, but you can configure if needed:
- **Polling**: Default, works behind firewalls
- **Webhook**: Faster, requires public HTTPS endpoint

## Next Steps
- See `BOT_CREATION.md` for detailed bot creation guide
- See `CLAWDBOT_CONNECTION.md` for ClawdBot provider details
- See `EXISTING_BOTS.md` for current bot configurations