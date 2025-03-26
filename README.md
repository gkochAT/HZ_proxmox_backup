# Proxmox Config Backup Script

Dieses Skript erstellt ein vollständiges Backup wichtiger Konfigurationsdateien eines Proxmox-Systems und speichert es lokal sowie optional auf einer gemounteten Hetzner Storagebox.

## 🔧 Gesicherte Dateien

- `/etc/network/interfaces`
- `/etc/fstab`
- `/etc/bash.bashrc`
- `/root/.bashrc`
- `/etc/apt/sources.list`
- `/etc/apt/sources.list.d/`
- `/etc/pve/storage.cfg`
- `/etc/backup-credentials.txt`

## 📦 Ablauf

1. Erstellt ein temporäres Backup-Verzeichnis unter `/var/backups/proxmox-config-<Datum>/`
2. Sichert alle oben genannten Dateien dorthin
3. Erzeugt ein komprimiertes `.tar.gz`-Archiv
4. Löscht das temporäre Verzeichnis
5. Kopiert das Archiv nach `/mnt/storagebox/pve-config-backups` (falls gemountet)
6. Löscht lokal und auf der Storagebox alte `.tar.gz`-Backups, sodass nur die **7 neuesten** erhalten bleiben

## 📧 Fehlerbehandlung

- Bei kritischen Fehlern wird automatisch eine **E-Mail an `root`** gesendet.

## ✅ Verwendung

```bash
chmod +x backup-proxmox-config-<Datum>.sh
./backup-proxmox-config-<Datum>.sh
```

## 📅 Automatisierung

Das Skript kann z. B. via `cron` regelmäßig ausgeführt werden. Beispiel für täglichen Cronjob um 3:00 Uhr:

```bash
0 3 * * * /root/backup-proxmox-config-<Datum>.sh
```

## 📝 Hinweis

Stelle sicher, dass `/mnt/storagebox` korrekt gemountet ist, bevor du das Skript verwendest.
