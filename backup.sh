#! /bin/bash

# A simple script that makes incremental backups using rsync
# This script should be run using sudo if you plan to backup system-wide folders 

# Requests the backup source and its destination 
read -p 'Please, select the backup source: ' SOURCE_VAR
read -p 'Please, select the backup destination: ' DESTINATION_VAR
echo
echo The backup source is $SOURCE_VAR and its destination is $DESTINATION_VAR
echo

# Checks if the user wants to remove destination files do not matching the source
read -p 'Type YES to delete the destination folder files that do not match the source: ' DELETE_VAR

if [ "$DELETE_VAR" = "YES" ]
then
# Copies files from the source to the destination and deletes the destination files that do not match the source
rsync -aP --delete $SOURCE_VAR $DESTINATION_VAR
else
# Copies files from the source to the destination without removing files that do not match the source
rsync -aP $SOURCE_VAR $DESTINATION_VAR
fi

echo
echo Done
