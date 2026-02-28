# SMMA Clawdbot Skill - GetLate Integration

Social Media Marketing Agency automation skill for Clawdbot that enables posting across 13+ social media platforms using GetLate API.

## Quick Setup

### 1. Get Your GetLate API Key
Visit [https://getlate.dev](https://getlate.dev) to sign up and get your API key.

### 2. Set Environment Variable
Add this to your shell configuration file (`~/.bashrc`, `~/.zshrc`, or `~/.bash_profile`):

```bash
export GETLATE_API_KEY="your_api_key_here"
```

Then reload your shell:
```bash
source ~/.bashrc  # or ~/.zshrc
```

### 3. Install Dependencies
The skill will automatically install dependencies when first run, or you can install manually:
```bash
pip install requests python-dotenv click rich tabulate
```

### 4. Test the Skill
```bash
# Check if skill is available
clawdbot skills

# Test the skill
clawdbot smma profiles list
```

## Usage Examples

### First Time Setup
```bash
# 1. Create a profile
clawdbot smma profiles create "My Agency"

# 2. Connect your social accounts
clawdbot smma accounts connect twitter
clawdbot smma accounts connect instagram
clawdbot smma accounts connect linkedin
# Follow the OAuth URLs provided to authenticate

# 3. Verify connections
clawdbot smma accounts list
```

### Posting Content

#### Quick Post
```bash
# Post to all connected accounts
clawdbot smma post
# Follow the interactive prompts
```

#### Scheduled Post with Media
```bash
clawdbot smma post create
# Enter content: "Check out our latest product!"
# Add media? yes
# Media file path: /path/to/product.jpg
# Select accounts: all
# Post immediately? no
# Date: 2024-02-20
# Time: 14:00
# Timezone: America/New_York
```

### Batch Posting
Create a CSV file (`content_calendar.csv`):
```csv
date,time,content,media,platforms
2024-02-20,10:00,"Morning motivation! Start your day right",quote.jpg,"twitter,instagram"
2024-02-20,14:00,"New blog post: 10 Tips for Social Media Success",blog_header.png,"linkedin,facebook"
2024-02-20,18:00,"Thank you for 10K followers!",celebration.mp4,"twitter,instagram,tiktok"
```

Then run:
```bash
clawdbot smma post batch content_calendar.csv
```

### Analytics
```bash
# View recent posts
clawdbot smma analytics summary

# Get detailed analytics for a specific post
clawdbot smma analytics post post_abc123
```

## Supported Platforms
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

## Commands Reference

### Profile Management
- `smma profiles list` - List all GetLate profiles
- `smma profiles create <name>` - Create new profile
- `smma profiles delete <id>` - Delete a profile

### Account Management
- `smma accounts list` - List connected accounts
- `smma accounts connect <platform>` - Connect social account
- `smma accounts disconnect <id>` - Disconnect account

### Content Posting
- `smma post` - Interactive post creation
- `smma post create` - Create post with prompts
- `smma post batch <csv>` - Batch schedule from CSV
- `smma post list` - List all posts

### Media Management
- `smma media upload <file>` - Upload media file
- `smma media list` - List uploaded media

### Analytics
- `smma analytics summary` - Overview of recent posts
- `smma analytics post <id>` - Detailed post analytics

## Rate Limits
GetLate API rate limits based on your plan:
- **Free**: 60 requests/minute
- **Build**: 120 requests/minute
- **Accelerate**: 600 requests/minute
- **Unlimited**: 1,200 requests/minute

## Troubleshooting

### "GETLATE_API_KEY not set" Error
Make sure you've added the environment variable to your shell config:
```bash
echo 'export GETLATE_API_KEY="your_key"' >> ~/.bashrc
source ~/.bashrc
```

### OAuth Connection Issues
1. Make sure you're using the correct platform name
2. Visit the OAuth URL in your browser
3. Authorize the application
4. Check connection status with `smma accounts list`

### Media Upload Errors
- Supported formats: JPG, PNG, GIF, MP4, MOV
- Max file size varies by platform (usually 5-100MB)
- Check file path is correct and accessible

## Support
- GetLate API Documentation: [https://docs.getlate.dev](https://docs.getlate.dev)
- Report Issues: Create an issue in your repository