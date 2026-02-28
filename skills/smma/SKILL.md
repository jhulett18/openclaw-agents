---
name: telegram-bots
description: Documentation for setting up Telegram bots with ClawdBot for social media automation
metadata: {
  "openclaw": {
    "emoji": "🤖",
    "requires": {
      "bins": ["node", "npm"],
      "packages": ["clawdbot"]
    },
    "install": [
      {
        "kind": "message",
        "text": "This is documentation only. See telegram-setup/ directory for bot configuration guides."
      },
      {
        "kind": "message", 
        "text": "To set up Telegram bots, you need: 1) Bot tokens from @BotFather, 2) ClawdBot installed"
      }
    ]
  }
}
---

# Telegram Bots via ClawdBot

This skill provides documentation for setting up and managing Telegram bots directly through ClawdBot, without any third-party services.

## Overview

ClawdBot connects directly to Telegram's Bot API, providing:
- Direct bot management without middleman services
- Multi-bot support (run multiple bots from one instance)
- Native integration with ClawdBot's agent system
- Secure token management
- Built-in rate limiting and error handling

## Quick Setup

1. **Create Bot with @BotFather**
   ```
   /newbot
   Choose name: SMMA Marketing Bot
   Choose username: smma_marketing_bot
   Save token: 1234567890:ABCdefGHIjklMNOpqrsTUVwxyz
   ```

2. **Add to ClawdBot**
   ```bash
   clawdbot providers add \
     --provider telegram \
     --account smma \
     --name "SMMA Bot" \
     --token "YOUR_BOT_TOKEN"
   ```

3. **Verify Connection**
   ```bash
   clawdbot providers list | grep telegram
   clawdbot message send --provider telegram --account smma --to @channel --message "Hello!"
   ```

## Current Bot Configuration

This instance runs 5 specialized Telegram bots:

| Bot | Purpose | Account ID |
|-----|---------|------------|
| Apartment Bot | Property management | `apartment` |
| System Bot | Monitoring & alerts | `default` |
| Events Bot | Event management | `events` |
| Resume Bot | Career services | `resumebot` |
| SMMA Bot | Marketing automation | `smma` |

## Features

### Multi-Bot Management
- Run unlimited bots from single ClawdBot instance
- Each bot has unique account ID for routing
- Separate token and configuration per bot
- Individual bot monitoring and control

### Direct API Connection
- No proxy services or third-party APIs
- Direct connection: ClawdBot ↔ Telegram API
- Lower latency, higher reliability
- Full control over bot features

### Security
- Tokens stored securely in ClawdBot config
- Support for token files and environment variables
- Encrypted configuration backups
- Token rotation capabilities

### Integration
- Works with ClawdBot's agent system
- Supports cron jobs and automation
- WebSocket gateway for real-time processing
- Compatible with all ClawdBot skills

## Use Cases

### Social Media Marketing (SMMA)
- Schedule posts across platforms
- Automated content distribution
- Engagement tracking
- Campaign management
- Analytics reporting

### System Monitoring
- Server health alerts
- Error notifications
- Backup status reports
- Performance metrics
- Automated diagnostics

### Customer Support
- Ticket management
- FAQ responses
- Escalation routing
- Response automation
- Satisfaction tracking

### Event Management
- Event announcements
- RSVP collection
- Reminder notifications
- Venue updates
- Schedule changes

## Commands

### Provider Management
```bash
# Add bot
clawdbot providers add --provider telegram --account <id> --token <token>

# List all bots
clawdbot providers list

# Remove bot
clawdbot providers remove --provider telegram --account <id>

# Check status
clawdbot providers status
```

### Message Operations
```bash
# Send message
clawdbot message send --provider telegram --account <id> --to <recipient> --message "text"

# Send to channel
clawdbot message send --provider telegram --account smma --to @channel_name --message "text"

# Send to user
clawdbot message send --provider telegram --account support --to 123456789 --message "text"
```

### Gateway Control
```bash
# Start gateway
clawdbot gateway

# Enable daemon
clawdbot daemon enable
clawdbot daemon start

# Check health
clawdbot doctor
```

## Documentation

For complete setup instructions, see:
- `/telegram-setup/TELEGRAM_BOT_SETUP.md` - Complete setup guide
- `/telegram-setup/BOT_CREATION.md` - BotFather tutorial
- `/telegram-setup/CLAWDBOT_CONNECTION.md` - Provider configuration
- `/telegram-setup/EXISTING_BOTS.md` - Current bot details

## Support

- ClawdBot Documentation: https://docs.openclaw.ai/
- Telegram Bot API: https://core.telegram.org/bots/api
- BotFather: https://t.me/botfather

## Important Notes

This is a **documentation-only** skill. It provides instructions for setting up Telegram bots but contains no executable code. The actual bot functionality is handled entirely by ClawdBot's native Telegram provider system.