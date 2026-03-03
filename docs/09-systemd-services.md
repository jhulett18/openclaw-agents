# Systemd Services

How to run the ClawdBot gateway, watchdog, and OpenClaw Monitor as persistent systemd user services.

## Overview

Three systemd units keep the system running:

| Unit | Type | Purpose |
|------|------|---------|
| `clawdbot-gateway.service` | Service | The main gateway process |
| `clawdbot-watchdog.timer` | Timer | Triggers health check every 5 minutes |
| `clawdbot-watchdog.service` | Oneshot | Runs the health check script |
| `openclaw-monitor.timer` | Timer | Triggers monitor every 15 minutes |
| `openclaw-monitor.service` | Oneshot | Runs the 7 check modules |

All units run as **user services** (not system-wide), so they live in `~/.config/systemd/user/`.

## Gateway Service

### Install

Copy the service file (see [`examples/gateway.service.example`](../examples/gateway.service.example)):

```bash
mkdir -p ~/.config/systemd/user
cp examples/gateway.service.example ~/.config/systemd/user/clawdbot-gateway.service
# Edit the file to match your paths if needed
```

### Enable and Start

```bash
systemctl --user daemon-reload
systemctl --user enable clawdbot-gateway.service
systemctl --user start clawdbot-gateway.service
```

### Verify

```bash
systemctl --user status clawdbot-gateway.service
```

You should see `active (running)`. Test with:

```bash
clawdbot gateway health
```

### Logs

```bash
journalctl --user -u clawdbot-gateway.service -f
```

## Watchdog

The watchdog is a two-part systemd setup: a **timer** that fires every 5 minutes, and a **oneshot service** that runs the health check.

### Install

1. Copy the watchdog script:
   ```bash
   cp examples/watchdog.sh.example ~/.clawdbot/scripts/gateway-watchdog.sh
   chmod +x ~/.clawdbot/scripts/gateway-watchdog.sh
   ```

2. Copy the systemd units:
   ```bash
   cp examples/watchdog.service.example ~/.config/systemd/user/clawdbot-watchdog.service
   cp examples/watchdog.timer.example ~/.config/systemd/user/clawdbot-watchdog.timer
   ```

### Enable

```bash
systemctl --user daemon-reload
systemctl --user enable clawdbot-watchdog.timer
systemctl --user start clawdbot-watchdog.timer
```

### Verify

```bash
# Check timer status
systemctl --user status clawdbot-watchdog.timer

# Check when it last ran
systemctl --user list-timers clawdbot-watchdog.timer

# Check watchdog logs
cat ~/.clawdbot/logs/watchdog.log
```

### How It Works

1. Timer fires every 5 minutes (first run 2 minutes after boot)
2. Runs `gateway-watchdog.sh`
3. Script calls `clawdbot gateway health` with a 15-second timeout
4. If health check fails, restarts `clawdbot-gateway.service`
5. A 60-second cooldown prevents restart loops

## OpenClaw Monitor

The monitor is a Python application with its own timer:

### Install

```bash
cp /root/openclaw-monitor/openclaw-monitor.service ~/.config/systemd/user/
cp /root/openclaw-monitor/openclaw-monitor.timer ~/.config/systemd/user/
```

### Enable

```bash
systemctl --user daemon-reload
systemctl --user enable openclaw-monitor.timer
systemctl --user start openclaw-monitor.timer
```

### Verify

```bash
systemctl --user list-timers openclaw-monitor.timer
```

## Managing Services

### Common Commands

```bash
# Start/stop/restart
systemctl --user start clawdbot-gateway
systemctl --user stop clawdbot-gateway
systemctl --user restart clawdbot-gateway

# View logs (follow mode)
journalctl --user -u clawdbot-gateway -f

# Check all ClawdBot-related units
systemctl --user list-units 'clawdbot-*'
systemctl --user list-timers

# Reload after editing unit files
systemctl --user daemon-reload
```

### Lingering

For services to run when you're not logged in:

```bash
sudo loginctl enable-linger $(whoami)
```

Without this, all user services stop when your SSH session ends.

## Next Steps

- [Monitoring & Ops](10-monitoring-and-ops.md) — understanding health checks and recovery procedures
