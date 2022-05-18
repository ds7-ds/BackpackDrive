#!/bin/bash

#####################################################################################
#                                                                                   #
# Auto backup "Darshan" folder in Documents to USB Flash backup drives if connected #
#                                                                                   #
#####################################################################################

# Credit to these posts for helping me out:
# https://unix.stackexchange.com/questions/408978/fastest-way-to-determine-if-directory-contents-have-changed-since-last-time
# https://stackoverflow.com/questions/4997242/in-linux-terminal-how-do-i-show-the-folders-last-modification-date-taking-its
# https://stackoverflow.com/questions/2355148/run-a-string-as-a-command-within-a-bash-script
# https://unix.stackexchange.com/questions/377891/copy-whole-folder-from-source-to-destination-and-remove-extra-files-or-folder-fr
# https://askubuntu.com/questions/420981/how-do-i-save-terminal-output-to-a-file
# https://stackoverflow.com/questions/14922562/how-do-i-copy-folder-with-files-to-another-folder-in-unix-linux
# https://stackoverflow.com/questions/4561895/how-to-recursively-find-the-latest-modified-file-in-a-directory
# https://linuxize.com/post/linux-cut-command/
# https://unix.stackexchange.com/questions/226310/using-file-date-time-as-metadata-reliable

# Get local user to access folders
USER=$(whoami)

# Check if backup drive is connected
FOLDER_FROM="darshan"
FOLDER_TO="darshan"
DRIVE_BACKUP="BACKUP A"
cd /media/"$USER"/"$DRIVE_BACKUP"/"$FOLDER_TO" &> /dev/null
DRIVE_MOUNTED_STATUS=$?

# If connected, backup files otherwise display an error message and quit
if [[ $DRIVE_MOUNTED_STATUS == 0 ]]
then
	echo "Backing up files to: "$DRIVE_BACKUP"..."
	# Go to Documents and obtain local folder modification date
	cd ~/Documents
	LOCAL_MOD_TIME=$(find $FOLDER_FROM/ -type d -printf '%T@ %p\n' | sort -n | tail -1 | cut -f1 -d".")
	LOCAL_MOD_DATE=$(date -d @$LOCAL_MOD_TIME)
	echo "Last modification to local folder "$FOLDER_FROM": "$LOCAL_MOD_DATE
	# Go to backup drive, get mod date, and compare dates
	cd /media/"$USER"/"$DRIVE_BACKUP"
	BACKUP_MOD_TIME=$(find $FOLDER_TO/ -type d -printf '%T@ %p\n' | sort -n | tail -1 | cut -f1 -d".")
	BACKUP_MOD_DATE=$(date -d @$BACKUP_MOD_TIME)
	echo "Last modification to backup folder "$FOLDER_TO": "$BACKUP_MOD_DATE
	if [[ $BACKUP_MOD_DATE < $LOCAL_MOD_DATE ]]
	then
		echo "Updating backup with newer local folder..."
		echo ""
		cd ~/Documents
		rsync --verbose --recursive --update --delete-after $FOLDER_FROM/ /media/$USER/"$DRIVE_BACKUP"/$FOLDER_TO
	else
		echo "Backup is current. No update needed..."
	fi
else
	echo "Cannot backup to"$DRIVE_BACKUP". No USB drive detected..."
fi
