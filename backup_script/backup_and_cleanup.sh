#!/bin/bash

###############################################################################
# Script Name : backup_and_cleanup.sh
# Purpose     : Automated backup and disk cleanup (Generic Linux)
# Author      : Harini Muruganantham
# Version     : 1.0
###############################################################################

######################## CONFIGURATION ########################

# Directory to back up (change as needed)
SOURCE_DIR="$HOME/data"

# Backup storage location
BACKUP_DIR="$HOME/backups"

# Backup retention (days)
RETENTION_DAYS=7

# Disk cleanup threshold (%)
DISK_THRESHOLD=80

# Cleanup targets
LOG_DIR="/var/log"
TMP_DIR="/tmp"

# Log file
LOG_FILE="$HOME/backup_cleanup.log"

TIMESTAMP=$(date "+%Y-%m-%d_%H-%M-%S")

##############################################################

mkdir -p "$BACKUP_DIR"

echo "==================================================" >> "$LOG_FILE"
echo "JOB STARTED AT $(date)" >> "$LOG_FILE"
echo "==================================================" >> "$LOG_FILE"

######################## BACKUP SECTION ########################
echo "[INFO] Starting backup process" >> "$LOG_FILE"

if [ ! -d "$SOURCE_DIR" ]; then
    echo "[ERROR] Source directory not found: $SOURCE_DIR" >> "$LOG_FILE"
    exit 1
fi

BACKUP_FILE="$BACKUP_DIR/backup_$TIMESTAMP.tar.gz"

tar -czf "$BACKUP_FILE" "$SOURCE_DIR" 2>>"$LOG_FILE"

if [ $? -eq 0 ]; then
    echo "[SUCCESS] Backup created: $BACKUP_FILE" >> "$LOG_FILE"
else
    echo "[ERROR] Backup failed" >> "$LOG_FILE"
    exit 1
fi

######################## RETENTION POLICY ########################
echo "[INFO] Applying retention policy (${RETENTION_DAYS} days)" >> "$LOG_FILE"

find "$BACKUP_DIR" -type f -name "*.tar.gz" -mtime +$RETENTION_DAYS -exec rm -f {} \;

######################## DISK USAGE CHECK ########################
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | tr -d '%')

echo "[INFO] Current disk usage: ${DISK_USAGE}%" >> "$LOG_FILE"

if [ "$DISK_USAGE" -lt "$DISK_THRESHOLD" ]; then
    echo "[INFO] Disk usage under threshold. Cleanup not required." >> "$LOG_FILE"
    echo "JOB COMPLETED SUCCESSFULLY" >> "$LOG_FILE"
    exit 0
fi

######################## CLEANUP SECTION ########################
echo "[WARNING] Disk usage exceeded ${DISK_THRESHOLD}%. Starting cleanup." >> "$LOG_FILE"

# Clean old log files (only if permission allows)
if [ -d "$LOG_DIR" ]; then
    find "$LOG_DIR" -type f -name "*.log" -mtime +7 -exec rm -f {} \; 2>>"$LOG_FILE"
fi

# Clean temporary files
find "$TMP_DIR" -type f -mtime +3 -exec rm -f {} \; 2>>"$LOG_FILE"

echo "[SUCCESS] Disk cleanup completed" >> "$LOG_FILE"

######################## END ########################
echo "==================================================" >> "$LOG_FILE"
echo "JOB COMPLETED AT $(date)" >> "$LOG_FILE"
echo "==================================================" >> "$LOG_FILE"

echo "✔ Backup & Cleanup completed successfully"
