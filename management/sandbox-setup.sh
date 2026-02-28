#!/bin/bash
# ClawdBot Docker Sandbox Setup Script
# This script sets up Docker-based sandboxing for ClawdBot agents

set -e

echo "🦞 ClawdBot Docker Sandbox Setup"
echo "================================"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "📦 Installing Docker..."
    sudo apt-get update
    sudo apt-get install -y docker.io
    
    # Add user to docker group to run without sudo
    sudo usermod -aG docker $USER
    
    # Start Docker service
    sudo systemctl start docker
    sudo systemctl enable docker
    
    echo "✅ Docker installed successfully"
    echo "⚠️  You may need to log out and back in for docker group changes to take effect"
else
    echo "✅ Docker is already installed"
fi

# Create sandbox configuration directories
echo "📂 Creating sandbox directories..."
mkdir -p ~/.clawdbot/sandboxes/{main,lovable,resumebot,smma}

# Create Docker network for sandbox isolation
echo "🔒 Setting up Docker sandbox network..."
docker network create clawdbot-sandbox || true

# Pull a secure base image for sandboxes
echo "📥 Pulling secure sandbox base image..."
docker pull ubuntu:22.04

# Create sandbox config file for each agent
echo "⚙️  Creating sandbox configurations..."

# Main agent sandbox (most restricted)
cat > ~/.clawdbot/sandboxes/main/sandbox.json << EOF
{
  "image": "ubuntu:22.04",
  "network": "clawdbot-sandbox",
  "resources": {
    "memory": "1g",
    "cpus": "0.5"
  },
  "volumes": {
    "/workspace": "/tmp/workspace:rw",
    "/readonly": "/usr/share:ro"
  },
  "environment": {
    "SANDBOX_MODE": "restricted"
  },
  "security": {
    "no_new_privileges": true,
    "readonly_rootfs": true,
    "user": "nobody",
    "capabilities": {
      "drop": ["ALL"]
    }
  }
}
EOF

# Lovable agent sandbox (development tools)
cat > ~/.clawdbot/sandboxes/lovable/sandbox.json << EOF
{
  "image": "ubuntu:22.04",
  "network": "clawdbot-sandbox",
  "resources": {
    "memory": "2g",
    "cpus": "1.0"
  },
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
    "capabilities": {
      "drop": ["SYS_ADMIN", "NET_ADMIN", "SYS_MODULE"]
    }
  }
}
EOF

# Resume bot sandbox (document processing)
cat > ~/.clawdbot/sandboxes/resumebot/sandbox.json << EOF
{
  "image": "ubuntu:22.04",
  "network": "clawdbot-sandbox",
  "resources": {
    "memory": "1g",
    "cpus": "0.75"
  },
  "volumes": {
    "/workspace": "/tmp/workspace:rw",
    "/docs": "/tmp/documents:rw"
  },
  "environment": {
    "SANDBOX_MODE": "document_processing"
  },
  "security": {
    "no_new_privileges": true,
    "readonly_rootfs": true,
    "user": "docprocessor",
    "capabilities": {
      "drop": ["ALL"]
    }
  }
}
EOF

# SMMA bot sandbox (content creation)
cat > ~/.clawdbot/sandboxes/smma/sandbox.json << EOF
{
  "image": "ubuntu:22.04",
  "network": "clawdbot-sandbox",
  "resources": {
    "memory": "1.5g",
    "cpus": "0.75"
  },
  "volumes": {
    "/workspace": "/tmp/workspace:rw",
    "/media": "/tmp/media:rw"
  },
  "environment": {
    "SANDBOX_MODE": "content_creation"
  },
  "security": {
    "no_new_privileges": true,
    "readonly_rootfs": false,
    "user": "creator",
    "capabilities": {
      "drop": ["SYS_ADMIN", "NET_ADMIN"]
    }
  }
}
EOF

# Create Docker health check script
cat > ~/.clawdbot/docker-health-check.sh << 'EOF'
#!/bin/bash
# Docker Health Check for ClawdBot Sandboxes

check_docker() {
    if ! docker info &> /dev/null; then
        echo "❌ Docker is not running"
        return 1
    fi
    echo "✅ Docker is running"
}

check_network() {
    if ! docker network inspect clawdbot-sandbox &> /dev/null; then
        echo "❌ ClawdBot sandbox network not found"
        return 1
    fi
    echo "✅ Sandbox network is available"
}

check_containers() {
    local running=$(docker ps --filter "name=clawdbot-" --format "{{.Names}}" | wc -l)
    echo "📊 Running sandbox containers: $running"
}

cleanup_old_containers() {
    echo "🧹 Cleaning up old containers..."
    docker container prune -f
    docker volume prune -f
}

main() {
    echo "🔍 ClawdBot Docker Health Check"
    echo "==============================="
    
    check_docker || exit 1
    check_network
    check_containers
    cleanup_old_containers
    
    echo "🎉 Health check complete"
}

main "$@"
EOF

chmod +x ~/.clawdbot/docker-health-check.sh

echo "🎉 Sandbox setup complete!"
echo ""
echo "Next steps:"
echo "1. Log out and back in to apply docker group changes"
echo "2. Run: clawdbot sandbox recreate --all"
echo "3. Test sandbox isolation with: clawdbot agent --sandbox"
echo ""
echo "Health check script: ~/.clawdbot/docker-health-check.sh"
echo "Sandbox configs: ~/.clawdbot/sandboxes/"