#!/bin/bash bingmsg
#==================================================================
#: FILE: is.bash
#: PATH: $BING/func/is.bash
#: TYPE: function
#:
#: AUTHOR:
#:      bing-bash by mandober <zgag@yahoo.com>
#:      https://github.com/mandober/bing-bash
#:      za Ǆ - Use freely at owns risk
#:      8-Mar-2016 (last revision)
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: NAME: 
#:      bb_is
#:
#: DESCRIPTION:
#:      Subroutines for pattern matching, sanity checks, 
#:      qualifying strings, variables and array.
#:      All subroutines return 0 (true) or 1 (false).
#:
#: DEPENDENCIES:
#:      bb_err, bb_get
#:
#: EXAMPLE:
#:      bb_is --digit NAME
#:      bb_is --opt NAME
#:      bb_is --set NAME
#:      bb_is --array NAME
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: SYNOPSIS:
#:      bb_is --PROPERTY NAME
#:
#: OPTIONS:
#:      PROPERTY - Range of options: alpha, alnum, digit, range, 
#:      int(eger), float, opt, opt-long, opt-short, opt-complex
#:      id, set, null, loaded, array, ind(exed), assoc(iative)
#:
#: PARAMETERS:
#:      <string> NAME - word, name, variable, array...
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: STDOUT:
#:      -
#:
#: STDERR:
#:      Error messages.
#:
#: RETURN CODE:
#:		 0   true
#:     1   false
#:	 ...   see err.bash for other error codes
#==================================================================

bb_is() {

### ABOUT
local bbapp="${FUNCNAME[0]}"
local bbnfo="[bing-bash] $bbapp v.0.27"
local usage="USAGE: $bbapp --PROPERTY NAME"

### DEPENDENCIES
bb_load bb_err bb_get

### PRECHECK
[[ $# -eq 0 ]] && { bb_err 51; printf "${usage}\n" 1>&2; return 51; }
[[ $# -gt 3 ]] && { bb_err 52; printf "${usage}\n" 1>&2; return 52; }

### HELP
[[ $1 =~ ^(-u|--usage)$ ]] && { printf "${usage}\n"; return 0; }
[[ $1 =~ ^(-v|--version)$ ]] && { printf "${bbnfo}\n"; return 0; }
[[ $1 =~ ^(-h|--help)$ ]] && {
	cat <<-EOFF
	$bbnfo
	  Pattern matching helper functions.
	$usage
	  PROPERTY is one of the following:
	        alpha - check if string consist of alphabetic chars only
	        alnum - check if string consist of alpha-numeric chars only
	        digit - check if string consist of digits only
	        range - check if string is a number range (e.g. 1,3-6,9,11-15)
	      integer - check if string is an integer
	        float - check if string is a float

	          opt - check if string is either short or long option
	     opt-long - check if string is a long option (e.g. --an-example)
	    opt-short - check if string is a short option (e.g. -x)
	  opt-complex - check if string is a complex option (e.g.--filename=/bin/bb)

	           id - check if string is a valid identifier
	          set - check if variable is set
	         null - check if variable is null
	       loaded - check if function is available (loaded)
	       substr - Check if substring is part of string

	        array - check if variable is an array
	      indexed - check if array is an indexed array
	  associative - check if array is an associative array
	      numeric - check if array is a numeric array

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
#   PARAMS
#

# $1 --OPTION
[[ -z "$1" ]] && { bb_err 53; return 53; }
[[ ! "$1" =~ ^-?-[[:alpha:]][[:alnum:]-]+$ ]] && return 241
local bbOpt="$1"
shift

# $2 NAME
[[ -z "${1:+defined}" ]] && { bb_err 53; return 53; }



### PROCESS
case $bbOpt in
  
 --alpha)
  #
  #  USAGE: 
  #      bb_is --alpha STRING
  #
  #  DESCRIPTION: 
  #      Check if all characters in a STRING 
  #      are alphabetic (e.g. a-zA-Z)
  #
  [[ "$1" =~ ^[[:alpha:]]+$ ]] && return 0
 ;;

 --alnum)
  #
  #  USAGE: 
  #      bb_is --alnum STRING
  #
  #  DESCRIPTION: 
  #      Check if all characters in a STRING 
  #      are alphanumeric (e.g. a-zA-Z0-9)
  #
  [[ "$1" =~ ^[[:alnum:]]+$ ]] && return 0
 ;;

 --int?(eger))
  #
  #  USAGE: 
  #      bb_is --integer STRING
  #
  #  DESCRIPTION:
  #      Check if STRING is a positive or negative
  #      integer (e.g. -5, 0, 113)
  #
  [[ "$1" =~ ^-?[[:digit:]]+$ ]] && return 0
 ;;

 --float)
  #
  #  USAGE: 
  #      bb_is --float STRING
  #
  #  DESCRIPTION:
  #      Check if STRING is a float
  #
  [[ "$1" =~ ^-?[[:digit:]]+\.[[:digit:]]+$ ]] && return 0
 ;;

 --range)
  #
  #  USAGE: 
  #      bb_is --range STRING
  #
  #  DESCRIPTION: 
  #      Check if STRING is a range (e.g. 0,3,5-10,12,15-20)
  #
  [[ "$1" =~ [[:digit:]]+[,-]? ]] && return 0
 ;;
               

 --opt-short)
  #
  #  USAGE: 
  #      bb_is --opt-short STRING
  #
  #  DESCRIPTION: 
  #      Check if STRING is a short option (e.g. -t)
  #
  [[ "$1" =~ ^-[[:alpha:]]$ ]] && return 0
 ;;


 --opt-long)
  #
  #  USAGE: 
  #      bb_is --opt-long STRING
  #
  #  DESCRIPTION: 
  #      Check if STRING is a long option (e.g. --long-option)
  #
  [[ "$1" =~ ^--[[:alpha:]][[:alpha:]-]+$ ]] && return 0
 ;;

 --opt)
  #
  #  USAGE: 
  #      bb_is --opt-short STRING
  #
  #  DESCRIPTION: 
  #      Check if STRING is a short or long option
  #
  [[ "$1" =~ ^-[[:alpha:]]$ ]] || \
  [[ "$1" =~ ^--[[:alpha:]][[:alpha:]-]+$ ]] && return 0
 ;;

 --opt-complex)
  #
  #  USAGE: 
  #      bb_is --opt-complex STRING
  #
  #  DESCRIPTION: 
  #      Check if STRING is a complex option
  #
  [[ "$1" =~ ^--?[[:alnum:]-]+([:=][[:alnum:]\+\./_-]+)?$ ]] && return 0
 ;;


 --id)
  #
  #  USAGE: 
  #      bb_is --id STRING
  #
  #  DESCRIPTION: 
  #      Check if STRING is a valid identifier
  #
  [[ "$1" =~ ^[[:alpha:]_][[:alnum:]_]*$ ]] && return 0
 ;;

 --set)
  #
  #  USAGE: 
  #      bb_is --set VAR
  #
  #  DESCRIPTION: 
  #      Check if VAR is set (but it can be null)
  #
  [[ "$(declare -p "$1" 2>/dev/null)" ]] && return 0
 ;;

 --null)
  #
  #  USAGE: 
  #      bb_is --null VAR
  #
  #  DESCRIPTION: 
  #      Check if VAR is set and not null
  #
  [[ -z "${!1}" ]] && return 0
 ;;

 --loaded)
  #
  #  USAGE: 
  #      bb_is --loaded FUNCTION
  #
  #  DESCRIPTION: 
  #      Check if FUNCTION is available (loaded)
  #
  if declare -F "$1" &>/dev/null; then
    return 0
  fi
 ;;

 --substr)
  #
  #  USAGE: 
  #      bb_is --substr SUBSTRING STRING
  #
  #  DESCRIPTION: 
  #      Check if SUBSTRING is part of STRING
  #
  case $2 in 
   *$1*) return 0;;
      *) return 1;;
  esac
 ;;


 --array)
  #
  #  USAGE: 
  #      bb_is --array ARRAY
  #  
  #  DESCRIPTION: 
  #      Check if variable is an array.
  #
  [[ ! "$(declare -p "$1" 2>/dev/null)" ]] && return 60
  local bbFlag="$(bb_get --attr $1)"
  [[ $bbFlag =~ ^[aA][[:alpha:]]*$ ]] && return 0
  return 63
 ;;


