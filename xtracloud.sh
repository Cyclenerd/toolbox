#!/bin/bash

# Backup to S3 Bucket dir <NUMBER> with xtrabackup and xbcloud

# Configuration file ~/.my.conf:
#
# [xtrabackup]
# user=root
# password=XXX
# [xbcloud]
# storage=s3
# parallel=10
# s3-endpoint=https://s3.eu-central-003.backblazeb2.com/
# s3-access-key=XXX
# s3-secret-key=XXX
# s3-bucket=mysql-backup-XXX
# s3-bucket-lookup=path
# s3-api-version=4

# More help: https://www.percona.com/doc/percona-xtrabackup/2.4/xbcloud/xbcloud.html


ME=$(basename "$0")
MY_TMP_DIR="/mnt/HC_Volume_1997648/backup"

function usage {
    returnCode="$1"
    echo
    echo -e "Usage: 
    $ME -n <NUMBER>] [-h]
    -t <TEMP DIR> Dir for temporary files (Default: '$MY_TMP_DIR')
    -n <NUMBER>   Folder number for backup in S3 Bucket
    [-h]          Displays help (this message)"
    echo
    exit "$returnCode"
}

while getopts "t:n:h" opt; do
    case $opt in
    t)
        MY_TMP_DIR="$OPTARG"
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
command -v xbcloud >/dev/null 2>&1    || { echo >&2 "!!! Error !!! xbcloud it's not installed."; exit 1; }
command -v xbstream >/dev/null 2>&1   || { echo >&2 "!!! Error !!! xbstream it's not installed."; exit 1; }

if ((MY_NUMBER >= 1)); then
    echo "Folder number: $MY_NUMBER"
else
    echo "Folder number for backup missing"
    exit 3
fi

if [ -d "$MY_TMP_DIR" ]; then
    MY_TMP_DIR=${MY_TMP_DIR%/}
    echo "Temp dir: $MY_TMP_DIR"
else
    echo "!!! Error !!! Temp dir missing or directory '$MY_TMP_DIR' does not exists."
    exit 2
fi

xbcloud delete "$MY_NUMBER"

if xtrabackup --backup --slave-info --safe-slave-backup --stream=xbstream --extra-lsndir="$MY_TMP_DIR" --target-dir="$MY_TMP_DIR" | xbcloud put "$MY_NUMBER"; then
    echo "Success."
else
    echo "!!! Error !!! Backup to S3 Bucket folder '$MY_NUMBER'"
    exit 9
fi
