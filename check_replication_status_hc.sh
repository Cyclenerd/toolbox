#!/usr/bin/env bash

# check_replication_status_hc.sh
#
# Check MySQL 8.0 replication status and ping healthchecks.io
#
# Author: Nils Knieling - https://github.com/Cyclenerd
# Source: https://handyman.dulare.com/mysql-replication-status-alerts-with-bash-script/

# healthchecks.io UUID
MY_HC_ID=""
# Maximum number of seconds behind master
MY_MAX_SEC_BEHIND=30

# Checking MySQL replication status
# Set username and password in .my.cnf
if ! mysql -e 'SHOW REPLICA STATUS \G' | grep 'Running:\|Source:\|Error:' > "/tmp/mysql_replication_status_hc.txt"; then
    echo "Login failed" > "/tmp/mysql_replication_status_hc.txt"
fi

# displaying results, just in case you want to see them
echo "Results:"
cat "/tmp/mysql_replication_status_hc.txt"

# checking parameters
MY_REPLICA_IO_RUNNING=$(grep -c "Replica_IO_Running: Yes" "/tmp/mysql_replication_status_hc.txt")
MY_REPLICA_SQL_RUNNING=$(grep -c "Replica_SQL_Running: Yes" "/tmp/mysql_replication_status_hc.txt")
MY_SECONDS_BEHIND_SOURCE=$(grep "Seconds_Behind_Source" "/tmp/mysql_replication_status_hc.txt" | tr -dc '0-9')

echo
echo "Replica_IO_Running    : $MY_REPLICA_IO_RUNNING"
echo "Replica_SQL_Running   : $MY_REPLICA_SQL_RUNNING"
echo "Seconds_Behind_Source : $MY_SECONDS_BEHIND_SOURCE"
echo

# Send status to healthchecks.io
if [[ $MY_REPLICA_IO_RUNNING != 1 || $MY_REPLICA_SQL_RUNNING != 1 || $MY_SECONDS_BEHIND_SOURCE -gt $MY_MAX_SEC_BEHIND ]]; then
    # Error
    echo "Error"
    curl -fsS -m 10 --retry 5 -o /dev/null "https://hc-ping.com/$MY_HC_ID/fail"
    exit 9
else
    # OK
    echo "OK"
    curl -fsS -m 10 --retry 5 -o /dev/null "https://hc-ping.com/$MY_HC_ID"
fi