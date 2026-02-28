# Telegram Bots Documentation

This directory contains documentation for setting up Telegram bots through ClawdBot for social media marketing automation (SMMA) and other purposes.

## Important Notice

**This is documentation only.** No executable code is included. All bot functionality is provided by ClawdBot's native Telegram provider system.

## What's Included

- **SKILL.md** - Skill metadata and overview
- **This README** - Setup instructions and bot documentation

## How Telegram Bots Work with ClawdBot

ClawdBot connects directly to Telegram's Bot API without any intermediary services:

```
Your Server → ClawdBot Gateway → Telegram Bot API → Users
```

## Setting Up SMMA Bot

### 1. Create the Bot

1. Open Telegram and message @BotFather
2. Send `/newbot`
3. Name: "SMMA Marketing Bot"
4. Username: `your_smma_bot` (must end in 'bot')
5. Save the token provided

### 2. Configure in ClawdBot

```bash
# Add SMMA bot to ClawdBot
clawdbot providers add \
  --provider telegram \
  --account smma \
  --name "SMMA Marketing Bot" \
  --token "YOUR_BOT_TOKEN_HERE"
```

### 3. Configure Bot Settings

Back in @BotFather:
- `/setdescription` - "Social Media Marketing Automation Bot"
- `/setabouttext` - "I help automate your social media marketing"
- `/setcommands` - Add commands like:
  ```
  post - Create a new post
  schedule - Schedule content
  analytics - View analytics
  help - Show help message
  ```
- `/setprivacy` - Disable for group access

### 4. Test the Connection

```bash
# Verify bot is configured
clawdbot providers list | grep smma

# Send test message
clawdbot message send \
  --provider telegram \
  --account smma \
  --to @your_channel \
  --message "SMMA Bot is online!"
```

## SMMA Bot Features

Once configured, the SMMA bot can:

- **Content Distribution**: Send posts to multiple channels
- **Scheduling**: Queue messages for optimal timing
- **Analytics Reporting**: Share performance metrics
- **Campaign Updates**: Notify about campaign status
- **Team Coordination**: Communicate with marketing team

## Using SMMA Bot for Marketing

### Channel Strategy

Create dedicated channels for different purposes:
- `@brand_updates` - Public brand announcements
- `@marketing_team` - Private team coordination
- `@campaign_reports` - Analytics and reporting
- `@content_calendar` - Scheduled content preview

### Automation Examples

```bash
# Morning report
clawdbot message send \
  --provider telegram \
  --account smma \
  --to @marketing_team \
  --message "Daily metrics: 1.2K impressions, 145 engagements, 23 conversions"

# Content announcement
clawdbot message send \
  --provider telegram \
  --account smma \
  --to @brand_updates \
  --message "New blog post: '10 Marketing Trends for 2024' - Read more at..."

# Team notification
clawdbot message send \
  --provider telegram \
  --account smma \
  --to @marketing_team \
  --message "Campaign 'Summer Sale' is now live across all platforms!"
```

### Integration with Other Platforms

While this bot handles Telegram directly, you can coordinate with other platforms through ClawdBot's multi-provider system:

- WhatsApp (via web session)
- Discord (bot token)
- Slack (app/bot tokens)
- Signal (CLI integration)

## Security Considerations

### Token Security
- Store tokens in files, not command line
- Use environment variables for production
- Rotate tokens quarterly
- Never commit tokens to Git

### Access Control
- Limit bot admin privileges
- Use separate bots for public/private channels
- Regular audit of channel members
- Monitor bot usage logs

## Monitoring and Maintenance

### Health Checks
```bash
# Check bot status
clawdbot providers status | grep smma

# View recent activity
clawdbot logs --tail 50 | grep smma

# Test connectivity
clawdbot doctor
```

### Common Issues

**Bot not responding:**
- Check token validity with @BotFather
- Verify ClawdBot gateway is running
- Restart: `clawdbot daemon restart`

**Messages not sending:**
- Confirm bot has channel access
- Check rate limits (30 msg/sec)
- Verify recipient format (@channel or user ID)

## Best Practices

1. **Use Descriptive Account IDs**: `smma`, `support`, `alerts`
2. **Document Channel Purposes**: Keep a list of channels and their uses
3. **Regular Token Rotation**: Change tokens every 3 months
4. **Monitor Performance**: Check logs weekly
5. **Backup Configuration**: Export provider settings regularly

## Additional Resources

For complete documentation, see:
- `/telegram-setup/TELEGRAM_BOT_SETUP.md` - Full setup guide
- `/telegram-setup/BOT_CREATION.md` - BotFather details
- `/telegram-setup/CLAWDBOT_CONNECTION.md` - Provider configuration
- `/telegram-setup/EXISTING_BOTS.md` - Current bot list

## Support

- Telegram Bot API: https://core.telegram.org/bots
- BotFather: https://t.me/botfather
- ClawdBot Docs: https://docs.openclaw.ai/