# Agents

ClawdBot runs 5 specialized agents, each with its own workspace, identity, memory, and Telegram bot.

---

## Sam (main)

| Field | Value |
|-------|-------|
| **Agent ID** | `main` |
| **Identity** | Sam — AI marketing partner |
| **Emoji** | 📢 |
| **Vibe** | Casual & clever, witty |
| **Telegram Account** | `production-smma` |
| **Bot Username** | `@socialmediasam112bot` |
| **Workspace** | `/root/clawd` |
| **Agent Dir** | `/root/.clawdbot/agents/main/agent` |

### Purpose

Sam is the SMMA (Social Media Marketing Agency) right hand. Handles content strategy, scheduling, and client management. Uses GetLate.dev for cross-platform social media posting (LinkedIn, etc.).

### Key Resources

- **Dashboard**: `/root/sam-dashboard/` (localhost:3000)
- **Database**: `/root/sam-dashboard/sam.db` (SQLite)
- **Client workspaces**: `/root/clawd-clients/{slug}/`
- **Client onboarding**: `cd /root/sam-dashboard && npx tsx src/onboard.ts ...`
- **GetLate helper**: `~/clawd/skills/getlate/scripts/getlate.sh`
- **Gemini Media**: `~/clawd/skills/gemini-media/scripts/generate_image.py`, `generate_video.py`

### Cron Jobs

| Job | Schedule | Description |
|-----|----------|-------------|
| `weekly-review` | Sun 6pm ET | Goals, finances, deadlines summary |

### Heartbeat Checks

- GetLate queue (scheduled, failed posts)
- SQLite queries for pending_approval, failed, and upcoming scheduled posts

---

## Cici

| Field | Value |
|-------|-------|
| **Agent ID** | `cici` |
| **Identity** | Cici — AI automation engineer |
| **Emoji** | ⚙️ |
| **Vibe** | Sharp, methodical, production-minded |
| **Telegram Account** | `production-cici` |
| **Bot Username** | `@cicigogogo_codebot` |
| **Workspace** | `/root/clawd/CiciCoder` |
| **Agent Dir** | `/root/.clawdbot/agents/cici/agent` |

### Purpose

Senior automation engineer for "Automations with JT." Builds and maintains production systems for legal (Lawmatics, Clio, Smokeball) and hospitality clients. Philosophy: boring is beautiful, strict TypeScript, Zod at every boundary.

### Key Resources

- **Active project**: Firm Schedule Assistant (`LE-TSS/remix-of-firm-schedule-assistant`)
- **Local path**: `/root/clawd/CiciCoder/remix-of-firm-schedule-assistant/`
- **GitHub helper**: `~/clawd/skills/github/scripts/gh-repo.sh`
- **Integrations**: Lawmatics, Smokeball, Clio, Monday CRM, Microsoft Graph API, Supabase

### Cron Jobs

| Job | Schedule | Description |
|-----|----------|-------------|
| `daily-codebase-map` | Daily 10am ET | Firm Schedule Assistant phases/edge functions/APIs summary |
| `zoom-email-reminder` | One-shot (ran) | Zoom integration email reminder |

### Heartbeat Checks

- CI failed workflows > 24h
- Supabase health
- Idle PRs > 48h
- Endpoint monitoring
- Improvement backlog review (items > 7 days, surface top 3)

---

## Reddit Scanner

| Field | Value |
|-------|-------|
| **Agent ID** | `reddit-scanner` |
| **Identity** | Reddit Scanner — AI intelligence analyst |
| **Emoji** | 📡 |
| **Vibe** | Data-focused, concise, analytical |
| **Telegram Account** | `reddit-scanner` |
| **Bot Username** | `@redditscanscan_bot` |
| **Workspace** | `/root/clawd/RedditScanner` |
| **Agent Dir** | `/root/.clawdbot/agents/reddit-scanner/agent` |

### Purpose

Reddit intelligence bot. Scrapes Reddit via Apify, deduplicates posts, generates markdown reports, and delivers them to Telegram.

### Key Resources

