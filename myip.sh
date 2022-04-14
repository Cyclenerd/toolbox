#!/usr/bin/env bash

#
# Get public external IPv4 address of your own local network
#

# External URL that returns your IP
MY_GET_IP_URL="https://domains.google.com/checkip"
#MY_GET_IP_URL="https://ifconfig.me"
#MY_GET_IP_URL="http://whatismyip.akamai.com/"
#MY_GET_IP_URL="https://api.ipify.org"

command -v curl >/dev/null 2>&1 || { echo >&2 "'curl' is needed. Please install 'curl'. More details can be found at https://curl.haxx.se/"; exit 1; }

MY_EXTERNAL_IP=$(curl -4 --silent "$MY_GET_IP_URL")
if [ -z "$MY_EXTERNAL_IP" ]; then
	echo "!!! ERROR !!! Could not discover current external IPv4 address"
	exit 9
else
	echo "$MY_EXTERNAL_IP"
fi