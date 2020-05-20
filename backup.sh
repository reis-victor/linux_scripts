#! /bin/bash

cat <<EOF > $HOME/Documents/scripts/backup.sh
#! /bin/bash

# A simple script that makes incremental backups using rsync
# This script should be run using sudo if you plan to backup system-wide folders 

# Requests the backup source and its destination 
read -p 'Please, input the backup source:   ' SOURCE
echo
read -p 'Please, input the backup destination:   ' DESTINATION
echo
echo The backup source is $SOURCE and its destination is $DESTINATION
echo

# Checks if the user wants to remove destination files do not matching the source
read -p 'Type YES to delete the destination folder files that do not match the source: ' DELETE
echo
grep -q YES <<< $DELETE && sudo rsync -aAXv --delete --checksum --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","swapfile","lost+found","ecryptfs","$HOME/.cache/*","$HOME/.mozilla/*"} $SOURCE $DESTINATION ||sudo rsync -aAXv --checksum --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","swapfile","lost+found","ecryptfs","$HOME/.cache/*","$HOME/.mozilla/*"} $SOURCE $DESTINATION 
echo
echo Done
EOF

SCRIPT_LOCATION=$HOME/Documents/scripts/backup.sh
chmod +x $SCRIPT_LOCATION

cat <<EOF > /etc/cron.daily/backup
#! /bin/bash
00 22 * * * $SCRIPT_LOCATION
EOF
