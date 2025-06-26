#!/bin/bash

# ========================================================================
# MySQL Backup Script using mydumper
# ========================================================================
# Description:
#   This script creates a MySQL database backup using mydumper.
#   It creates the backup in a temporary directory and moves it to the final
#   location only if the backup completes successfully.
#
# Usage:
#   ./mydumper.sh -d /path/to/backup/dir -n backup_number
#
# Requirements:
#   - mydumper must be installed
#   - Configuration file ~/.my.conf must exist with proper credentials:
#     [mydumper]
#     host=127.0.0.1
#     user=root
#     password=PASSWORD
#     
#     [myloader]
#     host=127.0.0.1
#     user=root
#     password=PASSWORD
# ========================================================================

ME=$(basename "$0")
DEFAULT_BACKUP_DIR="/home/backup"

# Display usage information
function usage {
    local returnCode="$1"
    echo
    echo -e "Usage: 
    $ME -d <DIR> -n <NUMBER> [-h]
    -d <DIR>    Backup directory (Default: '$DEFAULT_BACKUP_DIR')
    -n <NUMBER> Folder number
    -h          Displays help (this message)"
    echo
    exit "$returnCode"
}

# Process command line arguments
MY_DIR="$DEFAULT_BACKUP_DIR"
MY_NUMBER=""

while getopts "d:n:h" opt; do
    case $opt in
    d)
        MY_DIR="$OPTARG"
        ;;
    n)
        MY_NUMBER="$OPTARG"
        ;;
    h)
        usage 0
        ;;
    *)
        usage 1
        ;;
    esac
done

# Check if mydumper is installed
if ! command -v mydumper >/dev/null 2>&1; then
    echo >&2 "!!! Error !!! mydumper is not installed."
    exit 1
fi

# Validate backup number
if [[ -z "$MY_NUMBER" ]] || ! [[ "$MY_NUMBER" =~ ^[0-9]+$ ]] || ((MY_NUMBER < 1)); then
    echo "Error: Valid folder number for backup is required (must be a positive integer)"
    exit 3
fi
echo "Folder number: $MY_NUMBER"

# Validate backup directory
if [[ ! -d "$MY_DIR" ]]; then
    echo "Error: Backup directory '$MY_DIR' does not exist."
    exit 2
fi

# Remove trailing slash if present
MY_DIR=${MY_DIR%/}
echo "Backup dir: $MY_DIR"

# Define backup directories
MY_BACKUP_DIR_A="$MY_DIR/$MY_NUMBER"
MY_BACKUP_DIR_B="$MY_DIR/${MY_NUMBER}new"

# Create temporary backup directory
mkdir -p "$MY_BACKUP_DIR_B"
echo "Backup to: $MY_BACKUP_DIR_B"

# Perform the backup
if mydumper --outputdir "$MY_BACKUP_DIR_B"; then
    echo "Backup completed successfully."
    
    # If previous backup exists, remove it before moving the new one
    [[ -d "$MY_BACKUP_DIR_A" ]] && rm -rf "$MY_BACKUP_DIR_A"
    
    # Move the temporary backup to the final location
    mv "$MY_BACKUP_DIR_B" "$MY_BACKUP_DIR_A"
    echo "Backup moved to final location: $MY_BACKUP_DIR_A"
else
    echo "!!! Error !!! Backup failed. Cleaning up temporary files."
    rm -rf "$MY_BACKUP_DIR_B"
    exit 9
fi

echo "Backup process complete."
