#!/bin/bash

# Auto backup "Darshan" folder in Documents to USB Flash backup drives if connected
USER=$(whoami)
cd /media/$USER
DRIVE_MOUNTED=$(ls)
echo $DRIVE_MOUNTED
DRIVE_A="BACKUP A"
if [ "$DRIVE_MOUNTED"=="$DRIVE_A" ]
then
	echo "Backing up files to USB"
else
	echo "Cannot backup to USB"
fi

