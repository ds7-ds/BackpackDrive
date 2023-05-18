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
echo "Backup location: "$backup"/"$folder
echo



# Check if backup drive is connected
drives=`lsblk | grep $backup`
if [[ $drives == *"$backup"* ]]
then
	echo "Backup drive status: Mounted"
	echo
else
	echo "Backup drive status: Not Mounted"
	exit
fi



# Check if folder exists in local and backup drives
ready=0
cd $backup
find $folder/ -maxdepth 0 > /dev/null 2>&1
if [ $? -eq 1 ]
then
	echo "Backup folder status: Not created"
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



# Download backup folder to Downloads folder on local drive
rsync --verbose --recursive --update --delete-after $backup/$folder ~/Downloads/
