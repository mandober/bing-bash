#!/bin/bash bingmsg
#==================================================================
#: FILE: array_convert.bash
#: PATH: $BING_FUNC/array_convert.bash
#: TYPE: function
#:
#: AUTHOR:
#:      bing-bash by mandober <zgag@yahoo.com>
#:      https://github.com/mandober/bing-bash
#:      za Ǆ - Use freely at own's risk
#:      10-Mar-2016 (last revision)
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: NAME: 
#:      array_convert
#:
#: BRIEF: 
#:      Convert indexed to associative array or vice versa. 
#:
#: DESCRIPTION:
#:      An indexed array is converted to associative array with its
#:      indecis becoming the keys. If parameter is an associative 
#:      array it is converted to indexed array, loosing its keys.
#:      If the second parameter, NAME, is provided, the resulting array
#:      is stored in NAME, while the original array remains unchanged.
#:
#: DEPENDENCIES:
#:      bb_err, bb_is, bb_get, bb_array_clone
#:
#: EXAMPLE:
#:      array_convert varray
#:      #  `varray' is converted into assoc. array
#:      array_convert BASH_VERSINFO bashVersion
#:      #  An associative array `bashVersion' is created 
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: SYNOPSIS:
#:      array_convert ARRAY [NAME]
#:
#: OPTIONS: 
#:      -
#:
#: PARAMETERS:
#:    * ARRAY <array>
#:      Name of the array to be converted (without $).
#:    * NAME <identifier>
#:      Optional: user chosen name for the converted array.
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: ENVIRONMENT:
#:    * NAME <array>
#:      Optionally, if NAME is provided, the resulting array is 
#:      created by that name.
#:
#: STDOUT:
#:      -
#:
#: STDERR:
#:      Error messages
#:
#: RETURN CODE:
#:		0  success
#:	    see err file for non-zero errors
#==================================================================

bb_array_convert() {

# ABOUT
local bbapp="${FUNCNAME[0]}"
local bbnfo="[bing-bash] $bbapp v.0.8"
local usage="USAGE: $bbapp ARRAY [NAME]"

# DEPENDENCIES
bb_load bb_err bb_is bb_get bb_array_clone

# PRECHECK
[[ $# -eq 0 ]] && { bb_err 51; printf "${usage}\n" >&2; return 51; }
[[ $# -gt 2 ]] && { bb_err 52; printf "${usage}\n" >&2; return 52; }

# HELP
[[ $1 =~ ^(-u|--usage)$ ]] && { printf "${usage}\n"; return 0; }
[[ $1 =~ ^(-v|--version)$ ]] && { printf "${bbnfo}\n"; return 0; }
[[ $1 =~ ^(-h|--help)$ ]] && {
	cat <<-EOFF
	$bbnfo
	  Convert indexed to associative array or vice versa.
	$usage
	  An indexed array is converted to associative array with its
	  indecis becoming the keys. If parameter is an associative 
	  array it is converted to indexed array, loosing its keys.
	  If the second parameter, NAME, is provided, the resulting array
	  is stored in NAME, while the original array remains unchanged.
	OPTIONS:
	   -h, --help        Show program help.
	   -u, --usage       Show program usage.
	   -v, --version     Show program version.
	EOFF
	return 0
}


### PARAMS
local bbArrayName bbNewArray bbKey bbType

#$1 ARRAY
! bb_is --array "$1" && { bb_err 63; printf "$usage\n" >&2; return 63; }
bbArrayName="$1"
local -n bbArrayRef="$1"

#$2 NAME
bbNewArray="${2:-$bbArrayName}"
! bb_is --id "$bbNewArray" && { bb_err 61; printf "$usage\n" >&2; return 61; }


### PROCESS

# get array's type
bbType="$(bb_get --type "$bbArrayName")"

# convert indexed to associative
if [[ "$bbType" = "indexed" ]]; then
	local -A bbNewArray=()
	for bbKey in "${!bbArrayRef[@]}"; do
		bbNewArray[$bbKey]="${bbArrayRef[$bbKey]}"
	done
fi

# convert associative to indexed
if [[ "$bbType" = "associative" ]]; then
	local -a bbNewArray=()
	for bbKey in "${!bbArrayRef[@]}"; do
		bbNewArray+=("${bbArrayRef[$bbKey]}")
	done
fi

unset "$bbArrayName"
bb_array_clone bbNewArray "$bbArrayName"
return 0
}
