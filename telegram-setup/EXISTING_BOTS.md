# Current Telegram Bots Configuration

## Active Bots on This Instance

The following Telegram bots are currently configured and running on this ClawdBot instance:

| Account ID | Bot Name | Status | Purpose |
|------------|----------|--------|---------|
| `apartment` | Apartment Bot | ✅ Active | Property management, tenant communications, maintenance tracking |
| `default` | ClawdOps System Bot | ✅ Active | System monitoring, alerts, administrative tasks, health checks |
| `events` | Nightlife Guide Bot | ✅ Active | Event management, venue listings, party announcements, RSVP tracking |
| `resumebot` | Resume Bot | ✅ Active | Resume generation, CV optimization, job matching services |
| `smma` | SMMA Bot | ✅ Active | Social media marketing automation, content scheduling, analytics |

## Verifying Current Configuration

```bash
# Check all Telegram bots
clawdbot providers list | grep -A1 "Telegram"

# Get detailed status
clawdbot status

# Test a specific bot
clawdbot message send \
  --provider telegram \
  --account smma \
  --to "@test_channel" \
  --message "Test from SMMA Bot"
```

## Bot Token Management

### Current Setup
All bots are configured with `token=config`, meaning tokens are securely stored in ClawdBot's configuration.

### Exporting Configuration (for backup or migration)

```bash
# Create backup directory
mkdir -p ~/clawdbot_backup

# Export provider configurations (tokens encrypted)
clawdbot providers list --json > ~/clawdbot_backup/providers.json

# Backup entire ClawdBot configuration
cp -r ~/.clawdbot ~/clawdbot_backup/clawdbot_config

# Create encrypted archive
tar -czf ~/clawdbot_backup_$(date +%Y%m%d).tar.gz ~/clawdbot_backup
```

## Setting Up These Bots on a New Instance

### Option 1: Fresh Setup with New Tokens (Recommended)

For each bot, create new tokens via @BotFather and add to ClawdBot:

```bash
# 1. Apartment Bot
clawdbot providers add \
  --provider telegram \
  --account apartment \
  --name "Apartment Bot" \
  --token "NEW_TOKEN_FROM_BOTFATHER"

# 2. System Bot (default)
clawdbot providers add \
  --provider telegram \
  --account default \
  --name "ClawdOps System Bot" \
  --token "NEW_TOKEN_FROM_BOTFATHER"

# 3. Events Bot
clawdbot providers add \
  --provider telegram \
  --account events \
  --name "Nightlife Guide Bot" \
  --token "NEW_TOKEN_FROM_BOTFATHER"

# 4. Resume Bot
clawdbot providers add \
  --provider telegram \
  --account resumebot \
  --name "Resume Bot" \
  --token "NEW_TOKEN_FROM_BOTFATHER"

# 5. SMMA Bot
clawdbot providers add \
  --provider telegram \
  --account smma \
  --name "SMMA Bot" \
  --token "NEW_TOKEN_FROM_BOTFATHER"
```

### Option 2: Migration with Existing Tokens

If you need to use the same bot tokens on the new instance:

1. **On current machine**: Extract tokens
```bash
# Tokens are stored encrypted, need to extract from running config
# This requires access to the current running instance
```

2. **Transfer securely**: Use encrypted transfer method
```bash
# Use SSH/SCP or encrypted file transfer
scp ~/clawdbot_backup.tar.gz user@newserver:~/
```

3. **On new machine**: Restore configuration
```bash
# Extract backup
tar -xzf clawdbot_backup.tar.gz

# Restore ClawdBot configuration
cp -r ~/clawdbot_backup/clawdbot_config ~/.clawdbot
```

## Bot Responsibilities

### Apartment Bot (`apartment`)
- **Purpose**: Property management automation
- **Features**:
  - Tenant communication
  - Maintenance request tracking
  - Rent reminders
  - Property announcements
  - Emergency notifications

### ClawdOps System Bot (`default`)
- **Purpose**: System operations and monitoring
- **Features**:
  - Server health monitoring
  - Error alerts
  - Backup notifications
  - Cron job results
  - Admin commands

### Nightlife Guide Bot (`events`)
- **Purpose**: Event and nightlife management
- **Features**:
  - Event creation and listing
  - Venue information
  - Party announcements
  - RSVP management
  - Event reminders

### Resume Bot (`resumebot`)
- **Purpose**: Career services automation
- **Features**:
  - Resume generation from templates
  - CV optimization suggestions
  - Job matching based on skills
  - Interview preparation tips
  - Career advice

### SMMA Bot (`smma`)
- **Purpose**: Social media marketing automation
- **Features**:
  - Multi-platform posting
  - Content scheduling
  - Analytics reporting
  - Campaign management
  - Engagement tracking

## Channel and Group Associations

Each bot typically manages specific channels/groups:

```bash
# Example channel structure (customize for your setup)
@apartment_announcements    # Apartment Bot
@system_alerts              # System Bot (default)
@nightlife_events           # Events Bot
@career_tips                # Resume Bot
@marketing_updates          # SMMA Bot
```

## Monitoring Bot Health

### Individual Bot Check
```bash
# Check specific bot
clawdbot providers status | grep -A3 "Telegram smma"
```

### All Bots Health Check
```bash
# Full system status
clawdbot doctor

# Provider status with details
clawdbot providers status --deep
```

### View Logs
```bash
# Recent Telegram activity
clawdbot logs --tail 100 | grep -i telegram

# Specific bot logs
clawdbot logs --tail 50 | grep "smma"
```

## Maintenance Tasks

### Daily Checks
```bash
# Quick health check
clawdbot status
```

### Weekly Tasks
```bash
# Review logs for errors
clawdbot logs --tail 500 | grep -i error

# Check message statistics
clawdbot providers status --deep
```

### Monthly Tasks
- Review bot permissions in Telegram
- Check for BotFather updates
- Verify channel associations
- Review and rotate tokens if needed

## Troubleshooting Common Issues

### Bot Offline
```bash
# Restart the gateway
clawdbot daemon restart

# Check provider configuration
clawdbot providers list | grep telegram
```

### Message Not Sending
```bash
# Test bot connection
clawdbot doctor

# Check specific bot
clawdbot message send \
  --provider telegram \
  --account smma \
  --to "@test" \
  --message "test" \
  --verbose
```

### Token Issues
1. Verify with @BotFather that bot still exists
2. Check token hasn't been revoked
3. Generate new token if needed
4. Update in ClawdBot

## Migration Checklist

When setting up on a new server:

- [ ] Install ClawdBot: `npm install -g clawdbot`
- [ ] Initialize: `clawdbot setup`
- [ ] Create/restore bot tokens
- [ ] Add each bot to ClawdBot
- [ ] Test each bot connection
- [ ] Verify channel permissions
- [ ] Set up monitoring (cron jobs)
- [ ] Configure auto-start: `clawdbot daemon enable`
- [ ] Test message sending
- [ ] Document any custom configurations

## Security Notes

1. **Token Security**
   - Each bot token provides full control of that bot
   - Never share tokens publicly
   - Store securely with restricted permissions

2. **Access Control**
   - Each bot should have minimal required permissions
   - Use separate bots for different security levels
   - Regularly audit bot access to channels/groups

3. **Monitoring**
   - Set up alerts for bot failures
   - Monitor for unauthorized usage
   - Keep logs for audit purposes