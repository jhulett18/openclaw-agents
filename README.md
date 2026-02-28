# OpenClaw Agents - Instance Setup Documentation

**This repository contains documentation and setup instructions only. No executable code is included.**

## Purpose

This repository serves as a knowledge base for setting up ClawdBot agents on a new server instance, with a focus on Telegram bot configuration and system monitoring tools. It documents how to replicate the current working setup without relying on third-party services.

## What This Repository Contains

- 📚 **Documentation**: Step-by-step guides for bot setup
- 🤖 **Bot Configuration**: Instructions for Telegram bot creation and connection
- 🛠️ **Management Scripts**: Monitoring and recovery tools
- 📋 **Best Practices**: Security, backup, and maintenance procedures

## What This Repository Does NOT Contain

- ❌ No API keys or tokens
- ❌ No executable bot code
- ❌ No third-party service dependencies
- ❌ No GetLate or other proxy services

## System Architecture

```
Your Server
    ↓
ClawdBot Gateway (Port 18789)
    ↓
Direct Connection to Telegram Bot API
    ↓
Telegram Users/Channels/Groups
```

## Quick Start Guide

### 1. Install ClawdBot

```bash
# Install globally via npm
npm install -g clawdbot

# Initialize ClawdBot
clawdbot setup

# Start the gateway
clawdbot gateway

# Or run as daemon (recommended)
clawdbot daemon enable
clawdbot daemon start
```

### 2. Create Telegram Bot

1. Open Telegram and message **@BotFather**
2. Send `/newbot` and follow prompts
3. Save the bot token provided

### 3. Connect Bot to ClawdBot

```bash
# Add bot to ClawdBot
clawdbot providers add \
  --provider telegram \
  --account mybotname \
  --name "My Bot Name" \
  --token "BOT_TOKEN_FROM_BOTFATHER"

# Verify connection
clawdbot providers list | grep telegram

# Send test message
clawdbot message send \
  --provider telegram \
  --account mybotname \
  --to @channel_name \
  --message "Hello World!"
```

## Current Bot Fleet

This instance runs 5 specialized Telegram bots:

| Bot Name | Account ID | Purpose |
|----------|------------|---------|
| **Apartment Bot** | `apartment` | Property management and tenant communications |
| **ClawdOps System Bot** | `default` | System monitoring, alerts, and admin tasks |
| **Nightlife Guide Bot** | `events` | Event management and announcements |
| **Resume Bot** | `resumebot` | Resume generation and career services |
| **SMMA Bot** | `smma` | Social media marketing automation |

## Documentation Structure

```
openclaw-agents/
├── README.md                           # This file
├── telegram-setup/                     # Telegram bot documentation
│   ├── TELEGRAM_BOT_SETUP.md         # Complete setup guide
│   ├── BOT_CREATION.md               # BotFather tutorial
│   ├── CLAWDBOT_CONNECTION.md        # Provider configuration details
│   └── EXISTING_BOTS.md              # Current bot configurations
├── skills/
│   └── smma/                          # SMMA bot documentation
│       ├── SKILL.md                  # Skill description
│       └── README.md                  # Setup instructions
└── management/                         # System management scripts
    ├── auto-recovery.sh               # Automated recovery script
    ├── health-monitor.sh              # Health monitoring
    ├── monitoring-dashboard.sh        # Dashboard script
    └── sandbox-setup.sh               # Docker sandbox setup
```

## Key Features

### Direct Telegram Connection
- **No middleman services** - Direct Bot API connection
- **Lower latency** - No proxy overhead
- **Full control** - All bot features available
- **Better security** - Tokens stay on your server

### Multi-Bot Support
- Run unlimited bots from one instance
- Each bot has unique account ID
- Individual bot monitoring and control
- Separate configurations per bot

### Integrated Monitoring
- Health checks every 2 hours
- Auto-recovery from failures
- Real-time status dashboard
- Comprehensive logging

## Setup New Instance

### Prerequisites
- Linux/macOS/Windows with WSL
- Node.js 18+ and npm
- Python 3.8+ (for some skills)
- Internet connection
- Telegram account

### Installation Steps

