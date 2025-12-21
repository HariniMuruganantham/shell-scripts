
# Backup & Disk Cleanup Utility

  

A professional Bash utility designed for automated data backups and intelligent disk space management on Linux systems.

  

## 📌 Features

  

*  **Automated Backups**: Creates compressed `.tar.gz` archives with unique timestamps.

*  **Retention Policy**: Automatically deletes old backups based on a user-defined day limit.

*  **Threshold Monitoring**: Checks disk usage and only triggers cleanup when the storage is nearly full.

*  **System Cleanup**: Purges old system logs and temporary files to recover disk space.

*  **Logging**: Maintains a detailed audit trail of every job execution.

  

---

  

## ⚙️ Configuration

  

Open the script and modify the following variables in the **CONFIGURATION** section to suit your environment:

  

| Variable | Description | Default Value |

| :--- | :--- | :--- |

| `SOURCE_DIR` | Directory containing the data to be backed up | `$HOME/data` |

| `BACKUP_DIR` | Destination directory for backup files | `$HOME/backups` |

| `RETENTION_DAYS` | Number of days to keep backup files | `7` |

| `DISK_THRESHOLD` | % usage that triggers cleanup (0-100) | `80` |

| `LOG_FILE` | Path to the script execution log | `$HOME/backup_cleanup.log` |

  

---

  

## 🚀 Getting Started

  

### 1. Prerequisites

Ensure you have permissions to write to the backup directory and read the source directory.

  

### 2. Set Permissions

Make the script executable:

```bash

chmod  +x  backup_and_cleanup.sh

3.  Run  Manually

Execute  the  script  to  verify  the  configuration:

Bash

./backup_and_cleanup.sh

4.  Schedule  with  Cron

To  automate  this  process (e.g., run  every  day  at  midnight), add it to your crontab:

  

Bash

  

crontab  -e

Add  the  following  line:

  

Bash

  

00  00  *  *  *  /absolute/path/to/backup_and_cleanup.sh

  

📂  Workflow

Validation:  Checks  if  the  source  directory  exists.

  

Backup:  Compresses  the  source  into  a  .tar.gz  file.

  

Rotation:  Deletes  backups  older  than  RETENTION_DAYS.

  

Analysis:  Calculates  current  disk  usage  percentage.

  

Emergency  Cleanup:  If  usage > DISK_THRESHOLD,  it  clears:

  

Log  files  older  than  7  days  in  /var/log.

  

Temporary  files  older  than  3  days  in  /tmp.

 ```

👤  Author

Harini  Muruganantham