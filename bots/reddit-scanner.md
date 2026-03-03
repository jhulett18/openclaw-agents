# Reddit Scanner — Reddit Intelligence Bot

| Field | Value |
|-------|-------|
| **Handle** | `@redditscanscan_bot` |
| **Agent ID** | `reddit-scanner` |
| **Account ID** | `reddit-scanner` |
| **Workspace** | `/root/clawd/RedditScanner` |
| **SOUL.md** | `/root/clawd/RedditScanner/SOUL.md` |

## Purpose

Reddit Scanner is an automated intelligence bot that scrapes subreddits via Apify, deduplicates posts into a persistent database, and delivers daily reports to Telegram.

## How It Works

```
Apify Actor (Reddit Scraper)
        │
        ▼
  Scrape subreddits (configurable)
        │
        ▼
  Merge into posts.json (deduplicated)
        │
        ▼
  Generate markdown report
        │
        ▼
  Send report to Telegram as document
```

### Pipeline Details

1. **Scraping:** Apify's Reddit scraper actor fetches posts from configured subreddits
2. **Deduplication:** New posts are merged into `data/posts.json`, updating existing entries
3. **Report generation:** A markdown report summarizes new and trending posts
4. **Delivery:** The report is sent to Telegram as a document attachment

### Schedule

Runs daily at **9:00 AM ET** via cron (`0 9 * * *`).

## Key Integration: Apify

Reddit Scanner uses Apify for Reddit scraping. The API key is stored in an environment file:

```
/root/reddit-scanner/.env
```

The Apify key is validated by the OpenClaw Monitor against `https://api.apify.com/v2/users/me`.

### Current Configuration

- **Subreddits:** r/FashionReps (configurable)
- **Posts per scan:** 50
- **Comments per post:** 15
- **Sort order:** Hot

## Data Storage

| Path | Purpose |
|------|---------|
| `/root/reddit-scanner/data/posts.json` | Post database (deduplicated) |
| `/root/reddit-scanner/data/reports/` | Daily markdown reports |
| `/root/reddit-scanner/data/runs.log` | Run history |

## Personality (from SOUL.md)

- **Analytical and concise.** Deals in data, not opinions.
- **Direct.** "Last scan ran at 9:00 AM, scraped 50 posts, 12 new, 38 updated."
- **Proactive about data.** Pulls from `posts.json` for trends, checks `runs.log` for history.
- **Honest about limitations.** Only knows about subreddits it's configured to scan.

## Codebase

The Reddit Scanner is a Node.js TypeScript application at `/root/reddit-scanner/`.

## How Reddit Scanner Was Set Up

1. Created the bot via BotFather (`@redditscanscan_bot`)
2. Saved the token to `~/.clawdbot/tokens/reddit-scanner.token`
3. Added the `reddit-scanner` account to `clawdbot.json`
4. Created agent `reddit-scanner` with workspace `/root/clawd/RedditScanner`
5. Added binding: `reddit-scanner` → `reddit-scanner`
6. Wrote `SOUL.md` defining the scanner's data-oriented personality
7. Set up Apify API key in `/root/reddit-scanner/.env`
8. Configured cron job for daily 9 AM scans

## Files

| File | Purpose |
|------|---------|
| `/root/clawd/RedditScanner/SOUL.md` | Scanner's identity document |
| `/root/reddit-scanner/` | Scanner codebase (Node.js/TypeScript) |
| `/root/reddit-scanner/.env` | Apify API key |
| `/root/reddit-scanner/data/` | Post database and reports |
| `~/.clawdbot/tokens/reddit-scanner.token` | Bot API token |
