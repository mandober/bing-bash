#!/bin/bash bingmsg
#==================================================================
#:Name: in_array
#:Path: $BING/func/arrays/in_array
#:Type: function
#:Deps: bb_err,
#:Rev:  3-Mar-2016
#------------------------------------------------------------------
#:Author:
#:		bing-bash by mandober <zgag@yahoo.com>
#:		https://github.com/mandober/bing-bash
#:		za Ǆ - Use freely at own's risk
#------------------------------------------------------------------
#:Description:
#:		Checks if a value exists in an array. The value can be a
#:		scalar (variable or variable name) or array.
#:Example:
#:		in_array var ARRAY
#:		in_array "$var" ARRAY
#:		in_array "abc" haystack
#:		in_array array ARRAY
#------------------------------------------------------------------
#:Usage:
#:		in_array <var> NEEDLE <array> HAYSTACK
#:Options:
#:		no options
#:Parameters:
#:		<variable> NEEDLE - scalar or array
#:		<array> HAYSTACK - an array
#:Returns:
#:		void
#:Return code:
#:		0 value found
#:		1 value not found
#==================================================================

in_array() {

### ABOUT
local bbapp="${FUNCNAME[0]}"
local bbnfo="[bing-bash] $bbapp v.0.3"
local usage="USAGE: $bbapp NEEDLE HAYSTACK"

### CHECK
[[ $# -eq 0 ]] && { bb_err 51; printf "${usage}\n" >&2; return 51; }
[[ $# -gt 2 ]] && { bb_err 52; printf "${usage}\n" >&2; return 52; }

### HUV
[[ $1 =~ ^(-u|--usage)$ ]] && { printf "${usage}\n"; return 0; }
[[ $1 =~ ^(-v|--version)$ ]] && { printf "${bbnfo}\n"; return 0; }
[[ $1 =~ ^(-h|--help)$ ]] && {
	cat <<-EOFF
	$bbnfo
	  Checks if a value exists in an array.
	$usage
	  Searches array HAYSTACK for a NEEDLE, which can be a string,
	  a variable, name of variable or an array.
	OPTIONS:
	   -h, --help        Show program help.
	   -u, --usage       Show program usage.
	   -v, --version     Show program version.
	EXAMPLES:
	  in_array "abc" haystack    # haystack=(abc def ghi jkl)
	  in_array \$var haystack     # var="abc"
	  in_array var haystack
	  in_array needle haystack   # needle=(def ghi)
	EOFF
	return 0
}

### SET
 shopt -s extglob 		# Enable extended regular expressions
 shopt -s extquote		# Enables $'' and $"" quoting
 shopt -u nocasematch 	# regexp case-sensitivity
 set -o noglob			# Disable globbing. Enable it upon return:
 trap "set +o noglob" RETURN ERR SIGHUP SIGINT SIGTERM


### PARAMS 

## HAYSTACK
local bbArrayName="$2"
local -n bbArrayRef="$2"

## NEEDLE
local bbFlag
local bbNeedle


if bbFlag=$(declare -p "$1" 2>/dev/null); then
	bbFlag=( $bbFlag )
	bbFlag="${bbFlag[1]#?}"
	if [[ "$bbFlag" =~ ^[aA][[:alpha:]]*$ ]]; then
		## Array in array
		# needle=(b c) haystack=(a b c d)
		# in_array needle haystack
		bbNeedle="$1"
		local -n bbNeedleRef="$1"

		local bbBingo=0
		local bbNeedleNum="${#bbNeedleRef[@]}"
		local h n 
		
		for n in "${bbNeedleRef[@]}"; do
			for h in "${bbArrayRef[@]}"; do
				[[ "$h" == "$n" ]] && (( bbBingo++ ))
			done
		done

		if [[ "$bbBingo" -ge "$bbNeedleNum" ]]; then
			return 0
		else
			return 1
		fi
	else
		## in_array var ARRAY
		bbNeedle="${!1}"
	fi
else
	## in_array "$var" ARRAY
	bbNeedle="$1"
fi

echo "$bbNeedle: bbNeedle"

local n
for n in "${bbArrayRef[@]}"; do
	[[ "$n" == "$bbNeedle" ]] && return 0
done
return 1

}
