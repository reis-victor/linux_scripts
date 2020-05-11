#! /bin/bash

# A simple script that makes incremental backups using rsync
# This script should be run using sudo if you plan to backup system-wide folders 

# Requests the backup source and its destination 
read -p 'Please, select the backup source using the format /dev/sdx:   ' SOURCE
echo
read -p 'Please, select the backup destination using the format /dev/sdx:   ' DESTINATION
echo
echo The backup source is $SOURCE and its destination is $DESTINATION
echo

# Checks if the user wants to remove destination files do not matching the source
read -p 'Type YES to delete the destination folder files that do not match the source: ' DELETE
echo
grep -q YES <<< $DELETE && rsync -aP --delete $SOURCE $DESTINATION || rsync -aP $SOURCE $DESTINATION
echo
echo Done
