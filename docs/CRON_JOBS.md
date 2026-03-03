# Cron Jobs

ClawdBot manages 6 scheduled jobs defined in `/root/.clawdbot/cron/jobs.json`. All jobs use `sessionTarget: isolated` and `wakeMode: next-heartbeat`, delivering results via Telegram.

## Job Overview

| # | Name | Agent | Schedule (ET) | Description |
|---|------|-------|---------------|-------------|
| 1 | `weekly-review` | main (Sam) | Sun 6:00 PM | Weekly goals/finances/deadlines summary |
| 2 | `afternoon-improvement` | reddit-scanner | Daily 12:45 PM | Improvement suggestion check-in |
| 3 | `evening-improvement` | reddit-scanner | Daily 9:00 PM | Improvement suggestion check-in |
| 4 | `daily-codebase-map` | cici | Daily 10:00 AM | Firm Schedule Assistant summary |
| 5 | `zoom-email-reminder` | cici | One-shot (completed) | Zoom integration email reminder |
| 6 | `nightly-monitor-report` | openclaw-monitor | Daily 10:00 PM | Ecosystem health summary |

All schedules use `America/New_York` timezone.

---

## Job Details

### 1. weekly-review

| Field | Value |
|-------|-------|
| **ID** | `f3443043` |
| **Agent** | `main` (Sam) |
| **Schedule** | `0 18 * * 0` — Every Sunday at 6:00 PM ET |
| **Post Mode** | `summary` (max 8000 chars) |

**What it does**: Reads `goals.md`, `deadlines.md`, and `finances.md` from Sam's workspace and produces a weekly summary covering goal progress, financial status, and upcoming deadlines.

---

### 2. afternoon-improvement

| Field | Value |
|-------|-------|
| **ID** | `e76eb43e` |
| **Agent** | `reddit-scanner` |
| **Schedule** | `45 12 * * *` — Daily at 12:45 PM ET |

**What it does**: Sends an afternoon check-in to Reddit Scanner asking for ONE concrete improvement suggestion based on recent data or pipeline performance.

---

### 3. evening-improvement

| Field | Value |
|-------|-------|
| **ID** | `a7334eba` |
| **Agent** | `reddit-scanner` |
| **Schedule** | `0 21 * * *` — Daily at 9:00 PM ET |

**What it does**: Same as afternoon-improvement but at 9 PM. Provides another opportunity for the scanner to suggest improvements.

---

### 4. daily-codebase-map

| Field | Value |
|-------|-------|
| **ID** | `83ea40a1` |
| **Agent** | `cici` |
| **Schedule** | `0 10 * * *` — Daily at 10:00 AM ET |
| **Post Mode** | `summary` (max 4000 chars) |

**What it does**: Reads `memory/projects/firm-schedule-assistant-map.md` and delivers a clean summary of Firm Schedule Assistant phases, edge functions, and API endpoints.

---

### 5. zoom-email-reminder

| Field | Value |
|-------|-------|
| **ID** | `0eea5d25` |
| **Agent** | `cici` |
| **Schedule** | `0 15 2 3 *` — March 2 at 3:00 PM ET |
| **Delete After Run** | `true` |

**What it does**: One-shot reminder that asked Cici to send a Zoom integration email with two Zoom options. Already executed; next run calculated as 2027 (effectively defunct).

---

### 6. nightly-monitor-report

| Field | Value |
|-------|-------|
| **ID** | `34d70c8d` |
| **Agent** | `openclaw-monitor` (MicroMonitor) |
| **Schedule** | `0 22 * * *` — Daily at 10:00 PM ET |

**What it does**: Runs `python3 /root/openclaw-monitor/monitor_agent.py` and delivers an end-of-day ecosystem health summary covering gateway status, credential health, cron job performance, system resources, and session coherence.

---

## Job Configuration

### Common Fields

All jobs share these settings:

```json
{
  "sessionTarget": "isolated",
  "wakeMode": "next-heartbeat",
  "timezone": "America/New_York"
}
```

- **sessionTarget: isolated** — each cron run gets its own isolated session
- **wakeMode: next-heartbeat** — agent runs its heartbeat checks when woken by cron

### Post Modes

Some jobs have explicit post modes:

- `summary` — condense output to specified max chars before posting to Telegram
- Default — full output sent as-is

### Run Logs

Job execution logs are stored in `/root/.clawdbot/cron/runs/` as `.jsonl` files (one per job, append-only).

## Management Commands

```bash
# List all cron jobs
clawdbot cron list

# Manually trigger a job
clawdbot cron run <job-id>

# View run history (from log files)
cat /root/.clawdbot/cron/runs/<run-id>.jsonl
```
