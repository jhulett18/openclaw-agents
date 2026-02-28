---
name: smma
description: Social Media Marketing Agency automation with GetLate API for multi-platform posting
metadata: {
  "openclaw": {
    "emoji": "📱",
    "requires": {
      "bins": ["python3"],
      "env": ["GETLATE_API_KEY"]
    },
    "install": [
      {
        "kind": "message",
        "text": "First, get your GetLate API key from https://getlate.dev"
      },
      {
        "kind": "bash",
        "script": "pip install requests python-dotenv click rich tabulate"
      }
    ]
  }
}
---

# SMMA - Social Media Marketing Agency Automation

Automate your social media marketing across 13+ platforms using GetLate API.

## Features
- 📊 Multi-platform posting (Twitter/X, Instagram, Facebook, LinkedIn, TikTok, YouTube, Pinterest, Reddit, Bluesky, Threads, Telegram, Snapchat, Google Business)
- 🖼️ Media upload and management
- 📅 Content scheduling and queues
- 📈 Analytics and performance tracking
- 🔄 Batch posting from CSV
- 👥 Profile and account management

## Commands

### Profile Management
- `smma profiles list` - List all GetLate profiles
- `smma profiles create <name>` - Create new profile
- `smma profiles delete <id>` - Delete a profile

### Account Connection
- `smma accounts connect <platform>` - Connect social media account
- `smma accounts list` - List connected accounts
- `smma accounts disconnect <id>` - Disconnect an account

### Content Posting
- `smma post` - Interactive post creation
- `smma post schedule` - Schedule a post with options
- `smma post batch <csv_file>` - Batch schedule from CSV

### Media Management
- `smma media upload <file>` - Upload media file
- `smma media list` - List uploaded media

### Analytics
- `smma analytics post <id>` - Get post performance
- `smma analytics summary` - Get overall analytics

## Setup

1. Get your API key from [GetLate](https://getlate.dev)
2. Set environment variable:
   ```bash
   export GETLATE_API_KEY="your_api_key_here"
   ```
3. Connect your social media accounts:
   ```bash
   clawdbot smma accounts connect twitter
   clawdbot smma accounts connect instagram
   # etc...
   ```

## Examples

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
```bash
clawdbot smma post batch content_calendar.csv
```

CSV format:
```csv
date,time,content,media,platforms
2024-02-20,10:00,"Morning motivation!",quote.jpg,"twitter,instagram"
2024-02-20,14:00,"New blog post",blog_header.png,"linkedin,facebook"
```

## Rate Limits
- Free tier: 60 requests/minute
- Build plan: 120 requests/minute  
- Accelerate plan: 600 requests/minute
- Unlimited plan: 1,200 requests/minute

## Support
For issues or questions about GetLate API, visit [docs.getlate.dev](https://docs.getlate.dev)