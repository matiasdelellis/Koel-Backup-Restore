#!/bin/bash

#
# Bash script for creating backups of Koel.
# Usage: ./KoelBackup.sh
# 
# IMPORTANT
# You have to customize the .env file with directories, users, etc. for your actual environment.
# All entries which need to be customized are tagged with "TODO".
#

# Variables
source ./.env

currentDate=$(date +"%Y%m%d_%H%M%S")
backupdir="${backupMainDir}/${currentDate}/"

# Function for error messages
errorecho() { cat <<< "$@" 1>&2; }

#
# Check for root
#
if [ "$(id -u)" != "0" ]
then
	errorecho "ERROR: This script has to be run as root!"
	exit 1
fi

#
# Check if backup dir already exists
#
if [ ! -d "${backupdir}" ]
then
	mkdir -p "${backupdir}"
else
	errorecho "ERROR: The backup directory ${backupdir} already exists!"
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
# Backup and data directory
#
echo "Creating backup of Koel data directory..."
tar -cpzf "${backupdir}/${fileNameBackupDataDir}"  -C "${koelDataDir}" .
echo "Done"
echo

#
# Backup DB
#
echo "Backup Koel database..."
mysqldump --single-transaction -h localhost -u "${dbUser}" -p"${dbPassword}" "${koelDatabase}" > "${backupdir}/${fileNameBackupDb}"
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
# Delete old backups
#
if (( ${maxNrOfBackups} != 0 ))
then	
	nrOfBackups=$(ls -l ${backupMainDir} | grep -c ^d)
	
	if (( ${nrOfBackups} > ${maxNrOfBackups} ))
	then
		echo "Removing old backups..."
		ls -t ${backupMainDir} | tail -$(( nrOfBackups - maxNrOfBackups )) | while read dirToRemove; do
		echo "${dirToRemove}"
		rm -r ${backupMainDir}/${dirToRemove}
		echo "Done"
		echo
    done
	fi
fi

echo
echo "DONE!"
echo "Backup created: ${backupdir}"