--ind?(exed))
  #
  #  USAGE: 
  #      bb_is --indexed ARRAY
  #  
  #  DESCRIPTION: 
  #      Check if variable is an indexed array.
  #
  [[ ! "$(declare -p "$1" 2>/dev/null)" ]] && return 60
  local bbFlag="$(bb_get --attr $1)"
  [[ "$bbFlag" =~ ^a[[:alpha:]]*$ ]] && return 0
  return 58
 ;;


--assoc?(iative))
  #
  #  USAGE: 
  #      bb_is --associative ARRAY
  #  
  #  DESCRIPTION: 
  #      Check if variable is an associative array.
  #
  [[ ! "$(declare -p "$1" 2>/dev/null)" ]] && return 60
  local bbFlag="$(bb_get --attr $1)"
  [[ "$bbFlag" =~ ^A[[:alpha:]]*$ ]] && return 0
  return 59
 ;;


--num|--numeric)
  #
  #  USAGE: 
  #      bb_is --numeric NAME
  #  
  #  DESCRIPTION: 
  #      * Check if NAME is numeric string. Check if all
  #        characters in NAME are digits (e.g. 0-9)
  #      * Check if NAME is numeric array. All values
  #        must be integers (but empty elements allowed).
  # 
  if bb_is --array "$1"; then
    # Check if array is numeric
  	local bbVal
  	local -n bbArrayRef="$1"
    for bbVal in "${bbArrayRef[@]}"; do
  	  [[ -z "$bbVal" ]] && continue
  	  [[ ! "$bbVal" =~ ^-?[[:digit:]]+$ ]] && return 1
    done
    return 0
  else
    # Check if string is numeric
    [[ "$1" =~ ^-?[[:digit:]]+$ ]] && return 0
  fi
  return 1
 ;;


 *) return 1;;

esac



return 1
}

# ** for arrays
# When is an array empty?
# There's bug in bash 4.3 (fixed in 4.4-beta), so declared array:
#    declare -a ARRAY
# although present in symbols table:
#    declare -p
#    -> ... declare -a arrayname='()' ...
# comes up as unset when checked alone with 
#    declare -p ARRAY
#    -bash: declare: arrayname: not found
# BUT declaring an empty array:
#    declare -a ARRAY=()
# does work and it comes up, as expected, when checked with:
#    declare -p ARRAY
#    -> declare -a arr1='()'
