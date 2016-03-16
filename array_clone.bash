#!/bin/bash bingmsg
#==================================================================
#: FILE: array_clone.bash
#: PATH: $BING_FUNC/array_clone.bash
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
#:      bb_array_clone
#:
#: BRIEF: 
#:      Clone an array. 
#:
#: DESCRIPTION:
#:      Pass array's name, ARRAY, to clone it as array named NAME,
#:      which must be a valid identifier. If NAME is not given, it 
#:      defaults to BING_CLONED. If -p option is given the resulting
#:      array is reindexed, if it was a sparse indexed array.
#:      Associative arrays are not touched.
#:
#: DEPENDENCIES:
#:      bb_err, bb_is, bb_get
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
local usage="USAGE: $bbapp ARRAY [-p] [NAME]"

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
	  BING_CLONED. If -p option is given the resulting array
	  is reindexed, if it was a sparse indexed array (and
	  associative arrays are not touched).
	OPTIONS:
	   -p, --pack        Pack array.
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


### PARAMS
local bbArray bbNewArray bbDeclare bbTempArray bbFlag bbPattern

#1 ARRAY
bbArray="$1"
! bb_is --array "$bbArray" && { bb_err 63; return 63; }

#2 NAME
bbNewArray="${2:-BING_CLONED}"
if [[ "$bbNewArray" != "BING_CLONED" ]]; then
	! bb_is --id "$bbNewArray" && { bb_err 61; return 61; }
fi

### PROCESS
if ! bbDeclare="$(declare -p "$bbArray" 2>/dev/null)"; then
	return 60
fi

echo "${bbDeclare//$bbArray=/$bbNewArray=}"
return 0

# Array is cloned by replacing original array name with user defined one
# and then evaluating such declaration. Namely, `declare -p ARRAY' outputs:
# declare -a ARRAY='(...)' and in order to clone it, ARRAY is replaced with
# NAME, an user supplied name, so it becomes declare -a NAME='(...)' and
# then this statement is evaluated.
bbTempArray=( $bbDeclare )
bbFlag="${bbTempArray[1]/#?}"
[[ "$bbFlag" =~ ^a[[:alpha:]]*$ ]] && bbPattern="declare -ag $bbNewArray="
[[ "$bbFlag" =~ ^A[[:alpha:]]*$ ]] && bbPattern="declare -Ag $bbNewArray="
eval "${bbDeclare/#declare*$bbArray=/$bbPattern}"
return 0





}




## SWITCH - pack array
# [[ "$2" =~ ^(-p|--pack)$ ]] && { 
# 	local pack=1
# 	shift
# }


#	====================== CLONE AND PACK ARRAY ========================
# if [[ "$pack" == 1 ]]; then
# 	local j=0
# 	for bbTemp in "${!bbArrayRef[@]}"; do
# 		BING_ARRAY[$j]="${bbArrayRef[$bbTemp]}"
# 		(( j++ ))
# 	done

# 	eval "declare -ag $bbNewArray=( \"\${$BING_ARRAY[@]}\" )"
# 	return 0
# fi


#	=============== CLONE ARRAY AS IS (WITHOUT ATTRIBUTES) =============
#					attributes like -r for readonly, etc
