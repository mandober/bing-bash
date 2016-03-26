#!/bin/bash
#========================================================================
#: FILE: range
#: PATH: $BING_FUNC/bin/range
#: TYPE: function/executable
#:       Source this file to use it as a function called `bb_range'
#:       or execute this file as `range' if it's in the PATH.
#:
#: TIMING:
#:       When used as function (time bb_range 1-1000)
#:         real    0m0.020s
#:         user    0m0.031s
#:         sys     0m0.000s
#:       When executed (time range 1-1000)
#:         real    0m0.191s
#:         user    0m0.077s
#:         sys     0m0.108s
#:       
#: AUTHOR:
#:      bing-bash by mandober <zgag@yahoo.com>
#:      https://github.com/mandober/bing-bash
#:      za Ǆ - Use freely at own's risk
#:      25-Mar-2016 (last revision)
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: NAME: 
#:      bb_range (function)
#:      range (executable)
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
#:      # let range="1,3-7,9,12-16" than call it as:
#:      bb_range "$range"
#:      # or (by name):
#:      bb_range range
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: SYNOPSIS:
#:      bb_range [-s SEP] LIST
#:
#: OPTIONS:
#:      -s|--sep|--separator SEP <char>
#:      SEP is substring composed of single or muliple characters by
#:      which to separate the resulting numbers. Specify separator 
#:      after equal sign or as the next argument.
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
#:      3 - Invalid input
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
	  he final sequence. Final number sequence will be separated
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
      # passed by value
      bbRange="$1"
      # passed by name
      [[ ! "$bbRange" =~ [[:digit:]]+[,-]? ]] && bbRange="${!1}"
      [[ ! "$bbRange" =~ [[:digit:]]+[,-]? ]] && return 3
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
    bbMAX="${bbNum#*-}" # 110, check that both are integers:
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

# output result
printf "%s\n" "${bbSequence%$bbSep}"
return 0
}
# $BING_FUNC/bin/range

if [ "${BASH_SOURCE[0]}" != $0 ]; then
  export -f bb_range
  echo '$0: '$0
  echo 'BASH_SOURCE != $0'
  printf "%s\n" "${BASH_SOURCE[@]}"
  echo "App: $0"
else
  echo '$0: '$0
  echo 'BASH_SOURCE == $0'
  printf "%s\n" "${BASH_SOURCE[@]}"
  echo "App: $0"
  bb_range "$@"
  exit $?
fi