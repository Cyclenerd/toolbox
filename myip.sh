#!/usr/bin/env bash

# exit_with_failure() outputs and a message before exiting the script.
function exit_with_failure() {
	echo
	echo "$1"
	echo
	exit 9
}

# command_exists() tells if a given command exists.
function command_exists() {
	command -v "$1" >/dev/null 2>&1
}

if ! command_exists curl; then
	exit_with_failure "'curl' is needed. Please install 'curl'. More details can be found at https://curl.haxx.se/"
fi

ip=$(curl -s https://api.ipify.org)

echo
echo -n "Public IP Address: $ip"

# Onyl macOS 
if command_exists pbcopy; then
	echo "$ip" | pbcopy
	echo -n " (copied to clipboard)"
fi

echo
echo