#!/bin/bash bingmsg
#==================================================================
#: FILE: explode.bash
#: PATH: $BING_FUNC/explode.bash
#: TYPE: function
#:
#: AUTHOR:
#:      bing-bash by mandober <zgag@yahoo.com>
#:      https://github.com/mandober/bing-bash
#:      za Ǆ - Use freely at owns risk
#:      9-Mar-2016 (last revision)
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: NAME: 
#:      bb_explode
#:
#: BRIEF: 
#:      Convert a string to array.
#:
#: DESCRIPTION:
#:      Convert a string to array by splitting STRING by DELIM substring.
#:      Returns NAME, an indexed array of strings, each of which is a 
#:      substring of STRING, formed by splitting STRING on boundaries
#:      delimited by the DELIM.
#:      * DELIM can be a single character or multi-character substring.
#:        - If skipped, the DELIM defaults to (in order of precedence):
#:        colon(:), slash(/), comma(,), dot(.),
#:        dash(-), semicolon(;), pipe(|), space ( ).
#:        - If -c option is given, the DELIM is a character boundary i.e.
#:        each element of array will contain a single character from STRING,
#:        but final array will not contain any empty elements.
#:      * NAME will be the name for resulting indexed array, so it must be a
#:        valid identifier. If not provided it defaults to BING_EXPLODED.
#:
#: DEPENDENCIES:
#:      bb_err
#:
#: EXAMPLE:
#:      bb_explode var # variable passed by name
#:      bb_explode "$var"
#:      bb_explode var -c newArray  
#:      bb_explode var -d=':' newArray
#:      bb_explode var -d ', ' newArray
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: SYNOPSIS:
#:      bb_explode STRING [-c|-d DELIM] [NAME]
#:
#: OPTIONS:
#:      -c, --char, --chars
#:      Delimiter is a character boundary.
#:
#:      -d, --delim, --delimiter
#:      specify delimiter after equal sign (e.g. -d=':')
#:      or as a following argument (e.g. -d ', ').
#:
#: PARAMETERS:
#:
#:      STRING <string>
#:      String to bb_explode. It is the only required parameter.
#:      Variables can be passed by name or by value.
#:
#:      DELIM <char>
#:      Substring composed of single or muliple characters
#:      by which to split the STRING.
#:
#:      NAME <identifier>
#:      Identifier for resulting array.
#:      If not given the default is BING_EXPLODED.
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: RETURN TO ENVIRONMENT:
#:      <array identifier> NAME
#:      Returns an indexed array of strings, called NAME if name
#:      is provided. Otherwise it is called BING_EXPLODED.
#:      In fact, the array is not `returned', but a new array
#:      variable by that name is created in the current environment.
#:
#: STDOUT:
#:      Help, usage, version (if explicitly requested).
#:
#: STDERR:
#:      Error messages.
#:
#: RETURN CODE:
#:      0 - success
#:	    non 0 - see err.bash file
#==================================================================

