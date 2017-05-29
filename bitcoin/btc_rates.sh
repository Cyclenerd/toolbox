#!/usr/bin/env bash

#
# btc_rates.sh
#
# Command line interface for BitBay Bitcoin exchange rates.
#
# Author: Nils Knieling - https://github.com/Cyclenerd
#

PROG=$(basename "$0")

#####################################################################
# Usage
#####################################################################

function usage {
	returnCode="$1"
	echo
	echo -e "Usage: $PROG [-b <BTC>] [-d <USD>] [-e <EUR>] [-h]:
	[-b <BTC>]\t Bitcoins to Eurozone Euro and US Dollar
	[-d <USD>]\t US Dollar to Bitcoins
	[-e <EUR>]\t Eurozone Euro to Bitcoins
	[-h]\t\t displays help (this message)"
	echo
	exit "$returnCode"
}


#####################################################################
# Terminal output helpers
#####################################################################

# exit_with_failure() outputs a message before exiting the script.
function exit_with_failure() {
	echo
	echo "ERROR: $1"
	echo
	exit 9
}


#####################################################################
# Other helpers
#####################################################################

# command_exists() tells if a given command exists.
function command_exists() {
	command -v "$1" >/dev/null 2>&1
}


#####################################################################
# Let's start
#####################################################################

if ! command_exists curl; then
	exit_with_failure "'curl' is needed. Please install 'curl'. More details can be found at https://curl.haxx.se/"
fi

while getopts ":b:d:e:h" opt; do
	case $opt in
	b)
		MY_BTC="$OPTARG"
		;;
	d)
		MY_USD="$OPTARG"
		;;
	e)
		MY_EUR="$OPTARG"
		;;
	h)
		usage 0
		;;
	*)
		echo "Invalid option: -$OPTARG"
		usage 1
		;;
	esac
done

MY_BTC_EUR=$(curl -k -s -f "https://bitpay.com/api/rates/eur" | tr -d '{"code":"EUR","name":"Eurozone Euro","rate":' | tr -d '}')
MY_BTC_USD=$(curl -k -s -f "https://bitpay.com/api/rates/usd" | tr -d '{"code":"USD","name":"US Dollar","rate":' | tr -d '}')

echo
echo "---------------------------------------------"
echo "Bitcoin Exchange Rates"
echo "    https://bitpay.com/bitcoin-exchange-rates"
echo "---------------------------------------------"

# 1 BTC to EUR
if [[ $MY_BTC_EUR =~ ^[0-9\.]+$ ]]; then
	printf "%.0f BTC  ⤮   € %.6f EUR\n" "1" $MY_BTC_EUR
else
	exit_with_failure "Can not find Eurozone Euro (€) exchange rate!"
fi

# 1 BTC to USD
if [[ $MY_BTC_USD =~ ^[0-9\.]+$ ]]; then
	printf "%.0f BTC  ⤮   $ %.6f USD\n" "1" $MY_BTC_USD
else
	exit_with_failure "Can not find US Dollar ($) exchange rate!"
fi

# n BTC to EUR and USD
if [[ $MY_BTC =~ ^[0-9\.]+$ ]]; then
	MY_BTC_TO_EUR=$(echo "$MY_BTC * $MY_BTC_EUR" | bc -l)
	MY_BTC_TO_USD=$(echo "$MY_BTC * $MY_BTC_USD" | bc -l)
	echo "---------------------------------------------"
	printf "%.6f BTC  ⤮   € %.6f EUR\n" $MY_BTC $MY_BTC_TO_EUR
	printf "%.6f BTC  ⤮   € %.6f USD\n" $MY_BTC $MY_BTC_TO_USD
fi

# n EUR to BTC
if [[ $MY_EUR =~ ^[0-9\.]+$ ]]; then
	MY_EUR_TO_BTC=$(echo "1 / $MY_BTC_EUR * $MY_EUR" | bc -l)
	MY_EUR_TO_MBTC=$(echo "$MY_EUR_TO_BTC * 1000" | bc -l)
	echo "---------------------------------------------"
	printf "%.6f EUR  ⤮   ฿ %.6f BTC\n"  $MY_EUR $MY_EUR_TO_BTC
	printf "%.6f EUR  ⤮   ฿ %.6f mBTC\n" $MY_EUR $MY_EUR_TO_MBTC
fi

# n USD to BTC
if [[ $MY_USD =~ ^[0-9\.]+$ ]]; then
	MY_USD_TO_BTC=$(echo "1 / $MY_BTC_USD * $MY_USD" | bc -l)
	MY_USD_TO_MBTC=$(echo "$MY_USD_TO_BTC * 1000" | bc -l)
	echo "---------------------------------------------"
	printf "%.6f USD  ⤮   ฿ %.6f BTC\n"  $MY_USD $MY_USD_TO_BTC
	printf "%.6f USD  ⤮   ฿ %.6f mBTC\n" $MY_USD $MY_USD_TO_MBTC
fi

echo