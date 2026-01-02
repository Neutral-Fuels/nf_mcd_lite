#!/bin/bash
# Production Deployment Script for NF MCD Lite
# Run this on your VM after cloning the repo

set -e

APP_DIR="/opt/nf-mcd-lite"
REPO_URL="${1:-git@github.com:YOUR_USERNAME/nf-mcd-lite.git}"

echo "=========================================="
echo "NF MCD Lite - Production Deployment"
echo "=========================================="

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run with sudo: sudo ./deploy.sh"
    exit 1
fi

# Install Docker if not present
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    systemctl enable docker
    systemctl start docker
fi

# Install Docker Compose if not present
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "Installing Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# Clone or update repository
if [ -d "$APP_DIR" ]; then
    echo "Updating existing installation..."
    cd "$APP_DIR"
    git fetch origin
    git reset --hard origin/main
else
    echo "Cloning repository..."
    git clone "$REPO_URL" "$APP_DIR"
    cd "$APP_DIR"
fi

# Create .env file if not exists
if [ ! -f "$APP_DIR/.env" ]; then
    echo "Creating .env file..."
    cat > "$APP_DIR/.env" << 'EOF'
# Environment
ENVIRONMENT=production

# Backend
NODE_ENV=production
PORT=3000

# UCO API URLs
UCO_API_TEST_URL=https://ucoapi-test.neutralfuels.net
UCO_API_PROD_URL=https://ucoapi.neutralfuels.net

# Frontend
VITE_API_URL=http://localhost:3000/api
VITE_APP_VERSION=2.0.0
EOF
    echo "Please edit $APP_DIR/.env with your settings"
fi

# Stop existing containers
echo "Stopping existing containers..."
docker compose down 2>/dev/null || true

# Build and start containers
echo "Building and starting containers..."
docker compose build --no-cache
docker compose up -d

# Setup cleanup cron job
echo "Setting up cleanup cron job..."
chmod +x "$APP_DIR/scripts/setup-cron.sh"
"$APP_DIR/scripts/setup-cron.sh"

# Show status
echo ""
echo "=========================================="
echo "Deployment Complete!"
echo "=========================================="
echo ""
docker compose ps
echo ""
echo "Frontend: http://localhost:5173"
echo "Backend:  http://localhost:3000"
echo ""
echo "To view logs: docker compose logs -f"
echo "To stop: docker compose down"
