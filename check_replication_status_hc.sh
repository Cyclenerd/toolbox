#!/bin/bash

# check_replication_status_hc.sh - Check MySQL Replication and send status to healthchecks.io
# Author: Nils Knieling - https://github.com/Cyclenerd
# Source: https://handyman.dulare.com/mysql-replication-status-alerts-with-bash-script/

# healthchecks.io UUID
MY_HC_ID=''

# Maximum number of seconds behind master
MY_MAX_SEC_BEHIND=300

# Checking MySQL replication status
# Set username and password in .my.cnf
if ! mysql -e 'SHOW SLAVE STATUS \G' | grep 'Running:\|Master:\|Error:' > "/tmp/mysql_replication_status_hc.txt"; then
    echo "Login failed" > "/tmp/mysql_replication_status_hc.txt"
fi

# displaying results, just in case you want to see them
echo "Results:"
cat "/tmp/mysql_replication_status_hc.txt"

# checking parameters
slaveRunning=$(grep -c "Slave_IO_Running: Yes" "/tmp/mysql_replication_status_hc.txt")
slaveSQLRunning=$(grep -c "Slave_SQL_Running: Yes" "/tmp/mysql_replication_status_hc.txt")
secondsBehind="$(grep "Seconds_Behind_Master" "/tmp/mysql_replication_status_hc.txt" | tr -dc '0-9')"

echo
echo "slaveRunning    : $slaveRunning"
echo "slaveSQLRunning : $slaveSQLRunning"
echo "secondsBehind   : $secondsBehind"
echo

# Send status to healthchecks.io
if [[ $slaveRunning != 1 || $slaveSQLRunning != 1 || $secondsBehind -gt $MY_MAX_SEC_BEHIND ]]; then
    # Error
    echo "Error"
    curl -fsS -m 10 --retry 5 -o /dev/null "https://hc-ping.com/$MY_HC_ID/fail"
    exit 9
else
    # OK
    echo "OK"
    curl -fsS -m 10 --retry 5 -o /dev/null "https://hc-ping.com/$MY_HC_ID"
fi