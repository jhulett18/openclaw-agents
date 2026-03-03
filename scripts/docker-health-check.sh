#!/bin/bash
# docker-health-check.sh — Verify Docker environment for ClawdBot sandboxes
#
# Checks:
#   1. Docker daemon is running
#   2. clawdbot-sandbox network exists
#   3. Count of running clawdbot-* containers
#   4. Cleanup stopped containers and unused volumes

set -euo pipefail

echo "=== ClawdBot Docker Health Check ==="
echo "Date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo ""

# 1. Check Docker daemon
echo "--- Docker Daemon ---"
if docker info >/dev/null 2>&1; then
    echo "Status: running"
else
    echo "Status: NOT RUNNING"
    echo "Fix: sudo systemctl start docker"
    exit 1
fi
echo ""

# 2. Check sandbox network
echo "--- Sandbox Network ---"
if docker network inspect clawdbot-sandbox >/dev/null 2>&1; then
    echo "Network: clawdbot-sandbox exists"
else
    echo "Network: clawdbot-sandbox MISSING"
    echo "Creating network..."
    docker network create clawdbot-sandbox
    echo "Network: created"
fi
echo ""

# 3. Running containers
echo "--- Running Containers ---"
RUNNING=$(docker ps --filter "name=clawdbot-" --format "{{.Names}}" 2>/dev/null | wc -l)
echo "ClawdBot containers running: $RUNNING"
if (( RUNNING > 0 )); then
    docker ps --filter "name=clawdbot-" --format "  {{.Names}} ({{.Status}})"
fi
echo ""

# 4. Cleanup
echo "--- Cleanup ---"
echo "Pruning stopped containers..."
docker container prune -f 2>/dev/null | tail -1
echo "Pruning unused volumes..."
docker volume prune -f 2>/dev/null | tail -1
echo ""

echo "=== Done ==="
