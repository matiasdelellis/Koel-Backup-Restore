#!/bin/bash

#
# Bash script for restoring backups of Koel.
# Usage: ./KoelRestore.sh <BackupName> (e.g. ./KoelRestore.sh 20170910_132703)
# 
# IMPORTANT
# You have to customize the .env file with directories, users, etc. for your actual environment.
# All entries which need to be customized are tagged with "TODO".
#

# Variables
source ./.env

restore=$1
currentRestoreDir="${backupMainDir}/${restore}"

# Function for error messages
errorecho() { cat <<< "$@" 1>&2; }

#
# Check if parameter given
#
if [ $# != "1" ]
then
    errorecho "ERROR: No backup name to restore given!"
    errorecho "Usage: KoelRestore.sh 'BackupDate'"
    exit 1
fi

#
# Check for root
#
if [ "$(id -u)" != "0" ]
then
    errorecho "ERROR: This script has to be run as root!"
    exit 1
fi

#
# Check if backup dir exists
#
if [ ! -d "${currentRestoreDir}" ]
then
    errorecho "ERROR: Backup ${currentRestoreDir} not found!"
    exit 1
fi

#
# Stop web server
#
echo "Stopping web server..."
service "${webserverServiceName}" stop
echo "Done"
echo

#
# Delete old Koel direcories
#
echo "Deleting old Koel data directory..."
rm -r "${koelDataDir}"
mkdir -p "${koelDataDir}"
echo "Done"
echo

#
# Restore file and data directory
#
echo "Restoring Koel data directory..."
tar -xpzf "${currentRestoreDir}/${fileNameBackupDataDir}" -C "${koelDataDir}"
echo "Done"
echo

#
# Restore database
#
echo "Dropping old Koel DB..."
mysql -h localhost -u "${dbUser}" -p"${dbPassword}" -e "DROP DATABASE ${koelDatabase}"
echo "Done"
echo

echo "Creating new DB for Koel..."
mysql -h localhost -u "${dbUser}" -p"${dbPassword}" -e "CREATE DATABASE ${koelDatabase}"
echo "Done"
echo

echo "Restoring backup DB..."
mysql -h localhost -u "${dbUser}" -p"${dbPassword}" "${koelDatabase}" < "${currentRestoreDir}/${fileNameBackupDb}"
echo "Done"
echo

#
# Start web server
#
echo "Starting web server..."
service "${webserverServiceName}" start
echo "Done"
echo

#
# Set directory permissions
#
echo "Setting directory permissions..."
chown -R "${webserverUser}":"${webserverUser}" "${koelDataDir}"
echo "Done"
echo

echo
echo "DONE!"
echo "Backup ${restore} successfully restored."
