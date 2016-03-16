#!/bin/bash bingmsg
#==================================================================
#: FILE: do.bash
#: PATH: $BING/func/do.bash
#: TYPE: function
#:
#: AUTHOR:
#:      bing-bash by mandober <zgag@yahoo.com>
#:      https://github.com/mandober/bing-bash
#:      za Ǆ - Use freely at own's risk
#:      3-Mar-2016 (last revision)
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: NAME: 
#:      bb_do
#:
#: DESCRIPTION:
#:      Displays error message. 
#:
#: DEPENDENCIES:
#:      -
#:
#: EXAMPLE:
#:      bb_err 52
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: SYNOPSIS:
#:      bb_do --verb var
#:
#: OPTIONS: 
#:      -
#:
#: PARAMETERS:
#:      <integer> ERRCODE - error number
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: ENVIRONMENT:
#:      -
#:
#: STDOUT:
#:      -
#:
#: STDERR:
#:      Error messages.
#:
#: RETURN CODE:
#:		0  (no errors)
#:	   51  Positional parameter absent
#:	   52  Wrong number of positional parameters
#:	   61  Invalid identifier
#:	  244  Not a valid option
#==================================================================

bb_do() {

### ABOUT
local bbapp="${FUNCNAME[0]}"
local bbnfo="[bing-bash] $app v.0.5"
local usage="USAGE: $app VERB VAR"

### CHECK
[[ $# -eq 0 ]] && { bb err 51; printf "${usage}\n" >&2; return 51; }
[[ $# -gt 2 ]] && { bb err 52; printf "${usage}\n" >&2; return 52; }

### HELP
[[ $1 =~ ^(--usage)$ ]] && { printf "${usage}\n"; return 0; }
[[ $1 =~ ^(--version)$ ]] && { printf "${usage}\n"; return 0; }
[[ $1 =~ ^(--help)$ ]] && {
	cat <<-EOFF
	$bbnfo
	  Helper procedures.
	$usage
	  VERB is one of these:
	    trim - Trim leading, trailing and intermediate whitespace off variable.
	   range - Generate a sequence
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

#1 VERB
local bbVERB
bbVERB="$1"

#2 ACTION
local bbVar
bbVar="$2"

if [[ -z "$bbVERB" ]] || [[ -z "$bbVar" ]]; then bb_err 53; return 53; fi


### GO
case $bbVERB in

 --load) 
	# USAGE: bb_do --load function
	printf "Loading function: %s\n" "$bbVar"
 ;;


 --sufix) 
 	#@ USAGE: bb_do --sufix STRING
 	#@ Append CHR after each character of STRING
	local bbN j bbString=
	bbN="${#bbVar}"
	for (( j=0; j<=$bbN; j++ )) {
		bbString+="${bbVar:$j:1} "
	}
	bbString="${bbString%\${3:- }"
	printf "%s\n" "$bbString"
 ;;


 --trim) . "$BING_FUNC/strings/trim"; bbtrim "$bbValue";;

 --bb_explode) . "$BING_FUNC/bb_explode"; bb_explode "$bbValue";;

 --len) printf "${#bbValue}\n";;

 --range) 
	# bb_do --range 1,4-8,10,12-22,30-35,50
	echo "range"
 ;;

 *) bb_err 194; return 194;;

esac

}
