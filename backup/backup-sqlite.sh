#!/usr/bin/env bash

#
# Create rotating SQLite backups
#

# Backup location
BACKUP_PATH='/private-backup/sqlite'

# Location of the database
MY_DATABASE="/var/lib/sqlite/users.sqlite"

# Maximum number of backups
ROT_PERIOD=30


# fetch biggest id in dir
cd "$BACKUP_PATH" || exit

BIG_ID=$( ls -1 *_dump.gz | wc -l ) &> /dev/null

if [ ! "$BIG_ID" ];
then
  BIG_ID=0
fi

# rotation if at least 1_dump.gz
NEXT_ID=0
for i in $( seq 1 $BIG_ID );
do
  NEXT_ID=$((i+1))
  NEXT_FILENAME=$NEXT_ID'_dump.gz'
  FILENAME="$i""_dump.gz"
    if [ -e "$FILENAME" ];
    then
     # echo "$FILENAME exists"
     if [ "$i" = "$ROT_PERIOD"  ];
     then
       # echo "Removing oldest archive..."
       rm "$i""_dump.gz"
     else
       # echo "Rotating $i..."
       cp "$FILENAME" "$NEXT_FILENAME"
     fi
    fi
done

# Converting  entire database to an ASCII text file
echo '.dump' | sqlite3 "$MY_DATABASE" | gzip -c >"$BACKUP_PATH/1_dump.gz"