bb_explode() {

### ABOUT
local -r bbapp="${FUNCNAME[0]}"
local -r bbnfo="[bing-bash] $bbapp v.0.19"
local -r usage="USAGE: $bbapp STRING [-c|-d DELIM] [NAME]"

### DEPENDENCIES
[[ -z "$(declare -F bb_err 2>/dev/null)" ]] && . $BING_FUNC/err.bash

### PRECHECK
[[ $# -eq 0 ]] && { bb_err 51; printf "%s" "${usage}\n" >&2; return 51; }
[[ $# -gt 4 ]] && { bb_err 52; printf "%s" "${usage}\n" >&2; return 52; }

### HELP
[[ $1 =~ ^(-u|--usage)$ ]] && { printf "%s" "${usage}\n"; return 0; }
[[ $1 =~ ^(-v|--version)$ ]] && { printf "%s" "${bbnfo}\n"; return 0; }
[[ $1 =~ ^(-h|--help)$ ]] && {
	cat <<-EOFF
	$bbnfo
	  Convert a string to array by splitting it by substring.

	$usage

	DESCRIPTION:
	  Creates NAME, an indexed array of strings, each of which is a 
	  substring of STRING, formed by splitting it on boundaries
	  delimited by the DELIM which can also be multi-character string.
	  If DELIM is not given it defaults to (in order of precedance):
	     colon(:), slash(/), comma(,), dot(.),
	     dash(-), semicolon(;), pipe(|), space ( ).
	  If -c option is given, the DELIM is a character boundary i.e.
	  each element of array will contain a single character from STRING,
	  but final array will not contain any empty elements. If NAME is not
	  provided it defaults to BING_EXPLODED.
	
	OPTIONS:
	   -d, --delim      Substring of STRING by which to split the STRING
	   -c, --chars      Split string by characters (array of characters).
	   -h, --help       Show program help.
	   -u, --usage      Show program usage.
	   -v, --version    Show program version.
	EOFF
	printf "\nEXAMPLES:\n"
	printf "   $bbapp BASHOPTS newArray \e[2m%s\e[0m\n" \
	"# will be exploded by ':'"
	printf "   $bbapp BASH_VERSION -d '.' newArray \e[2m%s\e[0m\n" \
	"# variable passed by name"
	printf "   $bbapp \"\$BASH_VERSION\" -d='.' newArray \e[2m%s\e[0m\n" \
	"# variable passed by value"
	printf "   $bbapp USER -c \e[2m%s\e[0m\n\n" \
	"# default array name is BING_EXPLODED"
	return 0
}

### SET
 shopt -s extglob 		# Enable extended regular expressions
 shopt -s extquote		# Enables $'' and $"" quoting
 shopt -u nocasematch 	# regexp case-sensitivity
 set -o noglob			# Disable globbing. Enable it upon return:
 trap "set +o noglob" RETURN ERR SIGHUP SIGINT SIGTERM


### PARAMS
# First param is the STRING to explode, see if it's passed by name or by value?
# Check the former, see if there's a var by that name. If there is, then
# bb_explode its value, otherwise assume the latter.
local bbString bbFlag bbTNT bbArrayName

if bbFlag=$(declare -p "$1" 2>/dev/null); then
	# ...that is not an array
	bbFlag=( $bbFlag )
	bbFlag="${bbFlag[1]#?}"
	[[ "$bbFlag" =~ ^[aA][[:alpha:]]*$ ]] && { bb_err 62 && return 62; }
	bbString="${!1}" # bb_explode var
else
	bbString="$1" # bb_explode $var
fi
shift

## other params, defaults
bbTNT="default"
bbArrayName="BING_EXPLODED"

# bb_explode STRING -c | bb_explode STRING -d=', '
if [[ $# -gt 0 ]]; then
	while [[ "${1+def}" ]]; do
		case $1 in
		 -c|--char|--chars)
			bbTNT="nill"
		 ;;

		 -d|--delim|--delimiter)
			delim="user"
			bbTNT="${2?}"
			shift
		 ;;

		 -d=*|--delim=*|--delimiter=*)
			delim="user"
			bbTNT="${1#*=}"
		 ;;

		 *)
			bbArrayName="$1"
			[[ ! "$bbArrayName" =~ ^[[:alpha:]_][[:alnum:]_]*$ ]] && { 
				bb_err 61 && return 61;
			}
		 ;;
		esac
	shift
	done
fi

# echo "bbString: $bbString"
# echo "bbTNT: $bbTNT"
# echo "bbArrayName: $bbArrayName"


#   ====================== DEFAULT DELIMITER ===================
if [[ "$bbTNT" == "default" ]]; then

  # string is alnum only, so null delim
  # [[ "$bbString" =~ [[:alnum:]]+ ]] && bbTNT="nill"

  case "$bbString" in
    *:*)  bbTNT=':';;
    *\/*)  bbTNT='/';;
    *,*)  bbTNT=',';;
    *.*)  bbTNT='.';;
    *-*)  bbTNT='-';;
    *\;*)  bbTNT=';';;
    *|*)  bbTNT='|';;
    *)  bbTNT=' ';;
  esac

  IFS="$bbTNT" read -a "$bbArrayName" <<< "$bbString"

  return 0

fi


# 	====================== CHAR DELIMITER =======================
if [[ "$bbTNT" == "nill" ]]; then
	# Explode string into array of chars by inserting space after
	# each char and bb_explode it. Exclude blank elements from array.
	local bbSrc="$bbString"
	unset bbString
	while [[ "${#bbSrc}" -gt 0 ]]; do
		bbString+="${bbSrc:0:1} "
		bbSrc="${bbSrc#?}"
	done
	bbTNT=' '
	IFS="$bbTNT" read -a "$bbArrayName" <<< "$bbString"
	return 0
fi


#   ================== USER/COMPOUND DELIMITER ===================
if [[ "$delim" == "user" ]]; then
	# If user DELIMITER has more than 1 char
	# replace that group of chars with a Unit Separator ($'\x1f')
	[[ "${bbTNT}" = "\\n" ]] && bbString="${bbString//$'\\n'/$'\x1f'}"
	[[ "${bbTNT}" = "\\t" ]] && bbString="${bbString//$'\\t'/$'\x1f'}"

	if [[ "${#bbTNT}" -gt 1 ]]; then
		bbString="${bbString//$bbTNT/$'\x1f'}"
		IFS=$'\x1f' read -a "$bbArrayName" <<< "$bbString"
	else
		IFS="$bbTNT" read -a "$bbArrayName" <<< "$bbString"
	fi

	return 0
fi

}
