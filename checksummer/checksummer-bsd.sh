#!/usr/local/bin/bash

#
# Simple md5 Chechsum Builder for *BSD
#

STATICDIRS="/bin /boot /etc /sbin /usr"
#STATICDIRS="/etc"

CFV="/usr/local/bin/cfv"

if [ "$UID" != "0" ]; then
	echo -e "\033[40m\033[1;31mERROR: Root check FAILED (you MUST be root to use this script)!\033[0m"
	exit 1
fi

case "$1" in
create)
	for dir in ${STATICDIRS}
	do
		find "$dir" -type f \! \( -path "/usr/ports/*" \
			-or -path "/usr/src/*" \
			-or -path "/usr/local/man/*" \
			-or -path "/usr/local/lib/perl5/5.6.1/man/*" \
			-or -path "/usr/share/openssl/man/*" \
			-or -path "/usr/share/man/*" \) \
			-exec $CFV -t md5 -C -VV -f - \{\} \;
	done
	;;
check)
	$CFV -t md5 -f -
	;;
*)
	echo "Usage:"
	echo "Create:	$0 create > file"
	echo "Check:	$0 check < file"
	exit 1
	;;
esac
