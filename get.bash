#!/bin/bash bingmsg
#==================================================================
#: FILE: get
#: PATH: $BING/func/get
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
#:      bb_get
#:
#: BRIEF: 
#:      Routines that get information.
#:
#: DESCRIPTION:
#:      Routines for getting information about arguments. For example,
#:      option `--attr' returns variable's attributes (-aAi...).
#:
#: DEPENDENCIES:
#:      bb_err
#:
#: EXAMPLE:
#:      bb_get --attr VAR
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: SYNOPSIS:
#:      bb_get --ATTR VAR
#:
#: OPTIONS: 
#:      Range of options:
#:      --attr  Returns variable's attributes
#:
#: PARAMETERS:
#:      <string> VAR - word, name, variable, array...
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: RETURN:
#:
#: STDOUT:
#:      plenty
#:
#: STDERR:
#:      Error messages, usage
#:
#: RETURN CODE:
#:		 0   true
#:	 not 0   false
#:		51   Positional parameter absent
#:		52   Wrong number of positional parameters
#:		53   Positional parameter empty
#:	    ...  see err for error codes of specific procedures
#==================================================================

bb_get() {

### ABOUT
local bbapp="${FUNCNAME[0]}"
local bbnfo="[bing-bash] $bbapp v.0.13"
local usage="USAGE: $bbapp --property VAR"

### DEPENDENCIES
[[ -z "$(declare -F bb_err 2>/dev/null)" ]] && . $BING/func/err

### PRECHECK
[[ $# -eq 0 ]] && { bb_err 51; printf "${usage}\n" 1>&2; return 51; }
# [[ $# -gt 2 ]] && { bb_err 52; printf "${usage}\n" 1>&2; return 52; }

### HELP
[[ $1 =~ ^(-u|--usage)$ ]] && { printf "${usage}\n"; return 0; }
[[ $1 =~ ^(-v|--version)$ ]] && { printf "${bbnfo}\n"; return 0; }
[[ $1 =~ ^(--help)$ ]] && {
	cat <<-EOFF
	$bbnfo
	  Routines that get information.
	$usage
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

### SET
 shopt -s extglob 		# Enable extended regular expressions
 shopt -s extquote		# Enables $'' and $"" quoting
 shopt -u nocasematch 	# regexp case-sensitivity
 set -o noglob			# Disable globbing. Enable it upon return:
 trap "set +o noglob" RETURN ERR SIGHUP SIGINT SIGTERM


### PARAMS

##1 OPTION
[[ -z "$1" ]] && { bb_err 53; return 53; }
[[ ! "$1" =~ ^--[[:alpha:]][[:alnum:]-]+$ ]] && return 241
local bbOpt="$1"
shift


### PROCESS
case $bbOpt in

 -a|--attr)
  #
  #  USAGE: 
  #      bb_get --attr VAR
  #
  #  DESCRIPTION: 
  #      Get VAR's attributes, one or combination of: -aAlinuxcrt
  #
  #  EXAMPLE:
  #      bb_get --attr BASHPID  # returns `ir' (integer readonly)
  #
  [[ ! "$1" =~ ^[[:alpha:]_][[:alnum:]_]*$ ]] && return 61
  local bbFlag
  if ! bbFlag=$(declare -p "$1" 2>/dev/null); then 
    return 60
  else
    bbFlag=( $bbFlag )
    bbFlag="${bbFlag[1]#?}"
    printf "%s" "$bbFlag"
    return 0
  fi
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
  return 63
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
  bbFuncFile="${BING_FUNC}/${bbFunc#bb_}.bash"  # $BING_FUNC/err.bash
  bbMD5="$(md5sum "$bbFuncFile")"
  bbMD5="${bbMD5:0:32}"
  printf "%s" "$bbMD5"
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


 *) return 195;;


esac


return 195
}