1. **Clone this repository**
   ```bash
   git clone https://github.com/yourusername/openclaw-agents.git
   cd openclaw-agents
   ```

2. **Install ClawdBot**
   ```bash
   npm install -g clawdbot
   clawdbot setup
   ```

3. **Follow the guides**
   - Start with `telegram-setup/TELEGRAM_BOT_SETUP.md`
   - Create bots using `telegram-setup/BOT_CREATION.md`
   - Configure providers via `telegram-setup/CLAWDBOT_CONNECTION.md`

4. **Set up monitoring** (optional)
   ```bash
   chmod +x management/*.sh
   crontab -e
   # Add: */120 * * * * /path/to/management/health-monitor.sh
   ```

## Security Best Practices

### Token Management
- **Never commit tokens to Git**
- **Use token files** with restrictive permissions (600)
- **Rotate tokens** quarterly or if compromised
- **Store securely** in password managers

### Access Control
- Each bot should have minimal required permissions
- Use different bots for different security levels
- Regularly audit bot access to channels/groups
- Monitor logs for unauthorized usage

### Backup Strategy
```bash
# Backup configuration
cp -r ~/.clawdbot ~/.clawdbot_backup_$(date +%Y%m%d)

# Export providers
clawdbot providers list --json > providers_backup.json

# Create encrypted archive
tar -czf clawdbot_backup_$(date +%Y%m%d).tar.gz ~/.clawdbot_backup_*
```

## Common Commands

### Bot Management
```bash
# List all bots
clawdbot providers list

# Add new bot
clawdbot providers add --provider telegram --account newbot --token "TOKEN"

# Remove bot
clawdbot providers remove --provider telegram --account oldbot

# Check status
clawdbot status
```

### Message Operations
```bash
# Send to channel
clawdbot message send --provider telegram --account smma --to @channel --message "text"

# Send to user (by ID)
clawdbot message send --provider telegram --account support --to 123456789 --message "text"

# Send to group
clawdbot message send --provider telegram --account events --to -1001234567890 --message "text"
```

### System Control
```bash
# Gateway management
clawdbot gateway                    # Start manually
clawdbot daemon start               # Start as service
clawdbot daemon stop                # Stop service
clawdbot daemon restart             # Restart service

# Health checks
clawdbot doctor                     # Full system check
clawdbot providers status --deep    # Detailed provider status

# Logs
clawdbot logs --tail 100           # View recent logs
clawdbot logs --tail 50 | grep telegram  # Filter for Telegram
```

## Troubleshooting

### Bot Not Responding
1. Check gateway status: `clawdbot daemon status`
2. Verify bot token: `clawdbot providers list`
3. Test connection: `clawdbot doctor`
4. Restart if needed: `clawdbot daemon restart`

### Invalid Token
1. Verify with @BotFather
2. Regenerate if needed
3. Update in ClawdBot
4. Test connection

### Connection Issues
1. Check network: `ping api.telegram.org`
2. Verify firewall (port 443 required)
3. Check logs: `clawdbot logs --tail 100`
4. Restart gateway

## Migration Checklist

When setting up a new instance:

- [ ] Install ClawdBot
- [ ] Initialize configuration
- [ ] Create/import bot tokens
- [ ] Add each bot to ClawdBot
- [ ] Test each bot connection
- [ ] Verify channel/group access
- [ ] Set up monitoring scripts
- [ ] Configure auto-start daemon
- [ ] Test message sending
- [ ] Document custom configurations

## Important Notes

1. **This is documentation only** - No running code included
2. **Direct connections only** - No third-party APIs
3. **Security first** - Never expose tokens
4. **Test everything** - Verify each step works

## Support Resources

- **ClawdBot Docs**: https://docs.openclaw.ai/
- **Telegram Bot API**: https://core.telegram.org/bots
- **BotFather**: https://t.me/botfather
- **This Repository**: Documentation and guides

## Contributing

This repository is meant for documentation and knowledge transfer. When updating:
1. Keep documentation clear and concise
2. Update based on actual working configurations
3. Never include real tokens or sensitive data
4. Test all instructions on a fresh system

## License

Documentation and scripts provided as-is for setting up ClawdBot instances.