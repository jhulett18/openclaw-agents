# ClawdBot Telegram Provider Configuration

## How ClawdBot Connects to Telegram

ClawdBot uses a direct connection to Telegram's Bot API. No third-party services or proxies are involved.

```
[Your ClawdBot Instance] ←→ [Telegram Bot API] ←→ [Telegram Users/Channels]
```

## Provider System Overview

ClawdBot's provider system manages all chat platform connections:

- **Telegram**: Direct Bot API connection using tokens
- **WhatsApp**: Web session via QR code
- **Discord**: Bot token authentication
- **Slack**: App and bot tokens
- **Signal**: CLI or HTTP daemon
- **iMessage**: Direct database access (macOS)

## Adding Telegram Bots to ClawdBot

### Basic Syntax
```bash
clawdbot providers add \
  --provider telegram \
  --account <unique_id> \
  --name "<display_name>" \
  --token "<bot_token>"
```

### Parameters Explained

- **`--provider telegram`**: Specifies Telegram as the platform
- **`--account <unique_id>`**: Unique identifier for this bot in ClawdBot
  - Examples: `default`, `smma`, `support`, `events`
  - Used to route messages to specific bots
  - Must be unique across all Telegram providers
  
- **`--name "<display_name>"`**: Human-readable name for the bot
  - Shows in `clawdbot providers list`
  - Can contain spaces and special characters
  - Examples: "SMMA Bot", "Customer Support", "System Monitor"
  
- **`--token "<bot_token>"`**: The token from BotFather
  - Format: `1234567890:ABCdefGHIjklMNOpqrsTUVwxyz`
  - Keep quotes around token to handle special characters
  
- **`--token-file <path>`**: Alternative to `--token` for better security
  - Reads token from file instead of command line
  - Prevents token from appearing in shell history

## Configuration Storage

ClawdBot stores configuration in `~/.clawdbot/` directory:

```
~/.clawdbot/
├── config.json           # Main configuration
├── providers/            # Provider configurations
│   ├── telegram/         # Telegram-specific configs
│   └── whatsapp/         # Other providers...
├── tokens/               # Secure token storage (optional)
└── agents/               # Agent workspaces
```

## Adding Multiple Telegram Bots

### Example: Complete Bot Setup
```bash
# 1. System monitoring bot
clawdbot providers add \
  --provider telegram \
  --account default \
  --name "ClawdOps System Bot" \
  --token "1111111111:AAAAAAaaaaaaAAAAAAAAaaaaaaaaaaaaa"

# 2. Marketing automation bot  
clawdbot providers add \
  --provider telegram \
  --account smma \
  --name "SMMA Marketing Bot" \
  --token "2222222222:BBBBBBbbbbbbBBBBBBBBbbbbbbbbbbbb"

# 3. Customer support bot
clawdbot providers add \
  --provider telegram \
  --account support \
  --name "Support Bot" \
  --token "3333333333:CCCCCCccccccCCCCCCCCcccccccccccc"

# 4. Event management bot
clawdbot providers add \
  --provider telegram \
  --account events \
  --name "Event Coordinator" \
  --token "4444444444:DDDDDDddddddDDDDDDDDdddddddddddd"

# 5. Analytics bot
clawdbot providers add \
  --provider telegram \
  --account analytics \
  --name "Analytics Bot" \
  --token "5555555555:EEEEEEeeeeeeEEEEEEEEeeeeeeeeeeee"
```

## Secure Token Management

### Method 1: Token Files
```bash
# Create secure token directory
mkdir -p ~/.clawdbot/tokens
chmod 700 ~/.clawdbot/tokens

# Store each bot's token in a separate file
echo "1111111111:AAAAAAaaaaaaAAAAAAAAaaaaaaaaaaaaa" > ~/.clawdbot/tokens/default.token
echo "2222222222:BBBBBBbbbbbbBBBBBBBBbbbbbbbbbbbb" > ~/.clawdbot/tokens/smma.token
echo "3333333333:CCCCCCccccccCCCCCCCCcccccccccccc" > ~/.clawdbot/tokens/support.token

# Set restrictive permissions
chmod 600 ~/.clawdbot/tokens/*.token

# Add bots using token files
clawdbot providers add \
  --provider telegram \
  --account default \
  --name "System Bot" \
  --token-file ~/.clawdbot/tokens/default.token

clawdbot providers add \
  --provider telegram \
  --account smma \
  --name "SMMA Bot" \
  --token-file ~/.clawdbot/tokens/smma.token
```

### Method 2: Environment Variables
```bash
# Set environment variables
export TELEGRAM_TOKEN_DEFAULT="1111111111:AAAAAAaaaaaaAAAAAAAAaaaaaaaaaaaaa"
export TELEGRAM_TOKEN_SMMA="2222222222:BBBBBBbbbbbbBBBBBBBBbbbbbbbbbbbb"

# Add bot using environment variable (default account only)
clawdbot providers add \
  --provider telegram \
  --account default \
  --use-env
```

