#!/bin/bash
# Docker Cleanup Script for NF MCD Lite
# Runs every 6 hours via cron to prevent disk space issues

set -e

LOG_FILE="/var/log/nf-mcd-cleanup.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

log() {
    echo "[$TIMESTAMP] $1" >> "$LOG_FILE"
    echo "[$TIMESTAMP] $1"
}

log "Starting cleanup..."

# 1. Truncate Docker container logs (keep last 100MB per container)
log "Truncating Docker container logs..."
for container in $(docker ps -q 2>/dev/null); do
    LOG_PATH=$(docker inspect --format='{{.LogPath}}' "$container" 2>/dev/null)
    if [ -f "$LOG_PATH" ]; then
        SIZE=$(du -m "$LOG_PATH" 2>/dev/null | cut -f1)
        if [ "$SIZE" -gt 100 ]; then
            log "Truncating log for container $container (${SIZE}MB)"
            truncate -s 0 "$LOG_PATH"
        fi
    fi
done

# 2. Remove unused Docker images
log "Removing dangling Docker images..."
docker image prune -f >> "$LOG_FILE" 2>&1 || true

# 3. Remove unused Docker volumes
log "Removing unused Docker volumes..."
docker volume prune -f >> "$LOG_FILE" 2>&1 || true

# 4. Remove unused Docker networks
log "Removing unused Docker networks..."
docker network prune -f >> "$LOG_FILE" 2>&1 || true

# 5. Remove Docker build cache older than 7 days
log "Removing old Docker build cache..."
docker builder prune -f --filter "until=168h" >> "$LOG_FILE" 2>&1 || true

# 6. Clean up old log files in application
APP_DIR="/opt/nf-mcd-lite"
if [ -d "$APP_DIR/backend/logs" ]; then
    log "Cleaning application logs older than 7 days..."
    find "$APP_DIR/backend/logs" -type f -name "*.log" -mtime +7 -delete 2>/dev/null || true
fi

# 7. Clean up /tmp files older than 1 day
log "Cleaning old temp files..."
find /tmp -type f -mtime +1 -delete 2>/dev/null || true

# 8. Report disk usage
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}')
log "Current disk usage: $DISK_USAGE"

# 9. Rotate cleanup log if > 10MB
if [ -f "$LOG_FILE" ]; then
    LOG_SIZE=$(du -m "$LOG_FILE" 2>/dev/null | cut -f1)
    if [ "$LOG_SIZE" -gt 10 ]; then
        mv "$LOG_FILE" "${LOG_FILE}.old"
        log "Rotated cleanup log"
    fi
fi

log "Cleanup completed successfully"
