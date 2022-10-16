#!/usr/bin/env bash

# check_replication_status.sh
#
# Check MySQL 8.0 replication status and send email on error
#
# Author: Nils Knieling - https://github.com/Cyclenerd
# Source: https://handyman.dulare.com/mysql-replication-status-alerts-with-bash-script/

# Send alert to this email (root@localhost it always CC)
MY_MAIL_TO='nils@localhost'
# Maximum number of seconds behind master
MY_MAX_SEC_BEHIND=120
# Set MySQL username and password in .my.cnf

# Check commands
command -v mysql >/dev/null 2>&1 || { echo >&2 "[ERROR] mysql it's not installed!"; exit 1; }
command -v mutt  >/dev/null 2>&1 || { echo >&2 "[ERROR] mutt it's not installed!"; exit 1; }

# Check MySQL replication status
if ! mysql -e 'SHOW REPLICA STATUS \G' | grep 'Running:\|Source:\|Error:' > "/tmp/mysql_replication_status.txt"; then
	echo "Login failed" > "/tmp/mysql_replication_status.txt"
fi

# Check parameters
MY_REPLICA_IO_RUNNING=$(grep -c "Replica_IO_Running: Yes" "/tmp/mysql_replication_status.txt")
MY_REPLICA_SQL_RUNNING=$(grep -c "Replica_SQL_Running: Yes" "/tmp/mysql_replication_status.txt")
MY_SECONDS_BEHIND_SOURCE=$(grep "Seconds_Behind_Source" "/tmp/mysql_replication_status.txt" | tr -dc '0-9')

if [[ $MY_REPLICA_IO_RUNNING != 1 || $MY_REPLICA_SQL_RUNNING != 1 || $MY_SECONDS_BEHIND_SOURCE -gt $MY_MAX_SEC_BEHIND ]]; then
	# Echo error to stderr
	{
		echo "ERROR:"
		cat "/tmp/mysql_replication_status.txt"
		echo
		echo "Replica_IO_Running    : $MY_REPLICA_IO_RUNNING"
		echo "Replica_SQL_Running   : $MY_REPLICA_SQL_RUNNING"
		echo "Seconds_Behind_Source : $MY_SECONDS_BEHIND_SOURCE"
	} >&2
	# Send email
	mutt -s "MySQL: Replication Error - $(hostname)" -c "root@localhost" "$MY_MAIL_TO" < "/tmp/mysql_replication_status.txt"
	exit 9
else
	# echo OK to stdout
	echo "OK"
fi