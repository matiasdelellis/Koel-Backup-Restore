# Koel-Backup-Restore

This repository contains two bash scripts for backup/restore of [Koel](https://koel.phanan.net/)

**Important:**

After cloning or downloading the repository, you'll have to edit the .env file to represent your current Koel installation (directories, users, etc.).

## Backup

In oder to create a backup, simplly call the script *KoelBackup.sh* on your Koel machine.
This will create a direcotry with the current time stamp in your main backup directory.

## Restore

For restore, just call *KoelRestore.sh*. This script expects one parameter which is the name of the backup to be restored. So the full command for a restore would be *./KoelRestore.sh 20170910_132703*.

** Note **

Long based on [Nextcloud-Backup-Restore](https://github.com/DecaTec/Nextcloud-Backup-Restore). Thank you so much!.