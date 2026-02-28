# OpenClaw Agents Collection

A comprehensive collection of OpenClaw agents for social media automation, monitoring, and management. This repository includes the SMMA (Social Media Marketing Agency) bot with full management and monitoring capabilities.

## Features

### SMMA Bot
- **Multi-platform posting** - Support for 13+ social media platforms
- **Media management** - Upload and manage images/videos
- **Content scheduling** - Schedule posts for optimal engagement
- **Batch processing** - Import content calendars via CSV
- **Analytics tracking** - Monitor post performance
- **Profile management** - Handle multiple brand profiles

### Supported Platforms
- Twitter/X
- Instagram
- Facebook
- LinkedIn
- TikTok
- YouTube
- Pinterest
- Reddit
- Bluesky
- Threads
- Google Business
- Telegram
- Snapchat

### Management Tools
- **Health monitoring** - Automated health checks every 2 hours
- **Auto-recovery** - Self-healing from common failures
- **Monitoring dashboard** - Real-time status monitoring
- **Docker sandboxing** - Secure execution environment

## Quick Start

### Prerequisites
- Python 3.8+
- pip
- ClawdBot CLI installed
- GetLate API key (get from [getlate.dev](https://getlate.dev))

### Installation

#### Method 1: Automated Install
```bash
# Clone the repository
git clone https://github.com/yourusername/openclaw-agents.git
cd openclaw-agents

# Run the installer
chmod +x install.sh
./install.sh
```

#### Method 2: Manual Install
```bash
# Clone the repository
git clone https://github.com/yourusername/openclaw-agents.git
cd openclaw-agents

# Install SMMA skill
clawdbot mcp add smma ./skills/smma

# Install Python dependencies
pip install -r skills/smma/requirements.txt

# Set up environment variable
export GETLATE_API_KEY="your_api_key_here"
echo 'export GETLATE_API_KEY="your_api_key_here"' >> ~/.bashrc

# Set up monitoring (optional)
chmod +x management/*.sh
crontab -e
# Add: */120 * * * * /path/to/openclaw-agents/management/health-monitor.sh
```

## Configuration

### Environment Variables
Create a `.env` file in your home directory:
```bash
GETLATE_API_KEY=your_api_key_here
```

### GetLate Setup
1. Sign up at [getlate.dev](https://getlate.dev)
2. Get your API key from the dashboard
3. Set the environment variable as shown above

### Connect Social Media Accounts
```bash
# List available profiles
clawdbot smma profiles list

# Create a new profile
clawdbot smma profiles create "My Brand"

# Connect social media accounts
clawdbot smma accounts connect twitter
clawdbot smma accounts connect instagram
clawdbot smma accounts connect linkedin
# ... etc
```

## Usage

### Interactive Posting
```bash
# Create a post interactively
clawdbot smma post
```

### Quick Post to All Platforms
```bash
clawdbot smma post --content "Exciting news!" --media photo.jpg --platforms all
```

### Schedule a Post
```bash
clawdbot smma post schedule \
  --content "Check out our latest product!" \
  --media product.jpg \
  --platforms twitter,instagram,linkedin \
  --date "2024-02-20" \
  --time "14:00"
```

### Batch Posting from CSV
Create a CSV file with your content calendar:
```csv
date,time,content,media,platforms
2024-02-20,10:00,"Morning motivation!",quote.jpg,"twitter,instagram"
2024-02-20,14:00,"New blog post",blog_header.png,"linkedin,facebook"
```

Then run:
```bash
clawdbot smma post batch content_calendar.csv
```

### Analytics
```bash
# View post analytics
clawdbot smma analytics summary

# Get specific post metrics
clawdbot smma analytics post <post_id>
```

### Profile Management
```bash
# List profiles
clawdbot smma profiles list

# Create profile
clawdbot smma profiles create "Brand Name"

# Delete profile
clawdbot smma profiles delete <profile_id>
```

### Account Management
```bash
# List connected accounts
clawdbot smma accounts list

# Connect account
clawdbot smma accounts connect <platform>

# Disconnect account
clawdbot smma accounts disconnect <account_id>
```

## Monitoring & Management

### Health Monitoring
The health monitor runs automated checks and recovery:
```bash
# Manual health check
./management/health-monitor.sh

# Set up automated monitoring (runs every 2 hours)
crontab -e
# Add: 0 */2 * * * /path/to/management/health-monitor.sh
```

### Auto-Recovery
Automatically recovers from common failures:
```bash
# Run auto-recovery
./management/auto-recovery.sh

# Features:
# - Daemon restart on failure
# - Provider reconnection
# - API limit management
# - Failed cron job recovery
# - Docker sandbox cleanup
```

### Monitoring Dashboard
Interactive real-time monitoring:
```bash
./management/monitoring-dashboard.sh
```

### Docker Sandbox (Optional)
Set up isolated execution environment:
```bash
./management/sandbox-setup.sh
```

## API Rate Limits

GetLate API rate limits by plan:
- **Free tier**: 60 requests/minute
- **Build plan**: 120 requests/minute  
- **Accelerate plan**: 600 requests/minute
- **Unlimited plan**: 1,200 requests/minute

## Troubleshooting

### Common Issues

#### API Key Not Found
```bash
# Verify environment variable is set
echo $GETLATE_API_KEY

# Set it if missing
export GETLATE_API_KEY="your_api_key_here"
```

#### Connection Errors
```bash
# Check ClawdBot daemon status
clawdbot health

# Restart if needed
clawdbot daemon restart
```

#### Failed Posts
```bash
# Check cron job status
clawdbot cron list

# Retry failed jobs
clawdbot cron run <job_id>
```

### Logs
- Health monitor logs: `/tmp/clawdbot-health-*.log`
- Recovery logs: `/tmp/clawdbot-recovery-*.log`
- Main ClawdBot logs: Check `clawdbot logs`

## Development

### Project Structure
```
openclaw-agents/
├── skills/               # OpenClaw skill modules
│   └── smma/            # SMMA bot skill
├── management/          # Management scripts
├── install.sh           # Installation script
└── README.md           # This file
```

### Adding New Skills
1. Create a new directory under `skills/`
2. Include required files:
   - `SKILL.md` - Skill metadata
   - Python/bash implementation
   - `requirements.txt` - Dependencies
   - `setup.sh` - Setup script
3. Register with ClawdBot: `clawdbot mcp add <skill_name> ./skills/<skill_name>`

## Security

### Best Practices
- Never commit API keys to the repository
- Use environment variables for sensitive data
- Regularly rotate API keys
- Monitor usage and set up alerts
- Use Docker sandboxing for untrusted operations

### Permissions
The SMMA bot requires:
- Network access for API calls
- File system access for media uploads
- Environment variable access for API keys

## Support

### Resources
- GetLate Documentation: [docs.getlate.dev](https://docs.getlate.dev)
- OpenClaw Documentation: [docs.openclaw.ai](https://docs.openclaw.ai)
- ClawdBot Documentation: [docs.clawd.bot](https://docs.clawd.bot)

### Issues
For issues or questions:
1. Check the troubleshooting section
2. Review logs for error details
3. Open an issue on GitHub
4. Contact GetLate support for API issues

## License

MIT License - See LICENSE file for details

## Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## Acknowledgments

- GetLate API for social media platform integration
- OpenClaw framework for agent architecture
- ClawdBot for execution environment