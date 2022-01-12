#!/bin/bash


# Auto backup "Darshan" folder in Documents to USB Flash backup drives if connected


# Wait for OS to load entirely before starting
#sleep 1s
# Get local user to access folders
USER=$(whoami)
echo $USER
cd /media/$USER
# Get USB drive name and check if it's the backup drive
DRIVE_MOUNTED=$(ls)
echo $DRIVE_MOUNTED
DRIVE_A="BACKUP A"
if [ "$DRIVE_MOUNTED"=="$DRIVE_A" ]
then
	echo "Backing up files to USB"
	# Go to Documents and obtain local folder modification date
	cd ~/Documents
	ls
	TEMP_DATE_1=$(stat 'Darshan' | grep "Modify" | cut -c 9-27)
	LOCAL_MOD_DATE=$(date -d "$TEMP_DATE_1" +%s)
	echo $LOCAL_MOD_DATE
	# Go to backup drive, get mod date, and compare dates
	cd /media/"$USER"/"$DRIVE_MOUNTED"
	ls
	TEMP_DATE_2=$(stat 'Darshan' | grep "Modify" | cut -c 9-27)
	BACKUP_MOD_DATE=$(date -d "$TEMP_DATE_2" +%s)
	echo $BACKUP_MOD_DATE
	if [[ "$BACKUP_MOD_DATE" < "$LOCAL_MOD_DATE" ]]
	then
		echo "Backup is old"
		rm -rf Darshan
		cd ~/Documents
		cp -r -v Darshan /media/"$USER"/"$DRIVE_MOUNTED"/Darshan
	else
		echo "Backup is current"
	fi
else
	echo "Cannot backup to USB"
fi

