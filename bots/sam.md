# Sam — Social Media Marketing Assistant

| Field | Value |
|-------|-------|
| **Handle** | `@socialmediasam112bot` |
| **Agent ID** | `main` |
| **Account ID** | `production-smma` |
| **Workspace** | `/root/clawd` |
| **SOUL.md** | `/root/clawd/SOUL.md` |

## Purpose

Sam is a social media marketing assistant built for managing SMMA (Social Media Marketing Agency) operations. He handles content creation, scheduling, cross-platform posting, analytics, and audience growth for multiple clients.

## Key Integrations

### GetLate.dev

Sam's primary tool for social media operations. The `getlate` skill provides:

- Cross-platform posting (LinkedIn connected)
- Content scheduling and queue management
- Analytics and performance tracking
- Account management across clients

Configuration in `clawdbot.json`:

```json
{
  "skills": {
    "entries": {
      "getlate": {
        "enabled": true,
        "apiKey": "YOUR_GETLATE_API_KEY"
      }
    }
  }
}
```

### Gemini Media

Sam can generate images and videos for social media content using the `gemini-media` skill:

```json
{
  "skills": {
    "entries": {
      "gemini-media": {
        "enabled": true,
        "apiKey": "YOUR_GEMINI_API_KEY"
      }
    }
  }
}
```

### Client Dashboard

A web dashboard for SMMA clients runs at `localhost:3000`:

- Clients log in to chat with their bot, create content, and view analytics
- Backend: Node.js with SQLite database at `/root/sam-dashboard/sam.db`
- Start: `cd /root/sam-dashboard && npm run dev`

## Personality (from SOUL.md)

- **Casual and clever.** Talks like a teammate, not a tool.
- **Has opinions about content.** Pushes back on bad ideas, suggests better angles.
- **Draft freely, publish never (without approval).** Creates content but never posts without explicit go-ahead.
- **Resourceful before asking.** Checks the queue, reads the brief, pulls analytics — then comes with recommendations, not questions.

## Multi-Client Management

Sam manages multiple SMMA clients. Each client has:

- A workspace at `/root/clawd-clients/{slug}/`
- An entry in the dashboard database
- Platform accounts linked via GetLate

### Client Workflow

1. Clients create posts via the web dashboard
2. Posts are saved as `pending_approval`
3. Sam checks for pending posts during heartbeat cycles
4. Admin approves/rejects via Telegram
5. Approved posts are published via GetLate

### Heartbeat Monitoring

Sam runs heartbeat checks on:

- **Pending approvals** — flags anything waiting more than a few hours
- **Failed posts** — posts that need retry or attention
- **Upcoming schedules** — posts with `scheduled_at` approaching in the next hour

## How Sam Was Set Up

1. Created the bot via BotFather (`@socialmediasam112bot`)
2. Saved the token to `~/.clawdbot/tokens/production-smma.token`
3. Added the `production-smma` account to `clawdbot.json`
4. Created agent `main` with workspace `/root/clawd`
5. Added binding: `production-smma` → `main`
6. Wrote `SOUL.md` defining Sam's SMMA-focused personality
7. Configured GetLate and Gemini Media skills
8. Set up the client dashboard at `/root/sam-dashboard/`

## Files

| File | Purpose |
|------|---------|
| `/root/clawd/SOUL.md` | Sam's identity document |
| `/root/sam-dashboard/` | Client web dashboard |
| `/root/sam-dashboard/sam.db` | SQLite database |
| `/root/clawd-clients/` | Per-client workspaces |
| `~/.clawdbot/tokens/production-smma.token` | Bot API token |
