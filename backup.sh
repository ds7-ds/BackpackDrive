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
# https://www.cyberciti.biz/tips/linux-unix-pause-command.html
# https://www.linuxtechi.com/compare-numbers-strings-files-in-bash-script/
# https://stackoverflow.com/questions/4277665/how-do-i-compare-two-string-variables-in-an-if-statement-in-bash

# Get local user to access folders
USER=$(whoami)

# Check if backup drive is connected
FOLDER_FROM="darshan"
FOLDER_TO="darshan"
DRIVE_BACKUP="BACKUP A"
cd /media/"$USER"/"$DRIVE_BACKUP"/"$FOLDER_TO" &> /dev/null
DRIVE_MOUNTED_STATUS=$?

# If connected, backup files otherwise display an error message and quit
if [ $DRIVE_MOUNTED_STATUS -eq 0 ]
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
	if [ $BACKUP_MOD_TIME -lt $LOCAL_MOD_TIME ]
	then
		echo "Updating backup with newer local folder..."
		echo ""
		cd ~/Documents
		rsync --verbose --recursive --update --delete-after $FOLDER_FROM/ /media/$USER/"$DRIVE_BACKUP"/$FOLDER_TO
	else
		echo "Backup is current. No update needed..."
		echo ""
		read -t 5 -p "Download backup and replace local copy? [y/n]: " response
		if [[ $response == "y" ]]
		then
			echo "Replacing local copy with backup..."
			rsync --verbose --recursive --update --delete-after /media/$USER/"$DRIVE_BACKUP"/$FOLDER_TO $FOLDER_FROM/
		elif [[ $response == "n" ]]
		then
			echo "No action performed..."
		else
			echo ""
		fi
	fi
else
	echo "Cannot backup to"$DRIVE_BACKUP". No USB drive detected..."
fi
