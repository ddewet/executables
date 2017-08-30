#!/usr/bin/env bash
#
# Author:
#   Newton (@chrisohpedia)
#
# Description:
#   Get stock quotes
#
# Dependencies:
#   None
#
# Configuration:
#   @param   stock_ticker    required
#
# Usage:
#   `stock aapl`

readonly PROGNAME=$(basename "$0")
readonly PROGDIR=$(readlink "$(dirname "$0")")
readonly ARGS="$*"

_usage() {
	printf "%s: usage: %s [-h|--help] [-c]  %sstock ticker,[stock ticker]%s" "$PROGNAME" "$PROGNAME" "$(tput smul)" "$(tput rmul)"
}

is_empty() {
	local var=$1
	[[ -z $var ]]
}

is_not_empty() {
	local var=$1
	[[ -n $var ]]
}

_is_not_valid_option() {
	local option=$1
	printf "bash: %s: %s: invalid option\n" "$PROGNAME" "$option"
}

_get_stock() {
	local stock=$1;

	if [[ -n "${changed}" ]]; then
		stock="$(echo '-c aapl,rubi' | sed -E 's/-{1,2}c //')"
	fi
	local url="http://download.finance.yahoo.com/d/quotes.csv?s=$stock&f=l1$changed"
	curl -s "${url}"
}

_cmdline() {
	# got this idea from here:
	# http://kirk.webfinish.com/2009/10/bash-shell-script-to-use-getopts-with-gnu-style-long-positional-parameters/
	local arg=
	for arg
	do
		local delim=""
		case "$arg" in
			#translate --gnu-long-options to -g (short options)
			--changed)        args="${args}-c ";;
			--help)           args="${args}-h ";;
			#pass through anything else
			*) [[ "${arg:0:1}" == "-" ]] || delim="\""
				args="${args}${delim}${arg}${delim} ";;
		esac
	done

	#Reset the positional parameters to the short options
	eval set -- "${args}"

	while getopts ":ch" OPTION
	do
		case $OPTION in
			c)
				changed="c1"
				;;
			h)
				_usage
				exit 0
				;;
			\?)
				_is_not_valid_option "-$OPTARG"
				_usage
				exit 1
				;;
		esac
	done

	return 0
}

main() {
	_cmdline "${ARGS}"

	is_empty "${ARGS}" \
		&& _usage

	is_not_empty "${ARGS}" \
		&& _get_stock "${ARGS}"
}

main
