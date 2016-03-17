#!/bin/bash bingmsg
#==================================================================
#: FILE: array_clone.bash
#: PATH: $BING_FUNC/array_clone.bash
#: TYPE: function
#:
#: AUTHOR:
#:      bing-bash by mandober <zgag@yahoo.com>
#:      https://github.com/mandober/bing-bash
#:      za Ǆ - Use freely at owns risk
#:      10-Mar-2016 (last revision)
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: NAME: 
#:      bb_array_clone
#:
#: BRIEF: 
#:      Clone an array. 
#:
#: DESCRIPTION:
#:      Pass array's name, ARRAY, to clone it as array named NAME,
#:      which must be a valid identifier. If NAME is not given, it 
#:      defaults to BING_CLONED. Array is cloned without additional
#:      attributes (if any) but indices/keys are preserved. An
#:      indexed array has -a attribute and associative array has -A
#:      attribute; these attributes are of course preserved, but
#:      an array can have other attributes. For example -i which would
#:      make its values integers, or -l which would make its values
#:      lowercasing. These additional attributes are not preserved.
#:
#: DEPENDENCIES:
#:      bb_err, bb_is
#:
#: EXAMPLE:
#:      bb_array_clone array1 newArray
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: SYNOPSIS:
#:      bb_array_clone ARRAY [NAME]
#:
#: OPTIONS: 
#:      
#:
#: PARAMETERS:
#:    * ARRAY <array>
#:      Name of the array to be cloned (without $).
#:    * NAME <identifier>
#:      Optional: user chosen name for the new array.
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: ENVIRONMENT:
#:    * NAME <array>
#:      New array named NAME is created in the environment.
#:
#: STDOUT:
#:      
#:
#: STDERR:
#:      Error messages
#:
#: RETURN CODE:
#:      0      success
#:      non-0  see err file for non-zero errors
#==================================================================

bb_array_clone() {

### ABOUT
local bbapp="${FUNCNAME[0]}"
local bbnfo="[bing-bash] $bbapp v.0.18"
local usage="USAGE: $bbapp ARRAY [NAME]"

### CHECK
[[ $# -eq 0 ]] && { bb_err 51; echo "$usage" >&2; return 51; }
[[ $# -gt 3 ]] && { bb_err 52; echo "$usage" >&2; return 52; }

### HELP
[[ $1 =~ ^(--usage)$ ]] && { echo "$usage"; return 0; }
[[ $1 =~ ^(--version)$ ]] && { echo "$bbnfo"; return 0; }
[[ $1 =~ ^(--help)$ ]] && {
	cat <<-EOFF
	$bbnfo
	  Clone an array.
	$usage
	  Pass array's name, ARRAY, to clone it as NAME, which must
	  be a valid identifier, but if not given, it defaults to
	  BING_CLONED.
	OPTIONS:
	   -h, --help        Show program help.
	   -u, --usage       Show program usage.
	   -v, --version     Show program version.
	EOFF
	return 0
}

### SET
 shopt -s extglob 		# Enable extended regular expressions
 shopt -s extquote		# Enables $'' and $"" quoting
 shopt -u nocasematch 	# regexp case-sensitivity
 set -o noglob			# Disable globbing. Enable it upon return:
 trap "set +o noglob" RETURN ERR SIGHUP SIGINT SIGTERM


#
## PARAMS
local bbArray bbNewArray bbDeclare bbTempArray bbFlag bbPattern

#1 ARRAY
bbArray="$1"
# check if it is indeed an array
! bb_is --array "$bbArray" && { bb_err 63; return 63; }

#2 NAME
bbNewArray="${2:-BING_CLONED}"
if [[ "$bbNewArray" != "BING_CLONED" ]]; then
	# check if user supplied name is a valid identifier
	! bb_is --id "$bbNewArray" && { bb_err 61; return 61; }
fi


#
## PROCESS

# if array is set, get his definition with `declare -p ARRAY'
if ! bbDeclare="$(declare -p "$bbArray" 2>/dev/null)"; then
	return 60
fi
# bbDeclare now contains array's definition, for example:
# `declare -p BASH_VERSINFO' outputs the statement:
# declare -ar BASH_VERSINFO='([0]="4" [1]="3" [2]="42" [3]="4")'

# Next, this statement is exploded, by space, into temporary array
# which will contain [0]="declare" [1]="-ar" [2]=BASH_VERSINFO=...
bbTempArray=( $bbDeclare )

# To identify the type of array, examine element1 (without the leading
# dash). If it is indexed (has `a' attribute ), a new global indexed
# array is declared (and same for associative array).
bbFlag="${bbTempArray[1]/#?}"
[[ "$bbFlag" =~ ^a[[:alpha:]]*$ ]] && bbPattern="declare -ag $bbNewArray="
[[ "$bbFlag" =~ ^A[[:alpha:]]*$ ]] && bbPattern="declare -Ag $bbNewArray="

# Finally, the original statement `bbDeclare' is searched for
# `declare -ar BASH_VERSINFO=' and this part is replaced with
# `declare -ag NAME=' and then the statement is evaluated.
eval "${bbDeclare/#declare*$bbArray=/$bbPattern}"

return 0

}
