#!/bin/bash bingmsg
#=========================================================================
#: FILE: get.bash
#: PATH: $BING_FUNC/get.bash
#: TYPE: function
#:   NS: shell:bash:mandober:bing-bash:function:bb_get
#:  CAT: variables
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
#:      bb_get
#:
#: BRIEF: 
#:      Get information about variables.
#:
#: DESCRIPTION:
#:      Routines that collect information: variable attributes, 
#:      variable/array length, etc.
#:
#: DEPENDENCIES:
#:      
#:
#: EXAMPLE:
#:      $ declare -air arr=()
#:      $ bb_get --attr arr
#:      $ air
#:      # which is a(rray indexed) i(nteger) r(eadonly)
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: SYNOPSIS:
#:      bb_get --ATTR NAME
#:
#: OPTIONS: 
#:      --len  Returns variable's length or number of array elements
#:      --attr  Returns variable's attributes
#:      
#: PARAMETERS:
#:      VAR <string>
#:      scalar or array variable
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: RETURN:
#:      
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
#:      3  Variable is not set
#=========================================================================

bb_get() {

#                                                                    ABOUT
#-------------------------------------------------------------------------
 local -r bbapp="${FUNCNAME[0]}"
 local -r bbnfo="[bing-bash] $bbapp v.0.19"
 local usage="USAGE: $bbapp --ATTR NAME"

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
  printf "\e[7m%s\e[0m\n" "$bbnfo"
  printf "\e[1m%s\e[0m\n" "$usage"
	cat <<-EOFF
	Subroutines that collect miscellaneous information.
  
	PROPERTY is one of the following:
	    attr - Get variable's attributes.
	    type - Qualify an array as indexed or associative.

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
case $1 in

-l|--len|--length)
  #
  #  USAGE: 
  #      bb_str --length TOKEN
  #
  #  DESCRIPTION: 
  #      Output length of string or array.
  #
  shift
  # usage="USAGE: $bbapp -l|--len|--length TOKEN"
  # (($# > 1)) && { printf "%s\n" "$usage" >&2; return 9; }

  local bbToken bbFlag

  for bbToken; do
    if ! bbFlag="$(declare -p "$bbToken" 2>/dev/null)"; then
      # use value
      printf "%d " "${#bbToken}"
    else
      # use var

      bbToken="${!bbToken}"
      printf "%d " "${#bbToken}"
    fi


    # passed by value
    # bbString="$1"
    # passed by name
    # declare -p "$1" &>/dev/null && bbString="${!1}"
    # printf "%s" "${#bbString}"
  done
  printf '\n'
  return 0
;;

-a|--attr)
  #
  #  USAGE: 
  #      bb_get --attr VAR
  #
  #  DESCRIPTION: 
  #      Get VAR's attributes [aAlinuxcrt]
  #
  #  EXAMPLE:
  #      bb_get --attr BASHPID  # returns `ir' (integer readonly)
  #
  shift
  local bbDeclare bbVar
  for bbVar; do
    if ! bbDeclare="$(declare -p "$1" 2>/dev/null)"; then
      printf "\e[2m%s: %s\e[0m\n" "$bbapp" "Parameter $1 is not set" >&2
      return 3
    fi
    bbDeclare=( $bbDeclare )
    printf "%s\n" "${bbDeclare[1]#?}"
  done
  return 0
;;


-t|--type)
  #
  #  USAGE: 
  #      bb_get --type ARRAY
  #
  #  DESCRIPTION: 
  #      Qualify an array as indexed or associative.
  #
  bbTemp="$(bb_get --attr "$1")"
  [[ "$bbTemp" =~ ^A[[:alpha:]]*$ ]] && { printf "associative" && return 0; }
  [[ "$bbTemp" =~ ^a[[:alpha:]]*$ ]] && { printf "indexed" && return 0; }
  [[ "$bbTemp" =~ ^a[[:alpha:]]*$ ]] && { printf "indexed" && return 0; }
  return 1
;;


--md5)
  #
  #  USAGE: 
  #      bb_get --md5 FILE
  #
  #  DESCRIPTION: 
  #      Return md5 of the file.
  #
  bbFunc=$1  # e.g. bb_err
  bbFuncFile="${BING_FUNC}/${bbFunc#bb_}.bash"  # $BING_FUNC/err
  bbMD5="$(md5sum "$bbFuncFile")"
  bbMD5="${bbMD5:0:32}"
  printf "%s" "$bbMD5"
  return 0
;;


-p|--pos|--position)
  #
  #  USAGE: 
  #      bb_get --char N STRING
  #
  #  DESCRIPTION: 
  #      Return char at position N
  #
  local -i bbChar="$1"
  local bbString="$2"
  [[ ! "$bbChar" =~ ^-?[[:digit:]]+$ ]] && return 247

  if [[ $bbChar -gt 0 ]]; then
     [[ $bbChar -gt "${#bbString}" ]] && return 30
     (( bbChar-- ))
  fi

  printf "%s" "${bbString:$bbChar:1}"
  return 0
;;

*) return 1;;

esac

} # $BING_FUNC/get.bash
