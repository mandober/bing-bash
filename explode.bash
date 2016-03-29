#!/bin/bash bingmsg
#=======================================================================
#: FILE: explode.bash
#: PATH: $BING_FUNC/explode.bash
#: TYPE: function
#:       shell:bash:mandober:bing-bash:function:bb_explode
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: AUTHOR:
#:      bing-bash by Ivan Ilic <ivanilic1975@gmail.com>
#:      https://github.com/mandober/bing-bash
#:      za Ǆ - Use freely at owns risk
#:      30-Mar-2016 (last revision)
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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
#:      none
#:
#: EXAMPLE:
#:      bb_explode var      # passed by name
#:      bb_explode "$var"   # passed by value
#:      bb_explode var -c newArray  
#:      bb_explode var -d=':' newArray
#:      bb_explode var -d ', ' newArray
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: SYNOPSIS:
#:      bb_explode STRING [-c|-d DELIM] [NAME]
#:
#: OPTIONS:
#:      -c, --char, --chars <option>
#:      With -c option delimiter is character boundary.
#:      e.g.: bb_explode "abc" -c varray  # varray=([0]=a [1]=b [2]=c)
#:
#:      -d, --delim, --delimiter <option> DELIM <argument>
#:      With -d option delimiter is user supplied string DELIM.
#:      The argument DELIM to this option is mandatory.
#:      DELIM <substring> <required> <argument>
#:        DELIM is user supplied substring of STRING composed of single 
#:        or muliple characters by which the STRING will be exploded.
#:        Specify delimiter after equal sign (e.g. -d=':')
#:        or as a following argument (e.g. -d ', ').
#:
#: PARAMETERS:
#:
#:      STRING <string|identifier> <required>
#:      String STRING to split, passed by name or by value.
#:
#:      NAME <identifier> <optional>
#:      User supplied identifier for resulting array.
#:      If not given the default is BING_EXPLODED.
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: ENVIRONMENT:
#:      NAME <array identifier>
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
#:      0  great success
#:      1  miserable failure
#:      4  Parameter is an array
#:      6  Invalid identifier
#:      9  Parameter empty
#=======================================================================

bb_explode() {

#                                                                   ABOUT
#                                                                   =====
 local -r bbapp="${FUNCNAME[0]}"
 local -r bbnfo="[bing-bash] $bbapp v.0.21"
 local -r usage="USAGE: $bbapp STRING [-c|-d DELIM] [NAME]"

#                                                                PRECHECK
#                                                                ========
  if [[ $# -eq 0 ]]; then
    printf "\e[2m%s: %s\e[0m\n" "$bbapp" "Parameter empty" >&2
    printf "%s\n" "$usage" >&2
    return 9
  fi

#                                                                    HELP
#                                                                    ====
 [[ $1 =~ ^(-u|--usage)$ ]] && { printf "%s\n" "$usage"; return 0; }
 [[ $1 =~ ^(-v|--version)$ ]] && { printf "%s\n" "$bbnfo"; return 0; }
 [[ $1 =~ ^(-h|--help)$ ]] && {
	printf "\e[7m%s\e[0m\n" "$bbnfo"
	printf "\e[1m%s\e[0m\n" "$usage"
	cat <<-EOFF
	Convert a string to array by splitting it by substring.
	
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

#                                                                     SET
#                                                                     ===
 shopt -s extglob extquote; shopt -u nocasematch; set -o noglob
 trap "set +o noglob" RETURN ERR SIGHUP SIGINT SIGTERM

#                                                                  PARAMS
#                                                                  ======
 local bbString bbFlag bbTNT bbArrayName
 
 # First param is the STRING to explode
 # Is it passed by name or by value?
if bbFlag=$(declare -p "$1" 2>/dev/null); then

  # can't explode an array
  bbFlag=( $bbFlag )
  if [[ "${bbFlag[1]}" =~ ^-[aA] ]]; then
    printf "\e[2m%s: %s\e[0m\n" "$bbapp" "Parameter is an array" >&2
    return 4
  fi

  # passed by name: bb_explode var
  bbString="${!1}"

else
  # passed by value: bb_explode $var
  bbString="$1"

fi
# remove param 1
shift


## defaults for other params
bbTNT="default"
bbArrayName="BING_EXPLODED"


# assign params
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
      # user provided name for resulting array
      bbArrayName="$1"
      # check it is a valid identifier
      if [[ ! "$bbArrayName" =~ ^[[:alpha:]_][[:alnum:]_]*$ ]]; then
        printf "\e[2m%s: %s\e[0m\n" "$bbapp" "Invalid identifier" >&2
        return 6
      fi
    ;;
  esac
  shift
done

# echo "String: $bbString"
# echo "TNT: $bbTNT"
# echo "ArrayName: $bbArrayName"


#   ====================== DEFAULT DELIMITER ===================
if [[ "$bbTNT" == "default" ]]; then
	if [[ ! "$bbString" =~ ^[[:alpha:]]+$ ]]; then
	  case "$bbString" in
	     *:*) bbTNT=':';;
	    *\/*) bbTNT='/';;
	     *,*) bbTNT=',';;
	     *.*) bbTNT='.';;
	     *-*) bbTNT='-';;
	    *\;*) bbTNT=';';;
	     *|*) bbTNT='|';;
	   *\\t*) bbTNT='\\t';;
	   *\\v*) bbTNT='\\v';;
	   *\\n*) bbTNT='\\n';;
	   *\\r*) bbTNT='\\r';;
	       *) bbTNT=' ';;
	  esac
	  IFS="$bbTNT" read -a "$bbArrayName" <<< "$bbString"
	  return 0
	else
    # if string is all alpha, split by character
    bbTNT="nill"
	fi

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
