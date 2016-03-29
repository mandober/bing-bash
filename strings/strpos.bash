#!/bin/bash bingmsg
#=======================================================================
#: FILE: strpos
#: PATH: $BING_FUNC/strings/strpos.bash
#: TYPE: function
#:       shell:bash:mandober:bing-bash:function:bb_strpos
#:
#: AUTHOR:
#:      bing-bash by Ivan Ilic <ivanilic1975@gmail.com>
#:      https://github.com/mandober/bing-bash
#:      za Ǆ - Use freely at owns risk
#:      29-Mar-2016 (last revision)
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: NAME:
#:      bb_strpos
#:
#: BRIEF: 
#:      Find the position of the first occurrence 
#:      of a substring in a string.
#:
#: DESCRIPTION:
#:      Find the position of the first occurrence of a 
#:      substring NEEDLE in a string HAYSTACK.
#:      Case-sensitive by default.
#:      Use -i option for case-insensitive version.
#:
#: DEPENDENCIES:
#:      none
#:
#: EXAMPLE:
#:      bb_strpos c abcdefg       # outputs: 2 
#:      bb_strpos def abcdefg     # outputs: 3
#:      bb_strpos -i def abcDEFg  # outputs: 3
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: SYNOPSIS:
#:      bb_strpos [-i] NEEDLE HAYSTACK
#:
#: OPTIONS:
#:      -i <option>
#:      With -i option function peforms case-insensitive matching.
#:
#: PARAMETERS:
#:
#:      NEEDLE <substring>
#:      Substring NEEDLE is the string to serach for in HAYSTACK.
#:
#:      HAYSTACK <string>
#:      String HAYSTACK is the subject string.
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: STDOUT:
#:      Index of the first occurrence of a substring in a string.
#:      Indexing starts at 0 - the first char of a string has index 0.
#:
#: STDERR:
#:      Error messages.
#:
#: RETURN CODE:
#:      0  great success
#:      1  miserable failure
#:      2  Positional parameters empty
#:      9  Parameter empty
#=======================================================================

bb_strpos() {
#                                                                  ABOUT
#                                                                  =====
 local -r bbapp="${FUNCNAME[0]}"
 local -r bbnfo="[bing-bash] $bbapp v.0.0.1"
 local -r usage="USAGE: $bbapp [-i] NEEDLE HAYSTACK"

#                                                               PRECHECK
#                                                               ========
  if [[ $# -eq 0 || $# -gt 3 ]]; then
    printf "\e[2m%s: %s\e[0m\n" "$bbapp" "Parameter error" >&2
    printf "%s\n" "$usage" >&2
    return 9
  fi

#                                                                   HELP
#                                                                   ====
  [[ $1 =~ ^(-u|--usage)$ ]] && { printf "%s\n" "$usage"; return 0; }
  [[ $1 =~ ^(-v|--version)$ ]] && { printf "%s\n" "$bbnfo"; return 0; }
  [[ $1 =~ ^(-h|--help)$ ]] && {
	cat <<-EOFF
	$bbnfo
	  Find the position of the first occurrence of a substring in a string.
	$usage
	  DESCRIPTION:
	    Find the position of the first occurrence of a substring NEEDLE in 
	    a string HAYSTACK. Case-sensitive by default. Use -i option for 
	    case-insensitive version.
	OPTIONS:
	   -i                Case-insensitive matching.
	   -h, --help        Show program help.
	   -u, --usage       Show program usage.
	   -v, --version     Show program version.
	EOFF
	return 0
 }

#                                                                    SET
#                                                                    ===
 shopt -s extglob extquote; shopt -u nocasematch; set -o noglob
 trap "set +o noglob" RETURN ERR SIGHUP SIGINT SIGTERM

#                                                                 PARAMS
#                                                                 ======
if [[ -z "$1" ]]; then
	printf "\e[2m%s: %s\e[0m\n" "$bbapp" "Positional parameters empty" >&2
	return 2
fi

local bbOpt bbChar bbString bbLen bbLenOut bbStringOut

# ASSIGN PARAMS
while [[ -n "${1+def}" ]]; do
  case $1 in
    
    # option
    -i)
      bbOpt="$1"
    ;;

    # needle + haystack
    *)
      # passed by value
      bbChar="$1"
      bbString="$2"
      # passed by name
      declare -p "$1" &>/dev/null && bbChar="${!1}"
      declare -p "$2" &>/dev/null && bbString="${!2}"
      shift
    ;;
  esac
  shift
done

[[ "$bbOpt" == "-i" ]] && { bbChar="${bbChar,,}"; bbString="${bbString,,}"; }

[[ ! "$bbString" =~ "$bbChar" ]] && return 1
bbLen="${#bbString}"
bbLenChr="${#bbChar}"
bbStringOut="${bbString#*$bbChar}"
bbLenOut="${#bbStringOut}"

printf "%d" $(( bbLen - bbLenOut - bbLenChr ))

return 0
 
} # $BING_FUNC/strings/strpos.bash
