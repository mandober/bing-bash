#!/bin/bash bingmsg
#=========================================================================
#: FILE: array_clone.bash
#: PATH: $BING_FUNC/array_clone.bash
#: TYPE: function
#:   NS: shell:bash:mandober:bing-bash:function:bb_array_clone
#:  CAT: arrays
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: AUTHOR:
#:      bing-bash by Ivan Ilic <ivanilic1975@gmail.com>
#:      https://github.com/mandober/bing-bash
#:      za Ǆ - Use freely at owns risk
#:      8-Apr-2016 (last revision)
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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
#:      attributes (if any) preserved.
#:
#: DEPENDENCIES:
#:      none
#:
#: EXAMPLE:
#:      bb_array_clone array1 newArray
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: SYNOPSIS:
#:      bb_array_clone ARRAY [NAME]
#:
#: OPTIONS: 
#:      none
#:
#: PARAMETERS:
#:
#:      ARRAY <array>
#:      Name of the array to be cloned (passed without $, us usual).
#:
#:      NAME <identifier>
#:      Optional: user chosen name for the new array.
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: ENVIRONMENT:
#:      NAME <array identifier>
#:      New array named NAME is created in the environment.
#:
#: STDOUT:
#:      Help, usage, version (if explicitly requested).
#:
#: STDERR:
#:      Error messages.
#:
#: RETURN CODE:
#:      0  great success
#:      1  miserable failure
#:      3  Parameter is not set
#:      4  Parameter is not an array
#:      6  Invalid identifier
#:      9  Parameter error
#=========================================================================
bb_array_clone() {

#                                                                    ABOUT
#-------------------------------------------------------------------------
 local -r bbapp="${FUNCNAME[0]}"
 local -r bbnfo="[bing-bash] $bbapp v.0.21"
 local -r usage="USAGE: $bbapp ARRAY [NAME]"

#                                                                 PRECHECK
#-------------------------------------------------------------------------
 if [[ $# -eq 0 ]]; then
   printf "\e[2m%s: %s\e[0m\n" "$bbapp" "Parameter error" >&2
   printf "%s\n" "$usage" >&2
   return 2
 fi

#                                                                     HELP
#-------------------------------------------------------------------------
 [[ $1 =~ ^(-u|--usage)$ ]] && { printf "%s\n" "$usage"; return 0; }
 [[ $1 =~ ^(-v|--version)$ ]] && { printf "%s\n" "$bbnfo"; return 0; }
 [[ $1 =~ ^(-h|--help)$ ]] && {
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

#                                                                      SET
#-------------------------------------------------------------------------
 shopt -s extglob extquote; shopt -u nocasematch; set -o noglob
 trap "set +o noglob" RETURN ERR SIGHUP SIGINT SIGTERM


#                                                                   PARAMS
#=========================================================================
local bbFlag bbDeclare bbNewArray bbPattern

# check if var is set
if ! bbDeclare="$(declare -p "$1" 2>/dev/null)"; then
  printf "\e[2m%s: %s\e[0m\n" "$bbapp" "Parameter $1 is not set" >&2
  return 3
fi

# check if var is array
bbFlag=( $bbDeclare )
if [[ ! "${bbFlag[1]}" =~ ^-[aA] ]]; then
  printf "\e[2m%s: %s\e[0m\n" "$bbapp" "Parameter $1 is not an array" >&2
  return 4
fi

# name for new array
# unset that name (in case that name is an existing array)
unset $bbNewArray
bbNewArray="${2:-BING_CLONED}"
# check if user supplied name is a valid identifier
if [[ "$bbNewArray" != "BING_CLONED" ]]; then
  if [[ ! "$bbNewArray" =~ ^[[:alpha:]_][[:alnum:]_]*$ ]]; then
    printf "\e[2m%s: %s\e[0m\n" "$bbapp" "Invalid identifier" >&2
    return 6
  fi
fi

#                                                                  PROCESS
#=========================================================================
# bbDeclare contains array's definition, for example:
#   declare -ar BASH_VERSINFO='([0]="4" [1]="3" [2]="42" [3]="4")'
# Next, this statement is exploded, by space, into array bbFlag
#   bbFlag=( $bbDeclare )    which will contain
#   [0]="declare" [1]="-ar" [2]=BASH_VERSINFO=...
# To identify the type of array, examine element 1.
# If it is indexed (has `a' attribute ), a new global indexed
# array is declared (and same for associative array).
#   [[ "$bbFlag" =~ ^a[[:alpha:]]*$ ]] && bbPattern="declare -ag $bbNewArray="
#   [[ "$bbFlag" =~ ^A[[:alpha:]]*$ ]] && bbPattern="declare -Ag $bbNewArray="
# Finally, the original statement `bbDeclare' is searched for
#   declare -xx BASH_VERSINFO=     and this part is replaced with
#   declare -ag NAME=              then the statement is evaluated.

# type of array
[[ "${bbFlag[1]}" =~ ^-a ]] && bbPattern="declare -ag $bbNewArray="
[[ "${bbFlag[1]}" =~ ^-A ]] && bbPattern="declare -Ag $bbNewArray="
eval "${bbDeclare/#declare*$1=/$bbPattern}"
return 0

} # $BING_FUNC/array_clone.bash
