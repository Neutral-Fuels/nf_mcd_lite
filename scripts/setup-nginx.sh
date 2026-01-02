#!/bin/bash
# Setup Nginx for NF MCD Lite
# Run this on your VM after deploying

set -e

echo "=========================================="
echo "Setting up Nginx for mCollect"
echo "=========================================="

# Install nginx if not present
if ! command -v nginx &> /dev/null; then
    echo "Installing Nginx..."
    sudo apt update
    sudo apt install -y nginx
fi

# Copy nginx config
echo "Copying nginx configuration..."
sudo cp /opt/nf-mcd-lite/nginx/mcollect.conf /etc/nginx/sites-available/mcollect.conf

# Enable site
sudo ln -sf /etc/nginx/sites-available/mcollect.conf /etc/nginx/sites-enabled/

# Remove default site if exists
sudo rm -f /etc/nginx/sites-enabled/default

# Test nginx config
echo "Testing nginx configuration..."
sudo nginx -t

# Reload nginx
echo "Reloading nginx..."
sudo systemctl reload nginx
sudo systemctl enable nginx

echo ""
echo "=========================================="
echo "Nginx setup complete!"
echo "=========================================="
echo ""
echo "Sites configured:"
echo "  - mCollect.neutralfuels.net -> localhost:5173"
echo "  - api.mcollect.neutralfuels.net -> localhost:3000"
echo ""
echo "Next: Run certbot to enable HTTPS:"
echo "  sudo apt install certbot python3-certbot-nginx"
echo "  sudo certbot --nginx -d mCollect.neutralfuels.net -d api.mcollect.neutralfuels.net"
echo ""
