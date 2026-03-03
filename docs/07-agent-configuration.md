# Agent Configuration

How to create agents, set up workspaces, and define agent identity with SOUL.md files.

## Agent Basics

An agent in ClawdBot is a Claude instance with its own:

- **ID** — unique identifier used in bindings and config
- **Workspace** — filesystem directory the agent can read/write
- **Agent directory** — session and config data
- **Identity** — SOUL.md file defining personality, capabilities, and boundaries

## Creating an Agent

### 1. Add to `clawdbot.json`

Add the agent to the `agents.list` array:

```json
{
  "agents": {
    "defaults": {
      "workspace": "/root/clawd",
      "userTimezone": "America/New_York",
      "compaction": { "mode": "safeguard" },
      "maxConcurrent": 4,
      "subagents": { "maxConcurrent": 8 }
    },
    "list": [
      {
        "id": "my-agent",
        "name": "my-agent",
        "workspace": "/root/clawd/MyAgent",
        "agentDir": "/root/.clawdbot/agents/my-agent/agent"
      }
    ]
  }
}
```

### Agent Defaults

Settings in `agents.defaults` apply to all agents unless overridden:

| Field | Description |
|-------|-------------|
| `workspace` | Default workspace directory |
| `userTimezone` | Timezone for time-aware operations |
| `compaction.mode` | Context window management (`"safeguard"`) |
| `maxConcurrent` | Max concurrent conversations per agent |
| `subagents.maxConcurrent` | Max concurrent subagent processes |

### Per-Agent Fields

| Field | Description |
|-------|-------------|
| `id` | Unique agent identifier (used in bindings) |
| `name` | Display name |
| `workspace` | Agent's working directory (overrides default) |
| `agentDir` | Where agent config and sessions live |

### 2. Create the Workspace

```bash
mkdir -p /root/clawd/MyAgent
```

### 3. Write a SOUL.md

Create a `SOUL.md` in the workspace root. This is the agent's identity document — it tells Claude who it is, how to behave, and what it can do.

```bash
cat > /root/clawd/MyAgent/SOUL.md << 'EOF'
# SOUL — My Agent

## Identity
You are [description of who this agent is and what it does].

## How You Communicate
- [Communication style guidelines]
- [Tone preferences]

## Capabilities
- [What tools/skills are available]
- [What the agent can access]

## Boundaries
- [What the agent should NOT do]
- [Approval requirements]

## Continuity
Each session, you wake up fresh. These files are your memory. Read them. Update them.
EOF
```

### 4. Bind to a Telegram Account

See [Connecting a Bot to OpenClaw](05-connecting-bot-to-openclaw.md) for the binding config.

## Current Agent Fleet

| Agent ID | Workspace | SOUL.md | Purpose |
|----------|-----------|---------|---------|
| `main` | `/root/clawd` | `/root/clawd/SOUL.md` | Sam — SMMA |
| `cici` | `/root/clawd/CiciCoder` | `/root/clawd/CiciCoder/SOUL.md` | Code assistant |
| `reddit-scanner` | `/root/clawd/RedditScanner` | `/root/clawd/RedditScanner/SOUL.md` | Reddit scraping |
| `openclaw-monitor` | `/root/openclaw-monitor` | `/root/openclaw-monitor/SOUL.md` | Ops monitoring |

## SOUL.md Best Practices

- **Be specific about identity.** "You are a social media marketer" is better than "You are a helpful assistant."
- **Define boundaries clearly.** What should the agent never do? What requires human approval?
- **Include communication style.** Terse and status-oriented? Casual and clever? Specify it.
- **Document tools and integrations.** List what the agent has access to and how to use it.
- **Keep it concise.** SOUL.md files are loaded into the context window — every token counts.
- **Let the agent evolve it.** Include a "Continuity" section encouraging the agent to update its own SOUL.md as it learns.

## Agent Concurrency

The `maxConcurrent` setting controls how many conversations an agent can handle simultaneously:

```json
{
  "agents": {
    "defaults": {
      "maxConcurrent": 4,
      "subagents": {
        "maxConcurrent": 8
      }
    }
  }
}
```

If an agent hits its concurrency limit, new messages queue until a slot opens.

## Next Steps

- [Memory System](08-memory-system.md) — set up per-agent memory
- [Systemd Services](09-systemd-services.md) — run the gateway as a service
