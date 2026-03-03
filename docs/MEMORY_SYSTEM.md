# Memory System

ClawdBot uses the `memory-core` plugin for per-agent persistent memory, with full isolation between agents.

## Overview

- **Plugin**: `memory-core` (slot: `memory`)
- **Storage**: File-backed markdown files in each agent's workspace
- **Tools**: `memory_search` and `memory_get` available to agents
- **Hook**: `session-memory` auto-saves context on `/new`

## Per-Agent Isolation

Each agent has its own memory workspace, completely isolated from other agents:

```
Agent Workspace (e.g., /root/clawd/)
├── MEMORY.md          # Agent's memory index
└── memory/            # Agent's detailed memory files
    ├── clients.md
    ├── tasks.md
    ├── decisions.md
    └── ...
```

Agents cannot read or write other agents' memory files. Memory isolation is enforced by workspace boundaries.

## Workspace Config Files

Each agent workspace contains these markdown configuration files that define the agent's behavior:

### IDENTITY.md

Defines the agent's name, creature type, personality vibe, and emoji:

```markdown
# Identity
- **Name**: Sam
- **Creature**: AI marketing partner
- **Vibe**: Casual & clever, witty
- **Emoji**: 📢
```

### SOUL.md

The agent's core personality, rules, responsibilities, and domain knowledge. This is the most detailed config file — it defines what the agent does, its constraints, and its working style.

### USER.md

Information about the primary user the agent interacts with:

```markdown
# User
- **Name**: Kawalski
- **Timezone**: America/New_York
- **Context**: Runs SMMA business, LinkedIn connected through GetLate.dev
```

### HEARTBEAT.md

Defines periodic health checks the agent should perform. Each heartbeat runs when the agent wakes up:

- Sam: Check GetLate queue, pending posts in SQLite
- Cici: CI failures, Supabase health, idle PRs, endpoint monitoring
- Reddit Scanner: Last run status, storage size, today's report
- MicroMonitor: Full audit, stale reports, timer status, gateway health
- Dashboard Bot: Empty (heartbeat skipped)

### TOOLS.md

Lists available tools, scripts, APIs, and integration details specific to the agent:

- Helper script paths
- API endpoints and keys (referenced by path, not inline)
- External service integrations
- Codebase locations

### AGENTS.md

Agent-specific configuration data (e.g., Reddit Scanner's scraping config):

```json
{
  "subreddits": ["FashionReps"],
  "postsPerSubreddit": 50,
  "commentsPerPost": 15,
  "sort": "hot"
}
```

### MEMORY.md

The agent's persistent memory index. Contains:
- Workspace path
- Links to detailed memory files in `memory/` subdir
- Active priorities and context
- Key facts the agent needs to remember across sessions

## Session Memory Hook

The `session-memory` hook (internal) is enabled. When a user sends `/new` to start a fresh session, the hook automatically saves the current session's context to the agent's memory before clearing.

This ensures important context isn't lost between sessions without requiring manual memory writes.

## Memory Tools

Agents have access to two memory tools:

### `memory_search`

Search the agent's memory files for relevant information:

```
memory_search("client onboarding process")
→ Returns matching snippets from MEMORY.md and memory/ files
```

### `memory_get`

Retrieve a specific memory file:

```
memory_get("memory/clients.md")
→ Returns the full contents of the specified memory file
```

## Configuration in clawdbot.json

```json
{
  "plugins": {
    "slots": { "memory": "memory-core" },
    "entries": {
      "memory-core": { "enabled": true }
    }
  },
  "hooks": {
    "internal": {
      "entries": {
        "session-memory": { "enabled": true }
      }
    }
  }
}
```

## Best Practices

1. **Keep MEMORY.md as an index** — link to detailed files in `memory/` rather than storing everything inline
2. **Organize by topic** — one memory file per topic (e.g., `clients.md`, `tasks.md`, `decisions.md`)
3. **Update, don't duplicate** — update existing entries rather than creating new ones
4. **Let the hook save context** — the session-memory hook handles session transitions automatically
5. **Agent-specific memory** — each agent should only store information relevant to its domain
