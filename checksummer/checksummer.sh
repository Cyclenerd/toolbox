#!/bin/bash

#
# Simple md5 Chechsum Builder
#

#STATICDIRS="/bin /boot /etc /sbin /lib /opt /usr"
STATICDIRS="/bin"

if [ "$UID" != "0" ]; then
	echo -e "\033[40m\033[1;31mERROR: Root check FAILED (you MUST be root to use this script)!\033[0m"
	exit 1
fi

case "$1" in
create)
	for dir in ${STATICDIRS}
	do
		find "$dir" -mount -type f -exec md5sum \{\} \;
	done
	;;
check)
	md5sum -c
	;;
*)
	echo "Usage:"
	echo "Create:	$0 create > file"
	echo "Check:	$0 check < file"
	exit 1
	;;
esac