## Managing Telegram Providers

### List All Providers
```bash
# Show all configured providers
clawdbot providers list

# Filter for Telegram only
clawdbot providers list | grep -A1 "Telegram"

# Show detailed status
clawdbot providers status --deep
```

### Update a Bot Token
```bash
# Simply re-run the add command with new token
clawdbot providers add \
  --provider telegram \
  --account smma \
  --token "NEW_TOKEN_HERE"
```

### Remove a Bot
```bash
# Remove specific bot
clawdbot providers remove \
  --provider telegram \
  --account smma

# Confirm removal
clawdbot providers list | grep telegram
```

## Using Telegram Bots

### Send Messages
```bash
# Send to a specific user (by user ID)
clawdbot message send \
  --provider telegram \
  --account smma \
  --to "123456789" \
  --message "Hello from SMMA Bot!"

# Send to a channel
clawdbot message send \
  --provider telegram \
  --account smma \
  --to "@my_channel" \
  --message "Channel announcement"

# Send to a group (by group ID)
clawdbot message send \
  --provider telegram \
  --account default \
  --to "-1001234567890" \
  --message "Group message"
```

### Route Messages to Specific Bots
```bash
# Use different accounts for different purposes
clawdbot message send --account default --to "@admin_channel" --message "System alert"
clawdbot message send --account smma --to "@marketing" --message "New post scheduled"
clawdbot message send --account support --to "987654321" --message "Ticket resolved"
```

## Gateway Integration

The ClawdBot Gateway manages all bot connections:

```bash
# Start gateway manually
clawdbot gateway

# Run as daemon (recommended)
clawdbot daemon enable
clawdbot daemon start

# Check gateway status
clawdbot gateway status
clawdbot health

# View gateway dashboard
# Open browser to: http://127.0.0.1:18789/
```

## Connection Flow

1. **Bot Token Added**: Via `clawdbot providers add`
2. **Gateway Starts**: Establishes connection to Telegram API
3. **Polling/Webhook**: Gateway handles updates automatically
4. **Message Routing**: Based on account ID specified
5. **Agent Processing**: Messages processed by ClawdBot agents

## Troubleshooting Connections

### Bot Not Responding
```bash
# 1. Check provider status
clawdbot providers status

# 2. Verify gateway is running
clawdbot daemon status

# 3. Check logs for errors
clawdbot logs --tail 50 | grep telegram

# 4. Test connection
clawdbot doctor
```

### Invalid Token Errors
```bash
# Verify token format (should be number:string)
echo "YOUR_TOKEN" | grep -E "^[0-9]+:[A-Za-z0-9_-]+$"

# Re-add with correct token
clawdbot providers add --provider telegram --account smma --token "CORRECT_TOKEN"
```

### Connection Timeouts
```bash
# Restart gateway
clawdbot daemon restart

# Check network connectivity
ping api.telegram.org

# Review firewall rules (Telegram uses port 443)
```

## Advanced Configuration

### Custom Webhook Setup
```bash
# ClawdBot handles this automatically, but for custom setups:
# Requires public HTTPS endpoint
# Configure reverse proxy to ClawdBot gateway port
```

### Rate Limiting
- Telegram allows 30 messages/second per bot
- ClawdBot handles rate limiting automatically
- Burst capacity: up to 20 messages

### Multiple Instances
```bash
# Run separate ClawdBot instances with different profiles
clawdbot --profile production gateway --port 18789
clawdbot --profile development gateway --port 18790
```

## Provider Status Codes

When running `clawdbot providers list`:

- **configured**: Bot token is set
- **token=config**: Token stored in configuration
- **enabled**: Provider is active
- **linked**: Currently connected (WhatsApp)
- **not configured**: No token/credentials set

## Backup and Migration

### Export Configuration
```bash
# Backup all provider configs
clawdbot providers list --json > providers_backup.json

# Backup entire ClawdBot config
cp -r ~/.clawdbot ~/.clawdbot_backup
```

### Import on New System
```bash
# Restore configuration
cp -r ~/.clawdbot_backup ~/.clawdbot

# Or manually re-add each bot
# (Recommended for security - generate new tokens)
```

## Security Best Practices

1. **Token Storage**
   - Never hardcode tokens in scripts
   - Use token files with 600 permissions
   - Store in password manager

2. **Access Control**
   - Limit bot permissions in groups
   - Use different bots for different security levels
   - Regularly audit bot access

3. **Monitoring**
   - Check logs regularly: `clawdbot logs`
   - Monitor for unauthorized usage
   - Set up alerts for errors

4. **Token Rotation**
   - Rotate tokens quarterly
   - Immediately rotate if compromised
   - Document rotation schedule