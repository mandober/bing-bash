#!/bin/bash bingmsg
#==================================================================
#: FILE: array_sort.bash
#: PATH: $BING_FUNC/array_sort.bash
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
#:      bb_array_sort
#:
#: BRIEF: 
#:      Sort an array. 
#:
#: DESCRIPTION:
#:      Sorting array's values with `sort' utility.
#:      It will just pass its SWITCH to `sort' utility.
#:
#: DEPENDENCIES:
#:      bb_err, bb_is, bb_get, bb_array_clone
#:
#: EXAMPLE:
#:      bb_array_sort varray     # sort array ascending
#:      bb_array_sort -r varray  # sort array descending
#:      bb_array_sort -u varray  # remove duplicated elements
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: SYNOPSIS:
#:      bb_array_sort ARRAY [NAME]
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

bb_array_sort() {
local bbapp="${FUNCNAME[0]}"
local bbnfo="[bing-bash] $bbapp v.0.11"
local usage="USAGE: $bbapp [-rMhnRVu] ARRAY [NAME]"

[[ $# -eq 0 ]] && { bb_err 51; printf "${usage}\n" >&2 && return 51; }
[[ $# -gt 3 ]] && { bb_err 52; printf "${usage}\n" >&2 && return 52; }

[[ $1 =~ ^(--usage)$ ]] && { printf "${usage}\n" && return 0; }
[[ $1 =~ ^(--version)$ ]] && { printf "${bbnfo}\n" && return 0; }
[[ $1 =~ ^(--help)$ ]] && {
	cat <<-EOFF
	$bbnfo
	  Sort ARRAY using the options below. If NAME is provided, put
	  sorted array into NAME and leave original array intact.
	$usage
	  OPTIONS:
       (no switch)                sort ascending
       -r, --reverse              sort descending
       -M, --month-sort           sort months (jan feb march)
       -h, --human-numeric-sort   sort units (5B 5b 5KB 3GB 5K 2G)
       -n, --numeric-sort         sort numerically
       -R, --random-sort          randomize values
       -V, --version-sort         sort versions (0.1 0.x 0.11)
       -u, --unique               keep only unique values
	       --help                 show program help
	       --usage                show program usage
	       --version              show program version
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
## OPT
local bbOpt
if [[ "$1" =~ ^-[[:alpha:]]$ ]]; then
	bbOpt="$1"
	shift
fi

## ARRAY
local bbArrayName="$1"
local -n bbArrayRef="$1"
shift

## NAME
local bbName="${1:-$bbArrayName}"

# echo "bbOpt: $bbOpt"
# echo "bbArrayName: $bbArrayName"
# echo "bbName: $bbName"


### ACTION
local bbTemp
bbTemp=$(printf "%s\n" "${bbArrayRef[@]}" | sort $bbOpt)
mapfile -t "$bbName" <<< "$bbTemp"


# The LC_ALL affects sort order:
#     LC_ALL=C     - sort capital before lowercased letters (ABCabc)
#     LC_ALL=en_US - sort letters in mixed mode (aAbBcC)
#     LC_COLLATE=C
# In fact, LC_COLLATE affects sort order, but LC_ALL overrides it
}
