# Memory System

How claude-mem provides persistent, per-agent memory for the bot fleet.

## Overview

**claude-mem** is a memory plugin that gives each agent persistent memory across conversations. Without it, agents start every session with no recollection of prior interactions.

Key features:

- **Persistent storage** — memories survive across sessions and gateway restarts
- **Per-agent isolation** — each agent has its own memory namespace
- **Auto-capture** — important context is automatically captured from conversations
- **Web UI** — browse and manage memories at `http://localhost:37777`

## Configuration

claude-mem is configured in `clawdbot.json` under the `plugins` section:

```json
{
  "plugins": {
    "slots": {
      "memory": "claude-mem"
    },
    "entries": {
      "claude-mem": {
        "enabled": true,
        "config": {
          "syncMemoryFile": true,
          "workerPort": 37777,
          "project": "openclaw"
        }
      }
    }
  }
}
```

### Config Fields

| Field | Description |
|-------|-------------|
| `slots.memory` | Which plugin handles the memory slot (`"claude-mem"`) |
| `enabled` | Whether the plugin is active |
| `syncMemoryFile` | Sync memories to the agent's MEMORY.md file |
| `workerPort` | Port for the memory worker process |
| `project` | Base project name for memory isolation |

## Per-Agent Isolation

Each agent's memories are isolated via **project scoping**. The project name is constructed as `openclaw-<agent-id>`:

| Agent | Memory Project |
|-------|---------------|
| Sam (main) | `openclaw-main` |
| Cici | `openclaw-cici` |
| Reddit Scanner | `openclaw-reddit-scanner` |
| MicroMonitor | `openclaw-openclaw-monitor` |

This means Sam can't see Cici's memories and vice versa. Each agent builds its own knowledge base independently.

## How Memory Works

1. During a conversation, claude-mem automatically identifies important facts, preferences, and context
2. These are stored as memory entries with metadata (timestamp, source, relevance)
3. When the agent starts a new session, relevant memories are loaded into context
4. If `syncMemoryFile` is enabled, memories are also written to the agent's `MEMORY.md` file

## Web UI

The memory worker serves a web interface for browsing and managing memories:

```
http://localhost:37777
```

From here you can:

- Browse memories by agent/project
- Search across all memories
- Delete or edit individual memories
- View memory statistics

> **Note:** The web UI is only accessible from localhost. To access it remotely, use SSH port forwarding:
> ```bash
> ssh -L 37777:localhost:37777 your-server
> ```

## Disabled Hooks

The `session-memory` hook has been disabled because claude-mem handles auto-capture natively:

```json
{
  "hooks": {
    "internal": {
      "entries": {
        "session-memory": {
          "enabled": false
        }
      }
    }
  }
}
```

This avoids duplicate memory capture.

## Previous Memory System

The previous memory plugin (`memory-core`) has been replaced by claude-mem and is disabled:

```json
{
  "plugins": {
    "entries": {
      "memory-core": {
        "enabled": false
      }
    }
  }
}
```

## Troubleshooting

- **Memory worker not starting:** Check if port 37777 is already in use (`lsof -i :37777`)
- **Memories not persisting:** Verify `syncMemoryFile` is `true` and the workspace is writable
- **Cross-agent memory leakage:** Check that project scoping is correct in the config

## Next Steps

- [Systemd Services](09-systemd-services.md) — ensure the gateway (and memory worker) run persistently
