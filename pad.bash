#!/bin/bash bingmsg
#==================================================================
#: FILE: pad.bash
#: PATH: $BING_FUNC/strings/pad.bash
#: TYPE: function
#:
#: AUTHOR:
#:      bing-bash by Ivan Ilic <ivanilic1975@gmail.com>
#:      https://github.com/mandober/bing-bash
#:      za Ǆ - Use freely at owns risk
#:      2-Apr-2016 (last revision)
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: NAME: 
#:      bb_pad
#:
#: BRIEF:
#:      Pad a string.
#:
#: DESCRIPTION:
#:      Pad string STRING by appending char(s) PAD after each 
#:      character of the STRING. PAD defaults to space char. 
#:
#: DEPENDENCIES:
#:      none
#:
#: EXAMPLE:
#:      bb_pad -p ',' "abc"         # a,b,c
#:      bb_pad -p ',' -w '"' "abc"  # "a","b","c"
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: SYNOPSIS:
#:      bb_pad [-p PAD] STRING
#:
#: OPTIONS:
#:      -p, --pad <option> PAD <argument>
#:      With -p option padding is user supplied string PAD.
#:      The argument PAD to this option is mandatory:
#:      PAD <chars> <required> <argument>
#:        PAD is user supplied character or characters that will
#:        be inserted after each character of STRING.
#:        Specify padding char(s) after equal sign (e.g. -p=':')
#:        or as a following argument (e.g. -p $'\t').
#:
#: PARAMETERS:
#:
#:      STRING <string>
#:      String to pad, passed by name or by value.
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: ENVIRONMENT:
#:      
#:
#: STDOUT:
#:      Padded string.
#:
#: STDERR:
#:      Error messages.
#:
#: RETURN CODE:
#:      0  great success
#:      1  miserable failure
#:      2  Positional parameters empty
#==================================================================

bb_pad() {

#                                                                  ABOUT
#                                                                  =====
 local -r bbapp="${FUNCNAME[0]}"
 local -r bbnfo="[bing-bash] $bbapp v.0.0.1"
 local -r usage="USAGE: $bbapp [-p PAD] STRING"

#                                                               PRECHECK
#                                                               ========
  if [[ $# -eq 0 ]]; then
    printf "\e[2m%s: %s\e[0m\n" "$bbapp" "Parameter empty" >&2
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
	  Pattern matching helper functions.
	$usage
	  PROPERTY is one of the following:
	        alpha - check if string consist of alphabetic chars only

	OPTIONS:
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


#                                                                  PARAMS
#                                                                  ======
local bbPad bbWrap bbString bbLen bbNum 

# CHECK
if [[ -z "$1" ]]; then
  printf "\e[2m%s: %s\e[0m\n" "$bbapp" "Positional parameter empty" >&2
  return 2
fi

# defaults
bbPad="_"
bbWrap=""

# ASSIGN PARAMS
while [[ -n "${1+def}" ]]; do
  case $1 in
    # padding
    -p|--pad)
      bbPad="${2?}"
      shift
    ;;

    -p=*|--pad=*)
      bbPad="${1#*=}"
    ;;

    # wrap
    -w|--wrap)
      bbWrap="${2?}"
      shift
    ;;
    -w=*|--wrap=*)
      bbWrap="${1#*=}"
    ;;

    # string
    *)
      # passed by value or
      bbString="$1"
      # passed by name
      declare -p "$1" &>/dev/null && bbString="${!1}"
    ;;
  esac
  shift
done

echo "String: »$bbString«"
echo "Pad: »$bbPad«"
echo "Wrap: »${bbWrap}«"


bbLen="${#bbString}"
local bbStringOut=""

for (( bbNum=0; bbNum<$bbLen; bbNum++ )) {
  bbStringOut+="${bbWrap}${bbString:$bbNum:1}${bbWrap}${bbPad}"
}

bbStringOut="${bbStringOut%$bbPad}"
printf "%s\n" "$bbStringOut"

return 0

} # $BING_FUNC/strings/pad.bash
