#!/bin/bash bingmsg
#========================================================================
#: FILE: range.bash
#: PATH: $BING_FUNC/range.bash
#: TYPE: function
#:
#: AUTHOR:
#:      bing-bash by mandober <zgag@yahoo.com>
#:      https://github.com/mandober/bing-bash
#:      za Ǆ - Use freely at own's risk
#:      3-Mar-2016 (last revision)
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: NAME: 
#:      bb_range
#:
#: BRIEF:
#:      Generate number sequences from ranges list.
#:
#: DESCRIPTION:
#:      Generate sequences from given ranges list. List can be
#:      a single range (5-10) or a comma-separated list of ranges
#:      (12-22,30-35). Ranges are inclusive. Single values (2,5)
#:      will not generate anything, but they will be included in
#:      the final sequence. Final number sequence will be separated
#:      by provided substring SEP or by <space> if no SEP given.
#:
#: DEPENDENCIES:
#:      (none)
#:
#: EXAMPLE:
#:      bb_range 1,3-7,9,12-16
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: SYNOPSIS:
#:      bb_range [-s SEP] LIST
#:
#: OPTIONS:
#:      -s|--sep|--separator SEP
#:      SEP <char>
#:      Substring composed of single or muliple characters by which
#:      to separate the resulting numbers. Specify separator after 
#:      equal sign or as the next argument.
#:
#: PARAMETERS:
#:      LIST <string>
#:      Comma-separated list of integers or ranges.
#:    
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: STDOUT:
#:      Range of numbers.
#:
#: STDERR:
#:      Error messages.
#:    
#: RETURN CODE:
#:      0 - success
#:      1 - failure
#:      2 - Positional parameters empty
#:      3 - Wrong number of parameters
#:      4 - Not an integer
#========================================================================

bb_range() {
#                                                                   ABOUT
#                                                                   =====
 local -r bbapp="${FUNCNAME[0]}"
 local -r bbnfo="[bing-bash] $bbapp v.0.11"
 local -r usage="USAGE: $bbapp LIST"

#                                                                PRECHECK
#                                                                ========
  if [[ $# -eq 0 ]]; then
    printf "\e[2m%s: %s\e[0m\n" "$bbapp" "Wrong number of parameters" >&2
    printf "%s\n" "$usage" >&2
    return 3
  fi

#                                                                    HELP
#                                                                    ====
  [[ $1 =~ ^(-u|--usage)$ ]] && { printf "%s\n" "$usage"; return 0; }
  [[ $1 =~ ^(-v|--version)$ ]] && { printf "%s\n" "$bbnfo"; return 0; }
  [[ $1 =~ ^(-h|--help)$ ]] && {
	cat <<-EOFF
	$bbnfo
	  Generate number sequences from ranges list.
	$usage
  DESCRIPTION:
  	Generate sequences from given ranges list. List can be
    a single range (5-10) or a comma-separated list of ranges
    (12-22,30-35). Ranges are inclusive. Single values (2,5)
    will not generate anything, but they will be included in
    the final sequence. Final number sequence will be separated
    by provided substring SEP or by <space> if no SEP given.
	OPTIONS:
    -s, --sep       String by which to separate resulting numbers
	  -h, --help      Show program help.
	  -u, --usage     Show program usage.
	  -v, --version   Show program version.
	EOFF
	return 0
 }

#                                                                     SET
#                                                                     ===
 shopt -s extglob extquote; shopt -u nocasematch; set -o noglob
 trap "set +o noglob" RETURN ERR SIGHUP SIGINT SIGTERM

#                                                                  PARAMS
#                                                                  ======
local bbMIN bbMAX bbArray bbNum bbSep bbRange
local bbSequence=""

# assign params
while [[ "${1+def}" ]]; do
  case $1 in
   -s=*|--sep=*|--separator=*)
      bbSep="${1#*=}"
    ;;
   -s|--sep|--separator)
      bbSep="${2?}"
      shift
   ;;
   *)
    bbRange="$1"
   ;;
  esac
shift
done
# default separator
bbSep="${bbSep:- }"

#                                                                 PROCESS
#                                                                 =======
# explode list (5-8,100-110) by comma
IFS=, read -a bbArray <<< "$bbRange"

for bbNum in "${bbArray[@]}"; do
  # if element is a range (100-110)
  if [[ "$bbNum" =~ [[:digit:]]+-[[:digit:]]+ ]]; then
    bbMIN="${bbNum%-*}" # 100
    bbMAX="${bbNum#*-}" # 110
    # check that both are integers
    [[ ! "$bbMIN" =~ ^[[:digit:]]+$ ]] && return 4
    [[ ! "$bbMAX" =~ ^[[:digit:]]+$ ]] && return 4
    # generate seq
    while [[ $bbMIN -le $bbMAX ]]; do
      bbSequence+="${bbMIN}${bbSep}"
      (( bbMIN++ ))
    done
  # if element is a single number...
  else
    [[ ! "$bbNum" =~ ^[[:digit:]]+$ ]] && return 4
    # ...just add it to the sequence
    bbSequence+="${bbNum}${bbSep}"
  fi
done

bbSequence="${bbSequence%$bbSep}"
printf "%s\n" "$bbSequence"
return 0
}
