#!/bin/bash

# check_replication_status.sh - Check MySQL Replication
# Author: Nils Knieling - https://github.com/Cyclenerd
# Source: https://handyman.dulare.com/mysql-replication-status-alerts-with-bash-script/

#
# Send alert to this email (root@localhost it always CC)
#
MY_MAIL_TO='nils@localhost'

#
# Set the maximum number of seconds behind master that will be ignored.
# If the slave is be more than MY_MAX_SEC_BEHIND, an email will be sent.
#
MY_MAX_SEC_BEHIND=300

#
# Checking MySQL replication status
# Set username and password in .my.cnf
if mysql -e 'SHOW SLAVE STATUS \G' | grep 'Running:\|Master:\|Error:' > "/tmp/mysql_replication_status.txt"; then
    echo "Login successful"
else
    echo "Login failed" > "/tmp/mysql_replication_status.txt"
fi

#
# displaying results, just in case you want to see them
#
echo "Results:"
cat "/tmp/mysql_replication_status.txt"

#
# checking parameters
#
slaveRunning=$(grep -c "Slave_IO_Running: Yes" "/tmp/mysql_replication_status.txt")
slaveSQLRunning=$(grep -c "Slave_SQL_Running: Yes" "/tmp/mysql_replication_status.txt")
secondsBehind="$(grep "Seconds_Behind_Master" "/tmp/mysql_replication_status.txt" | tr -dc '0-9')"

echo
echo "slaveRunning    : $slaveRunning"
echo "slaveSQLRunning : $slaveSQLRunning"
echo "secondsBehind   : $secondsBehind"

#
# Sending email if needed
#
if [[ $slaveRunning != 1 || $slaveSQLRunning != 1 || $secondsBehind -gt $MY_MAX_SEC_BEHIND ]]; then
    echo ""
    echo "Sending email"
    mutt -s "MySQL: Replication Error - $(hostname)" -c "root@localhost" "$MY_MAIL_TO" < "/tmp/mysql_replication_status.txt"
else
    echo ""
    echo "Replication looks fine."
fi