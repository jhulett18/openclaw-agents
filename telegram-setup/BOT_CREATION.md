# Creating Telegram Bots with BotFather

## Complete Guide to BotFather

BotFather is Telegram's official bot for creating and managing other bots. This guide covers everything you need to know.

## Starting with BotFather

1. **Find BotFather**
   - Open Telegram
   - Search for `@BotFather` (look for the blue checkmark)
   - Start a chat

2. **BotFather Commands**
   ```
   /newbot - Create a new bot
   /mybots - Edit your existing bots
   /setname - Change bot's name
   /setdescription - Change bot's description
   /setabouttext - Change bot's about info
   /setuserpic - Change bot's profile photo
   /setcommands - Change bot command list
   /deletebot - Delete a bot
   /token - Get bot token
   /revoke - Revoke bot token
   /setinline - Toggle inline mode
   /setinlinegeo - Toggle inline location requests
   /setinlinefeedback - Set inline feedback settings
   /setjoingroups - Toggle group join ability
   /setprivacy - Toggle privacy mode
   ```

## Creating Your First Bot

### Step-by-Step Process

1. **Send `/newbot` to BotFather**

2. **Choose a display name**
   - This is what users see
   - Can contain spaces and special characters
   - Examples: "SMMA Marketing Bot", "Customer Support", "Event Manager"

3. **Choose a username**
   - Must end with 'bot' or '_bot'
   - Must be unique across all Telegram
   - No spaces allowed, use underscores
   - Examples: `smma_marketing_bot`, `support_helper_bot`, `EventManagerBot`

4. **Receive your bot token**
   - Looks like: `1234567890:ABCdefGHIjklMNOpqrsTUVwxyz`
   - Keep this SECRET - it's like a password
   - Anyone with the token can control your bot

## Configuring Bot Settings

### Essential Settings

After creating your bot, send `/mybots` and select your bot to configure:

#### 1. Bot Description (`/setdescription`)
What users see when viewing bot profile:
```
This bot helps you manage social media marketing campaigns across multiple platforms. Features include scheduling, analytics, and automated posting.
```

#### 2. About Text (`/setabouttext`)
Short text shown before user starts chat (max 120 chars):
```
I help you automate social media marketing. Send /help to get started!
```

#### 3. Profile Picture (`/setuserpic`)
- Use a 512x512px image
- PNG or JPG format
- Clear, recognizable icon
- Matches your brand

#### 4. Command List (`/setcommands`)
Define commands users can select from menu:
```
help - Show help message
start - Start the bot
status - Check bot status
post - Create a new post
schedule - Schedule content
analytics - View analytics
settings - Bot settings
cancel - Cancel current operation
```

Format for BotFather:
```
help - Show help message
start - Start the bot
status - Check bot status
```

### Advanced Settings

#### Privacy Mode (`/setprivacy`)
- **Enabled** (default): Bot only sees messages starting with `/` in groups
- **Disabled**: Bot sees all messages in groups
- Disable for: moderation bots, keyword monitoring

#### Group Settings (`/setjoingroups`)
- **Enabled**: Bot can be added to groups
- **Disabled**: Bot works only in private chats

#### Inline Mode (`/setinline`)
Allows users to use your bot in any chat by typing `@yourbotname query`
- Enable for: search bots, content bots, utility bots
- Requires additional programming

## Bot Types and Use Cases

### 1. System/Monitoring Bot
```
Name: System Monitor
Username: my_system_monitor_bot
Description: Monitors system health and sends alerts
Privacy: Enabled
Groups: Enabled (for team alerts)
```

### 2. Marketing/SMMA Bot
```
Name: SMMA Marketing Assistant
Username: smma_assistant_bot
Description: Automates social media marketing tasks
Privacy: Disabled (to monitor keywords)
Groups: Enabled (for team collaboration)
```

### 3. Customer Support Bot
```
Name: Support Helper
Username: company_support_bot
Description: Handles customer inquiries and tickets
Privacy: Enabled
Groups: Disabled (private support only)
```

### 4. Event Management Bot
```
Name: Event Coordinator
Username: event_coordinator_bot
Description: Manages events, RSVPs, and reminders
Privacy: Disabled (to track event mentions)
Groups: Enabled (for event groups)
```

## Token Management

### Getting Your Token
1. Send `/mybots` to BotFather
2. Select your bot
3. Select "API Token"

### Revoking a Token (if compromised)
1. Send `/mybots` to BotFather
2. Select your bot
3. Select "Revoke current token"
4. Update token in ClawdBot configuration

### Token Security Rules
- Never share tokens publicly
- Don't commit tokens to Git
- Store in environment variables or secure files
- Rotate tokens periodically
- Use different tokens for dev/prod

## Multiple Bot Strategy

### Why Multiple Bots?
- Separation of concerns
- Different permission levels
- Specialized functionality
- Better organization

### Recommended Bot Setup
```
1. default (System Bot) - Monitoring, alerts, admin tasks
2. smma (Marketing Bot) - Social media automation
3. support (Support Bot) - Customer service
4. events (Events Bot) - Event management
5. analytics (Analytics Bot) - Reporting and insights
```

## Deleting a Bot

If you need to delete a bot:
1. Send `/mybots` to BotFather
2. Select the bot to delete
3. Select "Delete Bot"
4. Confirm deletion
5. Remove from ClawdBot: `clawdbot providers remove --provider telegram --account botname`

## Common Issues and Solutions

### "Username already taken"
- Try variations: `mybot_v2`, `mybot_official`, `company_mybot`
- Add descriptive suffixes: `mybot_support`, `mybot_admin`

### "Invalid username"
- Must end with 'bot' or '_bot'
- No spaces (use underscores)
- Only letters, numbers, and underscores

### Lost token
- Can't be recovered, must revoke and generate new one
- Update all systems using the old token

## Bot Limits

- **Username length**: 5-32 characters
- **About text**: 120 characters
- **Description**: 512 characters
- **Commands**: Up to 100 commands
- **Command name**: 1-32 characters
- **Command description**: 3-256 characters

## Best Practices

1. **Naming Convention**
   - Use consistent prefixes for related bots
   - Make purpose clear in the name

2. **Profile Setup**
   - Professional profile picture
   - Clear, concise descriptions
   - Comprehensive command list

3. **Security**
   - Unique token for each bot
   - Regular token rotation
   - Monitor bot usage

4. **Documentation**
   - Document each bot's purpose
   - Keep token storage location documented
   - Maintain bot configuration list