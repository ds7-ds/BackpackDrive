#!/bin/bash

#####################################################################################
#                                                                                   #
# Auto backup "Darshan" folder in Documents to USB Flash backup drives if connected #
#                                                                                   #
#####################################################################################

# Get local user to access folders
USER=$(whoami)

# Check if backup drive is connected
FOLDER_FROM="darshan"
FOLDER_TO="darshan"
DRIVE_BACKUP="BACKUP A"
cd /media/"$USER"/"$DRIVE_BACKUP"/"$FOLDER_TO" &> /dev/null
DRIVE_MOUNTED_STATUS=$?

# If connected, backup files otherwise display an error message and quit
if [ $DRIVE_MOUNTED_STATUS == 0 ]
then
	echo "Backing up files to: "$DRIVE_BACKUP"..."
	# Go to Documents and obtain local folder modification date
	cd ~/Documents
	TEMP_DATE_1=$(stat $FOLDER_FROM | grep "Modify" | cut -c 9-27)
	LOCAL_MOD_DATE=$(date -d "$TEMP_DATE_1" +%s)
	echo "Last modification to local folder "$FOLDER_FROM": "$TEMP_DATE_1
	# Go to backup drive, get mod date, and compare dates
	cd /media/"$USER"/"$DRIVE_BACKUP"
	TEMP_DATE_2=$(stat $FOLDER_TO | grep "Modify" | cut -c 9-27)
	BACKUP_MOD_DATE=$(date -d "$TEMP_DATE_2" +%s)
	echo "Last modification to backup folder "$FOLDER_TO": "$TEMP_DATE_2
	if [[ $BACKUP_MOD_DATE < $LOCAL_MOD_DATE ]]
	then
		echo "Updating backup with newer local folder..."
		echo ""
		cd ~/Documents
		rsync --verbose --recursive --update --delete-after $FOLDER_FROM/ /media/$USER/$DRIVE_BACKUP/$FOLDER_TO
	else
		echo "Backup is current. No update needed..."
	fi
else
	echo "Cannot backup to"$DRIVE_BACKUP". No USB drive detected..."
fi

