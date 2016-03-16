#!/bin/bash bingmsg
#==================================================================
#: FILE: array.bash
#: PATH: $BING/func/array.bash
#: TYPE: function
#:
#: AUTHOR:
#:      bing-bash by mandober <zgag@yahoo.com>
#:      https://github.com/mandober/bing-bash
#:      za Ǆ - Use freely at owns risk
#:      4-Mar-2016 (last revision)
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: NAME: 
#:      bb_array
#:
#: BRIEF:
#:      Array related subroutines.
#:
#: DESCRIPTION:
#:      Subroutines for extracting information from arrays, 
#:      modifying, converting, cloning etc.
#:
#: DEPENDENCIES:
#:      bb_err, bb_explode, bb_clone
#:
#: EXAMPLE:
#:      bb_array
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: SYNOPSIS:
#:      bb_array FNAME [...]
#:
#: OPTIONS: 
#:      
#:
#: PARAMETERS:
#:      <string> FNAME - name of the function(s) to load
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: STDOUT:
#:      -
#:
#: STDERR:
#:      Error messages, usage
#:
#: RETURN CODE:
#:		  0  successful run - no errors
#:  non-0  see err.bash file
#==================================================================

bb_array() {

### ABOUT
local bbapp="${FUNCNAME[0]}"
local bbnfo="[bing-bash] $bbapp v.0.18"
local usage="USAGE: \n"
usage+=" ACCESSORS: $bbapp -d|t|n|k|v|e ARRAY\n"
usage+=" MUTILATORS: $bbapp -s|p|z|u ARRAY\n"
usage+="$bbapp -S [-rMhnRVu] ARRAY\n"
usage+="$bbapp -c ARRAY NEWARRAY\n"
usage+="$bbapp -r N[,N...] ARRAY"

### PRECHECK
[[ $# -eq 0 ]] && { bb_err 51; printf "${usage}\n" >&2 && return 51; }
[[ $# -gt 4 ]] && { bb_err 52; printf "${usage}\n" >&2 && return 52; }

### HELP
[[ $1 =~ ^(--usage)$ ]] && { printf "${usage}\n" >&2 && return 0; }
[[ $1 =~ ^(--version)$ ]] && { printf "${bbnfo}\n" >&2 && return 0; }
[[ $1 =~ ^(--help)$ ]] && {
	printf "$bbnfo\n"
	printf "  Array functions.\n"
	printf "$usage\n"
	cat <<-EOFF
	OPTIONS
	  
	  ACCESSORS:
	    -d, --dump        Dump an array.
	    -t, --type        Return array type (indexed or associative).
	    -n, --count       Return number of array elements.
	    -k, --keys        Return keys of an array.
	    -v, --values      Return values of an array.
	    -e, --empty       Return empty keys of an array.
	  
	  MUTILATORS:
	    -p, --pack        Re-index an indexed sparse array.
	    -q, --squeeze     Remove unset elements from array.
	    -z, --zip         Pack and squeeze an array.
	    -s, --sort        Sort array's elements.
	    -u, --unique      Remove duplicated values from an array.
	    -b, --convert     Convert indexed to associative array or vice versa.

	  GENERATORS:
	    -c, --clone       Clone an array.
	    -m, --merge       Merge arrays.
	    -r, --remove      Remove element(s) from an array.
	    -f, --shift       Shifts an array.

	  OTHER:
	        --help        Show program help.
	        --usage       Show program usage.
	        --version     Show program version.
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
#  PARAMS
#

# ACCESSORS:
# ---------
# -d|--dump
# -t|--type
# -n|--count 
# -k|--keys
# -v|--values
# -e|--empty
# -m|--max



# $1) ACTION
local bbOpt="$1"
if [[ ! "$bbOpt" =~ ^-[[:alpha:]]$ ]] && \
   [[ ! "$bbOpt" =~ ^--[[:alpha:]][[:alpha:]-]+$ ]]; then return 242; fi

# $2) ARRAY
if [[ ! "$2" =~ ^-[[:alpha:]]$ ]]; then
  ! bb_is --array "$2" && { bb_err 63; printf "$usage\n" >&2; return 63; }
	local bbArrayName="$2"
	local -n bbArrayRef="$2"
fi

### MISC
local bbTemp

unset BING_ARRAY
local BING_ARRAY

### PROCESS
case $bbOpt in

#	============================ ACCESSORS ============================

 -d|--dump)
  #
  #  USAGE: 
  #      array --dump ARRAY
  #
  #  DESCRIPTION: 
  #      Quick dump of indexed or associative arrays.
  #      For prettier output see `typeof' function.
  #
  printf "%12s: %s\n" "$bbArrayName" "[${#bbArrayRef[@]}]"
  for bbTemp in "${!bbArrayRef[@]}"; do
    printf "%12s: %s \e[2m(%d)\e[0m \n" \
      "[$bbTemp]" "${bbArrayRef[$bbTemp]}" "${#bbArrayRef[$bbTemp]}"
  done
  return 0
 ;;


 -t|--type)
  #
  #  USAGE: 
  #      array --type ARRAY
  #
  #  DESCRIPTION: 
  #      Qualify an array as indexed or associative.
  #
  bbTemp="$(bb_get --attr "$bbArrayName")"
  [[ "$bbTemp" =~ ^A[[:alpha:]]*$ ]] && { printf "associative" && return 0; }
  [[ "$bbTemp" =~ ^a[[:alpha:]]*$ ]] && { printf "indexed" && return 0; }
  return 63
 ;;


 -c|--count)
  #
  #  USAGE: 
  #      array --count ARRAY
  #
  #  DESCRIPTION: 
  #      Return number of array of elements.
  #
  printf "%s" "${#bbArrayRef[@]}" && return 0
 ;;


 -k|--keys)
  #
  #  USAGE: 
  #      array --keys ARRAY
  #
  #  DESCRIPTION: 
  #      Return keys of an array.
  #
  local bbKeys
  printf -v bbKeys "%s, " "${!bbArrayRef[@]}"
  printf "%s" "${bbKeys%??}" && return 0
 ;;


 -v|--values)
  #
  #  USAGE: 
  #      array --values ARRAY
  #
  #  DESCRIPTION: 
  #      Return values of an array.
  #
  local bbVals
  printf -v bbVals "\"%s\", " "${bbArrayRef[@]}"
  printf "%s" "${bbVals%??}" && return 0
 ;;


 -e|--empty)
  #
  #  USAGE: 
  #      array --empty ARRAY
  #
  #  DESCRIPTION: 
  #      Return empty elements of an array
  #
  local bbKey bbAltArray
  for bbKey in "${!bbArrayRef[@]}"; do
    [[ -n "${bbArrayRef[$bbKey]}" ]] && continue
    bbAltArray+="${bbKey} "
  done
    printf "%s" "${bbAltArray%?}" && return 0
 ;;


 -m|--max)
  #
  #  USAGE: 
  #      array --largest ARRAY
  #  
  #  DESCRIPTION: 
  #      Return number of chars of the element with most chars.
  #
  local bbKey bbCurr bbMax bbVal
  for bbKey in "${!bbArrayRef[@]}"; do
    bbCurr=${#bbArrayRef[$bbKey]}
    bbMax=$(( bbCurr > bbMax ? bbCurr : bbMax ))
  done

  # for bbVal in "${bbArrayRef[@]}"; do
  #   [[ "$bbVal" > "$bbMax" ]] && bbMax="$bbVal"
  # done

  printf "%s" "$bbMax" && return 0
 ;;


 -l|--list)
  #
  #  USAGE: 
  #      array --list ARRAY
  #  
  #  DESCRIPTION: 
  #      Return array as a colon separated list.
  #
  local bbPath
  bbFUNCS=
  
  for bbPath in "${FUNCS[@]}"; do
    bbFUNCS+="${bbPath}:"
  done

  bbFUNCS="${bbFUNCS%?}"
  printf "%s" "$bbFUNCS";
  return 0
 ;;


 *) return 195;;

esac


return 195
}
