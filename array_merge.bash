#!/bin/bash bingmsg
#==================================================================
#: FILE: array_merge
#: PATH: $BING/func/arrays/array_merge
#: TYPE: function
#:
#: AUTHOR:
#:      bing-bash by mandober <zgag@yahoo.com>
#:      https://github.com/mandober/bing-bash
#:      za Ǆ - Use freely at owns risk
#:      7-Mar-2016 (last revision)
#:
#: NAME: 
#:      array_merge
#:
#: BRIEF: 
#:      Merge arrays.
#:
#: DESCRIPTION:
#:      Merge two arrays into third array NAME. 
#:      If NAME is not given, the resulting array is BING_ARRAY.
#:      
#:
#: DEPENDENCIES:
#:      bb_err
#:
#: EXAMPLE:
#:      array_merge array1 array2 arrayAll
#:
#: SYNOPSIS:
#:      array_merge ARRAY_A ARRAY_B ARRAY
#:
#: OPTIONS: 
#:      (no options)
#:
#: PARAMETERS:
#:      <array> ARRAY_A - an array (indexed or associative)
#:
#: STDOUT:
#:      
#:
#: STDERR:
#:      Error message
#:
#: RETURN CODE:
#:		0  (no errors)
#:	    55 Positional parameters error
#==================================================================

array_merge() {

### ABOUT
local bbapp="${FUNCNAME[0]}"
local bbnfo="[bing-bash] $bbapp v.0.2"
local usage="USAGE: $bbapp ARRAY1 ARRAY2 [NAME]"

### DEPENDENCIES

### PRECHECK
[[ $# -eq 0 ]] && { bb_err 51; printf "${usage}\n" 1>&2; return 51; }
[[ $# -ne 3 ]] && { bb_err 52; printf "${usage}\n" 1>&2; return 52; }

### HELP
[[ $1 =~ ^(-u|--usage)$ ]] && { printf "${usage}\n"; return 0; }
[[ $1 =~ ^(-v|--version)$ ]] && { printf "${bbnfo}\n"; return 0; }
[[ $1 =~ ^(-h|--help)$ ]] && {
	cat <<-EOFF
	$bbnfo
	  Merge two arrays into third.
	$usage

	EOFF
	return 0
}


### PARAMS

## check
if ! bbis --array "$1" && ! bbis --array "$2"; then return 63; fi
# if ! bbis --array "$1"; then return 63; fi
# if ! bbis --array "$2"; then return 63; fi

## assign
local bbArray1="$1"
local -n bbArray1Ref="$1"
local bbType1=$(array --type "$1")

local bbArray2="$2"
local -n bbArray2Ref="$2"
local bbType2=$(array --type "$2")

unset BING_ARRAY
local bbArrayName="${3:-BING_ARRAY}"


if [[ "$bbType1" = "indexed" ]] && [[ "$bbType2" = "indexed" ]]; then
	BING_ARRAY=( "${bbArray1Ref[@]}" "${bbArray2Ref[@]}" )
	array_sort -u BING_ARRAY
else
	local -A BING_ARRAY
fi


clone BING_ARRAY "$bbArrayName"
}
