# Sandboxes

ClawdBot uses Docker sandboxes for agent code execution. Three sandbox configurations are defined in `/root/.clawdbot/sandboxes/`.

## Overview

All sandboxes share:
- **Image**: `ubuntu:22.04`
- **Network**: `clawdbot-sandbox` (Docker bridge network)
- **Security**: `no_new_privileges: true`

## Configurations

### main — Restricted Mode

**Path**: `/root/.clawdbot/sandboxes/main/sandbox.json`

| Setting | Value |
|---------|-------|
| Mode | `restricted` |
| Memory | 1 GB |
| CPUs | 0.5 |
| User | `nobody` |
| Rootfs | **readonly** |
| Capabilities | Drop ALL |

```json
{
  "image": "ubuntu:22.04",
  "network": "clawdbot-sandbox",
  "resources": { "memory": "1g", "cpus": "0.5" },
  "volumes": {
    "/workspace": "/tmp/workspace:rw",
    "/readonly": "/usr/share:ro"
  },
  "environment": { "SANDBOX_MODE": "restricted" },
  "security": {
    "no_new_privileges": true,
    "readonly_rootfs": true,
    "user": "nobody",
    "capabilities": { "drop": ["ALL"] }
  }
}
```

Most locked-down config. Used for untrusted or general-purpose execution. Readonly filesystem, no capabilities, runs as `nobody`.

---

### cici — Development Mode

**Path**: `/root/.clawdbot/sandboxes/cici/sandbox.json`

| Setting | Value |
|---------|-------|
| Mode | `development` |
| Memory | 2 GB |
| CPUs | 1.0 |
| User | `developer` |
| Rootfs | writable |
| Capabilities | Drop SYS_ADMIN, NET_ADMIN, SYS_MODULE |

```json
{
  "image": "ubuntu:22.04",
  "network": "clawdbot-sandbox",
  "resources": { "memory": "2g", "cpus": "1.0" },
  "volumes": {
    "/workspace": "/tmp/workspace:rw",
    "/node_modules": "/tmp/node_modules:rw"
  },
  "environment": {
    "SANDBOX_MODE": "development",
    "NODE_ENV": "development"
  },
  "security": {
    "no_new_privileges": true,
    "readonly_rootfs": false,
    "user": "developer",
    "capabilities": { "drop": ["SYS_ADMIN", "NET_ADMIN", "SYS_MODULE"] }
  }
}
```

More permissive for development work. Writable rootfs, higher resource limits, `node_modules` volume for npm packages. Used by Cici for building and testing automation projects.

---

### smma — Content Creation Mode

**Path**: `/root/.clawdbot/sandboxes/smma/sandbox.json`

| Setting | Value |
|---------|-------|
| Mode | `content_creation` |
| Memory | 1.5 GB |
| CPUs | 0.75 |
| User | `creator` |
| Rootfs | writable |
| Capabilities | Drop SYS_ADMIN, NET_ADMIN |

```json
{
  "image": "ubuntu:22.04",
  "network": "clawdbot-sandbox",
  "resources": { "memory": "1.5g", "cpus": "0.75" },
  "volumes": {
    "/workspace": "/tmp/workspace:rw",
    "/media": "/tmp/media:rw"
  },
  "environment": { "SANDBOX_MODE": "content_creation" },
  "security": {
    "no_new_privileges": true,
    "readonly_rootfs": false,
    "user": "creator",
    "capabilities": { "drop": ["SYS_ADMIN", "NET_ADMIN"] }
  }
}
```

Mid-tier permissions for content generation. Includes a `/media` volume for image/video processing. Used by Sam's SMMA workflows.

## Docker Network

The `clawdbot-sandbox` network is a Docker bridge network that isolates sandbox containers from the host network while allowing inter-container communication if needed.

```bash
# Inspect the network
docker network inspect clawdbot-sandbox

# Create if missing
docker network create clawdbot-sandbox
```

## Health Check Script

The Docker health check script at `/root/.clawdbot/docker-health-check.sh` verifies:

1. Docker daemon is running (`docker info`)
2. `clawdbot-sandbox` network exists
3. Running `clawdbot-*` container count
4. Cleans up stopped containers and unused volumes

```bash
# Run manually
bash /root/.clawdbot/docker-health-check.sh
```

## Security Notes

- All sandboxes use `no_new_privileges: true` — prevents privilege escalation
- Capability dropping limits what system calls containers can make
- The `restricted` sandbox is the most secure (readonly rootfs, drop ALL, runs as nobody)
- Volume mounts are explicit and limited to required paths
- No sandbox has access to the host's `/root/.clawdbot/` directory
