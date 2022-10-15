#!/bin/bash

# Run mydumper and save either in folder [NUMBER]A or [NUMBER]B.
# If successful, delete the other folder (A or B).

# Configuration file ~/.my.conf:
#
# [mydumper]
# host=127.0.0.1
# user=root
# password=[PASSWORD]
# 
# [myloader]
# host=127.0.0.1
# user=root
# password=[PASSWORD]

ME=$(basename "$0")
MY_DIR="/mnt/usb_wd_4tb_crypt/backup"

function usage {
    returnCode="$1"
    echo
    echo -e "Usage: 
    $ME -d <DIR> -n <NUMBER>] [-h]
    -d <DIR>    Backup directory (Default: '$MY_DIR')
    -n <NUMBER> Folder number
    [-h]        Displays help (this message)"
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

command -v mydumper >/dev/null 2>&1 || { echo >&2 "!!! Error !!! mydumper it's not installed."; exit 1; }

if ((MY_NUMBER >= 1)); then
    echo "Folder number: $MY_NUMBER"
else
    echo "Folder number for backup missing"
    exit 3
fi

if [ -d "$MY_DIR" ]; then
    MY_DIR=${MY_DIR%/}
    echo "Backup dir: $MY_DIR"
else
    echo "Backup dir missing or directory '$MY_DIR' does not exists."
    exit 2
fi

MY_BACKUP_DIR_A="$MY_DIR""/""$MY_NUMBER""A"
MY_BACKUP_DIR_B="$MY_DIR""/""$MY_NUMBER""B"

if [ -d "$MY_BACKUP_DIR_A" ]; then
    mkdir -p "$MY_BACKUP_DIR_B"
    echo "Backup to: $MY_BACKUP_DIR_B"
        if mydumper --outputdir "$MY_BACKUP_DIR_B"; then
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
    if mydumper --outputdir "$MY_BACKUP_DIR_A"; then
        echo "Success. Delete old backup."
        rm -rf "$MY_BACKUP_DIR_B"
    else
        echo "!!! Error !!! Delete current and errored backup."
        rm -rf "$MY_BACKUP_DIR_A"
        exit 9
    fi
fi