- **Codebase**: `/root/reddit-scanner/`
- **Config**: `/root/reddit-scanner/config.json`
- **Data**: `/root/reddit-scanner/data/posts.json`
- **Bot token**: `/root/reddit-scanner/.bot-token`
- **Env**: `/root/reddit-scanner/.env` (contains `APIFY_API_KEY`)

### Scanner Configuration

```json
{
  "subreddits": ["FashionReps"],
  "postsPerSubreddit": 50,
  "commentsPerPost": 15,
  "sort": "hot",
  "apifyActorId": "harshmaur/reddit-scraper",
  "telegramChatId": "<chat-id>",
  "schedule": "0 9 * * *"
}
```

### Cron Jobs

| Job | Schedule | Description |
|-----|----------|-------------|
| `afternoon-improvement` | Daily 12:45pm ET | One concrete improvement suggestion |
| `evening-improvement` | Daily 9pm ET | One concrete improvement suggestion |

### Heartbeat Checks

- Last run status from `runs.log`
- Storage size (warn > 3GB)
- Today's report presence

---

## MicroMonitor (openclaw-monitor)

| Field | Value |
|-------|-------|
| **Agent ID** | `openclaw-monitor` |
| **Identity** | MicroMonitor — AI ops watchdog |
| **Emoji** | 🔍 |
| **Vibe** | Terse, status-oriented, vigilant |
| **Telegram Account** | `production-openclaw` |
| **Bot Username** | `@micromonitorrrrr_bot` |
| **Workspace** | `/root/openclaw-monitor` |
| **Agent Dir** | `/root/.clawdbot/agents/openclaw-monitor/agent` |

### Purpose

Ops watchdog for the ClawdBot ecosystem. Runs `monitor_agent.py` every 15 minutes. Monitors gateway, credentials, cron, logs, system resources, dashboard, and session coherence.

### Key Resources

- **Monitor script**: `/root/openclaw-monitor/monitor_agent.py`
- **Config**: `/root/openclaw-monitor/monitor_config.yaml`
- **Reports**: `/root/openclaw-monitor/reports/`
- **Usage**: `python3 monitor_agent.py [--json] [--save] [--quiet] [--telegram]`

### Alert Thresholds

| Metric | Threshold | Level |
|--------|-----------|-------|
| Gateway response time | > 5000ms | WARN |
| Log errors/day | > 50 | WARN |
| Memory usage | > 85% | WARN |
| Disk usage | > 80% | WARN |
| System load | > 2x CPU count | WARN |

### 7 Check Modules

1. Gateway health
2. Credentials validity
3. Cron job status
4. Log analysis
5. System resources
6. Dashboard health
7. Session coherence

### Cron Jobs

| Job | Schedule | Description |
|-----|----------|-------------|
| `nightly-monitor-report` | Daily 10pm ET | End-of-day ecosystem health summary |

### Heartbeat Checks

- Full audit (`monitor_agent.py --json`)
- Stale reports (> 30min)
- Timer status verification (`openclaw-monitor.timer`)
- Gateway quick check (`clawdbot gateway health --json`)

---

## Dashboard Bot

| Field | Value |
|-------|-------|
| **Agent ID** | `dashboard-bot` |
| **Identity** | Dashboard Bot — AI SMMA assistant |
| **Emoji** | 📊 |
| **Vibe** | Casual & sharp |
| **Telegram Account** | `dashboard-bot` |
| **Bot Username** | *(client-facing, web dashboard)* |
| **Workspace** | `/root/clawd/DashboardBot` |
| **Agent Dir** | `/root/.clawdbot/agents/dashboard-bot/agent` |

### Purpose

Client-facing SMMA dashboard assistant. Lives in the web dashboard and helps clients with content strategy, post creation, analytics, and account health. All posts created as `pending_approval` — nothing goes live without operator sign-off.

### Key Details

- Each client has separate login, posts, and accounts
- No heartbeat configured (explicitly skipped)
- USER.md is blank (serves multiple end clients)
- TOOLS.md is template-only (not filled with specifics)
- No cron jobs assigned
