#!/bin/bash
# Setup cron jobs for NF MCD Lite production server

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="/opt/nf-mcd-lite"

echo "Setting up cron jobs for NF MCD Lite..."

# Copy cleanup script to /opt
sudo mkdir -p "$APP_DIR/scripts"
sudo cp "$SCRIPT_DIR/cleanup.sh" "$APP_DIR/scripts/"
sudo chmod +x "$APP_DIR/scripts/cleanup.sh"

# Create log directory
sudo mkdir -p /var/log
sudo touch /var/log/nf-mcd-cleanup.log
sudo chmod 644 /var/log/nf-mcd-cleanup.log

# Add cron job (every 6 hours: 0:00, 6:00, 12:00, 18:00)
CRON_JOB="0 */6 * * * /opt/nf-mcd-lite/scripts/cleanup.sh"

# Check if cron job already exists
if ! crontab -l 2>/dev/null | grep -q "nf-mcd-lite/scripts/cleanup.sh"; then
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
    echo "Cron job added: $CRON_JOB"
else
    echo "Cron job already exists"
fi

# Verify cron is running
if ! systemctl is-active --quiet cron 2>/dev/null; then
    if ! systemctl is-active --quiet crond 2>/dev/null; then
        echo "Warning: cron service not running. Starting..."
        sudo systemctl start cron 2>/dev/null || sudo systemctl start crond 2>/dev/null || true
    fi
fi

echo ""
echo "Setup complete! Cron jobs:"
crontab -l
echo ""
echo "Cleanup will run every 6 hours (0:00, 6:00, 12:00, 18:00)"
echo "Logs: /var/log/nf-mcd-cleanup.log"
