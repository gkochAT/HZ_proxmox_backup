#!/bin/bash

BACKUP_DIR="/root/pve-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "🔄 Sichern nach $BACKUP_DIR ..."

cp /etc/network/interfaces "$BACKUP_DIR/" 2>/dev/null
cp /etc/fstab "$BACKUP_DIR/" 2>/dev/null
cp /etc/bash.bashrc "$BACKUP_DIR/" 2>/dev/null
cp /root/.bashrc "$BACKUP_DIR/" 2>/dev/null
cp /etc/apt/sources.list "$BACKUP_DIR/" 2>/dev/null
cp -r /etc/apt/sources.list.d "$BACKUP_DIR/" 2>/dev/null
cp /etc/pve/storage.cfg "$BACKUP_DIR/" 2>/dev/null
cp /etc/backup-credentials.txt "$BACKUP_DIR/" 2>/dev/null

chmod 600 "$BACKUP_DIR/backup-credentials.txt"

echo "✅ Backup abgeschlossen: $BACKUP_DIR"
