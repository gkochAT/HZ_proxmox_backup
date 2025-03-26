# HZ_proxmox_backup
Proxmox Backup Script für Hetzner Root Server

Dieses Skript sichert wichtige Konfigurationsdateien deines Proxmox-Servers vor einer Neuinstallation.
Hinweis: Die Datei backup-credentials.txt enthält sensible Zugangsdaten – bitte vorsichtig behandeln.

## Was wird gesichert?

- Netzwerk-Konfiguration: `/etc/network/interfaces`
- CIFS-Mounts: `/etc/fstab`
- APT-Repositories: `/etc/apt/sources.list`, `/etc/apt/sources.list.d/`
- Bash-Konfiguration: `/etc/bash.bashrc`, `/root/.bashrc`
- Proxmox-Storage-Konfiguration: `/etc/pve/storage.cfg`
- Storagebox-Zugangsdaten: `/etc/backup-credentials.txt`

## Das Backup wird im Verzeichnis /root/pve-backup-<Datum> abgelegt.

## Verwendung

```bash
chmod +x backup-proxmox-config.sh
./backup-proxmox-config.sh
