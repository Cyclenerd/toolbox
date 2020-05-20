#!/bin/bash

# Run xtrabackup
# Save either in folder <NUMBER>A or <NUMBER>B
# If successful, delete the other folder (A or B)

ME=$(basename "$0")

function usage {
    returnCode="$1"
    echo
    echo -e "Usage: 
    $ME -d <DIR> -n <NUMBER>] [-h]
    -d <DIR>\\t Backup dir
    -n <NUMBER>\\t Folder number
    [-h]\\t\\t displays help (this message)"
    echo
    exit "$returnCode"
}

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

command -v xtrabackup >/dev/null 2>&1 || { echo >&2 "!!! Error !!! xtrabackup it's not installed."; exit 1; }

if [ -d "$MY_DIR" ]; then
    MY_DIR=${MY_DIR%/}
    echo "Backup dir: $MY_DIR"
else
    echo "Backup dir missing or directory '$MY_DIR' DOES NOT exists."
    exit 2
fi

if ((MY_NUMBER >= 1)); then
    echo "Folder number: $MY_NUMBER"
else
    echo "Folder number for backup missing"
    exit 3
fi

MY_BACKUP_DIR_A="$MY_DIR""/""$MY_NUMBER""A"
MY_BACKUP_DIR_B="$MY_DIR""/""$MY_NUMBER""B"

if [ -d "$MY_BACKUP_DIR_A" ]; then
    mkdir -p "$MY_BACKUP_DIR_B"
    echo "Backup to: $MY_BACKUP_DIR_B"
        if xtrabackup --backup --slave-info --safe-slave-backup --target-dir="$MY_BACKUP_DIR_B"; then
        echo "Success. Delete old backup."
        rm -rf "$MY_BACKUP_DIR_A"
    else
        echo "!!! Error !!! Delete current and errored backup."
        rm -rf "$MY_BACKUP_DIR_B"
        exit 9
    fi
else
    mkdir -p "$MY_BACKUP_DIR_A"
    echo "Backup to: $MY_BACKUP_DIR_A"
    if xtrabackup --backup --slave-info --safe-slave-backup --target-dir="$MY_BACKUP_DIR_A"; then
        echo "Success. Delete old backup."
        rm -rf "$MY_BACKUP_DIR_B"
    else
        echo "!!! Error !!! Delete current and errored backup."
        rm -rf "$MY_BACKUP_DIR_A"
        exit 9
    fi
fi