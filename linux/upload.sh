#!/bin/bash

################################################################################
# References:
# https://stackoverflow.com/questions/2652753/loading-variables-from-a-text-file-into-bash-script
# https://www.computerhope.com/unix.htm
# https://askubuntu.com/questions/474556/hiding-output-of-a-command
# 
################################################################################



# Check OS and determine if program can run on system
clear
echo "OS:                "$OSTYPE
if [ $OSTYPE == "linux-gnu" ];
then
	echo "OS support status: Supported"
	echo
else
	echo "OS support status: Not supported"
	echo
	exit
fi



# Get information from setup file
input=$(cat setup.ini | grep "=" | sed 's/\=/\ /g')
set -- $input
while [ $1 ]
do
	eval $1=$2
	shift 2
done
echo "Local location:  "$local"/"$folder
echo "Backup location: "$backup"/"$folder
echo



# Check if backup drive is connected
drives=`lsblk | grep $backup`
if [[ $drives == *"$backup"* ]]
then
	echo "Backup drive status: Mounted"
	echo
else
	echo "Backup drive status: Not mounted"
	exit
fi



# Check if folder exists in local and backup drives
ready=0
cd $local
find $folder/ -maxdepth 0 > /dev/null 2>&1
if [ $? -eq 1 ]
then
	echo "Local folder status: Missing"
	ready=1
else
	echo "Local folder status: Ready"	
fi
cd $backup
find $folder/ -maxdepth 0 > /dev/null 2>&1
if [ $? -eq 1 ]
then
	echo "Backup folder status: Missing"
	ready=1
else
	echo "Backup folder status: Ready"	
fi
cd .
if [ $ready -eq 0 ]
then
	echo
else
	exit
fi



# Get dates of last modification to backup and local folders
local_mod_time=$(find $local/$folder -type d -printf '%T@ %p\n' | sort -n | tail -1 | cut -f1 -d".")
local_mod_date=$(date -d @$local_mod_time)
echo "Last modification to local:  "$local_mod_date
backup_mod_time=$(find $backup/$folder -type d -printf '%T@ %p\n' | sort -n | tail -1 | cut -f1 -d".")
backup_mod_date=$(date -d @$backup_mod_time)
echo "Last modification to backup: "$backup_mod_date
echo



# Upload local files to backup drive if modified
notify-send "USB-Backup" "Status: started"
rsync --verbose --recursive --update --delete-after $local/$folder $backup
notify-send "USB-Backup" "Status: ended"


