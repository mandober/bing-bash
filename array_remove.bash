#!/bin/bash bingmsg
#==================================================================
#: FILE: array_remove
#: PATH: $BING/func/array_remove
#: TYPE: function
#:
#: AUTHOR:
#:      bing-bash by mandober <zgag@yahoo.com>
#:      https://github.com/mandober/bing-bash
#:      za Ǆ - Use freely at owns risk
#:      7-Mar-2016 (last revision)
#:
#: NAME: 
#:      array_remove
#:
#: BRIEF: 
#:      Remove array element(s).
#:
#: DESCRIPTION:
#:      
#:      
#:      
#:
#: DEPENDENCIES:
#:      bb_err
#:
#: EXAMPLE:
#:      array_shift ARRAY VAR
#:
#: SYNOPSIS:
#:      array_merge ARRAY_A ARRAY_B ARRAY
#:
#: OPTIONS: 
#:      
#:
#: PARAMETERS:
#:      <array> ARRAY_A - an array (indexed or associative)
#:
#: STDOUT:
#:      the shifted value (0), or null if array is empty or is not an array (1).
#:
#: STDERR:
#:      Error message
#:
#: RETURN CODE:
#:		0 - great success
#:	    not 0 - see err file
#==================================================================

bb_array_remove() {
	
local bbapp="${FUNCNAME[0]}"
local bbnfo="[bing-bash] $bbapp v.0.15"
local usage="USAGE: $bbapp ARRAY n[,n,...] [NAME]"

[[ $# -eq 0 ]] && { bb_err 51; printf "${usage}\n" 1>&2; return 51; }
[[ $# -gt 3 ]] && { bb_err 52; printf "${usage}\n" 1>&2; return 52; }

[[ $1 =~ ^(-u|--usage)$ ]] && { printf "${usage}\n"; return 0; }
[[ $1 =~ ^(-v|--version)$ ]] && { printf "${bbnfo}\n"; return 0; }
[[ $1 =~ ^(-h|--help)$ ]] && {
	cat <<-EOFF
	$bbnfo
	  Remove array element(s).
	$usage
	  Remove element with key N from array, where N is a single
	  array key, a comma-separated list of array keys or a range
	  of keys; or any of this combined (e.g. 1,2,5,8-16,18,20-25).
	  Ranges are inclusive. Besides being an index in indexed array,
	  N can be a key in associative array. Optionally, if a NAME for
	  a new array is provided (as the 3rd parametar) than the result 
	  will be stored in an array by that name, leaving the original
	  array intact.
	OPTIONS:
	  -h, --help        Show program help.
	  -u, --usage       Show program usage.
	  -v, --version     Show program version.
	EXAMPLES:
	   $bbapp varray 0
	   $bbapp varray 1,2,5
	   $bbapp varray 0,3,5-10,12,15-20
	   $bbapp varray keyA
	   $bbapp varray keyA,keyB,keyF
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

#1 original array
! bbis --array "$1" && { bb_err 63; return 63; }
local bbArrayName="$1"
local -n bbArrayRef="$1"

#2 elements to remove
local bbToRemove="$2"
if bbis --indexed "$bbArrayName"; then 
	if bbis --range "$2"; then
		bbToRemove="$(bbseq "$2")"
	fi
fi

#3 new array: original or new name
local bbNewArrayName="${3:-$bbArrayName}"
! bbis --id "$bbNewArrayName" && { bb_err 63; return 63; }


### PROCESS
bb_explode bbToRemove -d ',' bbRemoveArray

local bbKey
for bbKey in "${bbRemoveArray[@]}"; do
	unset -v "bbArrayRef[$bbKey]"
done



}
