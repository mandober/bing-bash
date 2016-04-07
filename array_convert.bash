#!/bin/bash bingmsg
#=========================================================================
#: FILE: array_convert.bash
#: PATH: $BING_FUNC/array_convert.bash
#: TYPE: function
#:   NS: shell:bash:mandober:bing-bash:function:bb_array_convert
#:  CAT: arrays
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: AUTHOR:
#:      bing-bash by Ivan Ilic <ivanilic1975@gmail.com>
#:      https://github.com/mandober/bing-bash
#:      za Ǆ - Use freely at owns risk
#:      7-Apr-2016 (last revision)
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: NAME: 
#:      bb_array_convert
#:
#: BRIEF: 
#:      Convert indexed to associative array or vice versa. 
#:
#: DESCRIPTION:
#:      An indexed array is converted to associative array with its
#:      indices becoming the keys. If parameter is an associative 
#:      array it is converted to indexed array, loosing its keys.
#:      If the second parameter, NAME, is provided, the resulting array
#:      is stored in NAME, while the original array remains unchanged.
#:
#: DEPENDENCIES:
#:      none
#:
#: EXAMPLE:
#:      array_convert BASH_VERSINFO bashv
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: SYNOPSIS:
#:      array_convert ARRAY [NAME]
#:
#: OPTIONS: 
#:      none
#:
#: PARAMETERS:
#:
#:      ARRAY <array>
#:      Name of the array to be converted (without $).
#:
#:      NAME <identifier>
#:      User supplied name for converted array.
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: ENVIRONMENT:
#:      NAME <array>
#:      If name for resulting array is supplied, new array by that 
#:      name is created in the current environment.
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
#:      2  Parameter error
#:      3  Parameter is not set
#:      4  Parameter is not an array
#:      6  Invalid identifier
#=========================================================================
bb_array_convert() {

#                                                                    ABOUT
#=========================================================================
 local -r bbapp="${FUNCNAME[0]}"
 local -r bbnfo="[bing-bash] $bbapp v.0.11"
 local -r usage="USAGE: $bbapp ARRAY [NAME]"

#                                                                 PRECHECK
#=========================================================================
 if [[ $# -eq 0 || $# -gt 2 ]]; then
    printf "\e[2m%s: %s\e[0m\n" "$bbapp" "Parameter error" >&2
    printf "%s\n" "$usage" >&2
    return 2
 fi

#                                                                     HELP
#=========================================================================
 [[ $1 =~ ^(-u|--usage)$ ]] && { printf "%s\n" "$usage"; return 0; }
 [[ $1 =~ ^(-v|--version)$ ]] && { printf "%s\n" "$bbnfo"; return 0; }
 [[ $1 =~ ^(-h|--help)$ ]] && {
	cat <<-EOFF
	$bbnfo
	  Convert indexed to associative array or vice versa.
	$usage
	  Indexed array is converted to associative array with its
	  indices becoming the keys. If parameter is an associative
	  array it is converted to indexed array, loosing its keys.
	  If the second parameter NAME is provided the resulting array
	  variable will have that name and the new array variable by
	  that name is created in the current environment with original
	  array remaining unchanged.
	OPTIONS:
	   -h, --help        Show program help.
	   -u, --usage       Show program usage.
	   -v, --version     Show program version.
	EOFF
	return 0
 }

#                                                                      SET
#=========================================================================
 shopt -s extglob extquote; shopt -u nocasematch; set -o noglob
 trap "set +o noglob" RETURN ERR SIGHUP SIGINT SIGTERM



#                                                                   CHECKS
#=========================================================================
local bbDeclare bbFlag

# check if param is set var
if ! bbDeclare="$(declare -p "$1" 2>/dev/null)"; then
  printf "\e[2m%s: %s\e[0m\n" "$bbapp" "Parameter $1 is not set" >&2
  return 3
fi

# check if array
bbFlag=( $bbDeclare )
if [[ ! "${bbFlag[1]}" =~ ^-[aA] ]]; then
  printf "\e[2m%s: %s\e[0m\n" "$bbapp" "Parameter $1 is not an array" >&2
  return 4
fi

#                                                               ARRAY NAME
#=========================================================================
local bbArrayName
local -n bbArrayRef="$1"
bbArrayName="$1"

# if supplied, name for new array, otherwise convert original
bbNewArray="${2:-$bbArrayName}"
# check that new name is a valid identifier
if [[ ! "$bbNewArray" =~ ^[[:alpha:]_][[:alnum:]_]*$ ]]; then
  printf "\e[2m%s: %s\e[0m\n" "$bbapp" "Invalid identifier" 1>&2
  return 6
fi

#                                                   INDEXED to ASSOCIATIVE
#=========================================================================
if [[ "${bbFlag[1]}" =~ ^-a ]]; then
  # replace -a with -A and change the name
  local bbResult
  bbResult="${bbDeclare/#declare -a/declare -Ag}"
  bbResult="${bbResult/$1=/$bbNewArray=}"
  unset "$bbArrayName"
  eval "$bbResult"
  return $?
fi

#                                                   ASSOCIATIVE to INDEXED
#=========================================================================
if [[ "${bbFlag[1]}" =~ ^-A ]]; then
  local bbKey bbDecl
  local -a bbTemp=()

  # Add values from assoc to bbTemp array
  for bbKey in "${bbArrayRef[@]}"; do
    bbTemp+=("$bbKey")
  done

  bbDecl="$(declare -p bbTemp 2>/dev/null)"
  bbResult="${bbDecl/bbTemp=/$bbNewArray=}"
  bbResult="${bbResult/#declare -a/declare -ag}"
  unset "$bbArrayName"
  eval "$bbResult"
  return $?
fi

} # $BING_FUNC/array_convert.bash
