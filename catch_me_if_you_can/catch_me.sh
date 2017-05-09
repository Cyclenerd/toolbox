#!/usr/bin/env bash

#
# catch_me.sh
# Author: Nils Knieling
#    https://github.com/cyclenerd/toolbox/catch_me_if_you_can/
#
# This little Bash script tries to copy a file when it has changed.
# For this, the last modification date is compared.
# A new copy is created for each change.
# The file name is <TIMESTAMP>_<PID>.
#


#####################################################################
#### Configuration Section
#####################################################################

# File to be monitored.
#     If this file changes, it is copied.
MY_FILE="/tmp/test"

# Folder where the copies are saved.
#    The folder must exist and you must have write permission.
MY_DIR="/tmp/copy"

#####################################################################
#### END Configuration Section
#####################################################################


MY_TIMESTAMP_START=$(date "+%s")

if [ ! -e $MY_FILE ]; then
	echo "WARNING: '$MY_FILE' does not exist."
	exit 2
fi

if [ ! -d $MY_DIR ]; then
	echo "ERROR: '$MY_DIR' does not exist or no folder."
	exit 9
fi

if [ ! -w $MY_DIR ]; then
	echo "ERROR: No write permission on folder '$MY_DIR'."
	exit 9
fi

# Get filename of the last copied file
unset -v MY_LAST_FILE
for MY_DIR_FILE in "$MY_DIR"/*; do
	[[ $MY_DIR_FILE -nt $MY_LAST_FILE ]] && MY_LAST_FILE=$MY_DIR_FILE
done

# Compare files
MY_FILENAME="$MY_TIMESTAMP_START""_""$$"
if [[ $MY_FILE -nt $MY_LAST_FILE ]]; then
	if cp "$MY_FILE" "$MY_DIR/$MY_FILENAME"; then
		echo "INFO: '$MY_FILE' has changed. Copied to '$MY_DIR/$MY_FILENAME'."
		exit 0
	else
		echo "ERROR: Can not copy file '$MY_FILE' to '$MY_DIR/$MY_FILENAME'."
		exit 9
	fi
else
	echo "INFO: '$MY_FILE' has not changed."
	exit 1
fi
