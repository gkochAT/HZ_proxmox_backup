#!/bin/bash

set -euo pipefail

# 📁 Zielverzeichnis für das Backup
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="/var/backups/proxmox-config-$TIMESTAMP"
ARCHIVE="/var/backups/proxmox-config-$TIMESTAMP.tar.gz"
STORAGEBOX_TARGET="/mnt/storagebox/pve-config-backups"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

fail() {
    local message="$*"
    echo "❌ Fehler: $message" >&2
    echo -e "Proxmox-Konfig-Backup ist fehlgeschlagen auf Host: $(hostname)\n\nFehler:\n$message\n\nDatum: $(date)" | mail -s "[Proxmox Backup ❌ Fehler]" root
    exit 1
}

# 📂 Backup-Zielverzeichnis erstellen
if [ -d "$BACKUP_DIR" ]; then
    log "⚠️  Backup-Verzeichnis existiert bereits: $BACKUP_DIR"
else
    mkdir -p "$BACKUP_DIR" || fail "Konnte Backup-Verzeichnis nicht erstellen: $BACKUP_DIR"
    log "📁 Backup-Verzeichnis erstellt: $BACKUP_DIR"
fi

# 📂 Storagebox prüfen
if mountpoint -q /mnt/storagebox; then
    if [ ! -d "$STORAGEBOX_TARGET" ]; then
        mkdir -p "$STORAGEBOX_TARGET" || fail "Konnte Zielverzeichnis auf Storagebox nicht erstellen: $STORAGEBOX_TARGET"
        log "📁 Zielverzeichnis auf Storagebox erstellt: $STORAGEBOX_TARGET"
    else
        log "☁️  Zielverzeichnis auf Storagebox vorhanden: $STORAGEBOX_TARGET"
    fi
else
    log "⚠️  /mnt/storagebox ist nicht gemountet – das Archiv wird nur lokal gespeichert."
    STORAGEBOX_TARGET=""
fi

log "🔄 Starte Sicherung nach $BACKUP_DIR"

# 🔐 Konfigurationsdateien sichern
copy_or_warn() {
    local src="$1"
    local dst="$2"
    if [ -e "$src" ]; then
        cp -r "$src" "$dst/" || log "⚠️  Kopieren fehlgeschlagen: $src"
    else
        log "⚠️  Nicht gefunden (übersprungen): $src"
    fi
}

copy_or_warn /etc/network/interfaces "$BACKUP_DIR"
copy_or_warn /etc/fstab "$BACKUP_DIR"
copy_or_warn /etc/bash.bashrc "$BACKUP_DIR"
copy_or_warn /root/.bashrc "$BACKUP_DIR"
copy_or_warn /etc/apt/sources.list "$BACKUP_DIR"
copy_or_warn /etc/apt/sources.list.d "$BACKUP_DIR"
copy_or_warn /etc/pve/storage.cfg "$BACKUP_DIR"
copy_or_warn /etc/backup-credentials.txt "$BACKUP_DIR"

chmod 600 "$BACKUP_DIR/backup-credentials.txt" 2>/dev/null || log "⚠️  Konnte Rechte für backup-credentials.txt nicht setzen"

# 📦 Archiv erstellen
log "📦 Erstelle Archiv: $ARCHIVE ..."
tar -czf "$ARCHIVE" -C "$(dirname "$BACKUP_DIR")" "$(basename "$BACKUP_DIR")" || fail "Archivierung fehlgeschlagen"

# 🗑️ Backup-Verzeichnis löschen – nur Archiv behalten
log "🗑️ Lösche temporäres Verzeichnis: $BACKUP_DIR"
rm -rf "$BACKUP_DIR"

# 📤 Auf Storagebox kopieren (wenn vorhanden)
if [ -n "$STORAGEBOX_TARGET" ]; then
    log "📤 Übertrage Archiv nach: $STORAGEBOX_TARGET ..."
    cp "$ARCHIVE" "$STORAGEBOX_TARGET/" || fail "Kopieren zur Storagebox fehlgeschlagen"
    log "✅ Archiv erfolgreich übertragen."
fi

# 🧹 Alte .tar.gz-Backups lokal löschen (nur die 7 neuesten behalten)
log "🧹 Bereinige alte Backups in /var/backups (max. 7 behalten)..."
mapfile -t BACKUPS_LOCAL < <(ls -1t /var/backups/proxmox-config-*.tar.gz 2>/dev/null)
BACKUPS_TO_DELETE_LOCAL=("${BACKUPS_LOCAL[@]:7}")
for OLD in "${BACKUPS_TO_DELETE_LOCAL[@]}"; do
    log "🗑️  Lokal löschen: $OLD"
    rm -f "$OLD"
done

# 🧹 Auch auf der Storagebox bereinigen (falls vorhanden)
if [ -n "$STORAGEBOX_TARGET" ]; then
    log "🧹 Bereinige alte Backups auf der Storagebox (max. 7 behalten)..."
    mapfile -t BACKUPS_REMOTE < <(ls -1t "$STORAGEBOX_TARGET"/proxmox-config-*.tar.gz 2>/dev/null)
    BACKUPS_TO_DELETE_REMOTE=("${BACKUPS_REMOTE[@]:7}")
    for OLD in "${BACKUPS_TO_DELETE_REMOTE[@]}"; do
        log "🗑️  Storagebox löschen: $OLD"
        rm -f "$OLD"
    done
fi

# ✅ Abschlussmeldung
log "✅ Backup abgeschlossen:"
log "   📦 Archiv: $ARCHIVE"
[ -n "$STORAGEBOX_TARGET" ] && log "   ☁️  Kopiert nach: $STORAGEBOX_TARGET"
