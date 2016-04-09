#!/bin/bash
#========================================================================
#: FILE: range.bash
#: PATH: $BING_FUNC/range.bash
#: TYPE: function
#:   NS: shell:bash:mandober:bing-bash:function:bb_range
#:  CAT: strings
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: AUTHOR:
#:      bing-bash by Ivan Ilic <ivanilic1975@gmail.com>
#:      https://github.com/mandober/bing-bash
#:      za Ǆ - Use freely at owns risk
#:      9-Apr-2016 (last revision)
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
#:      (12-22,21-15). Ranges are inclusive. Single values (2,5)
#:      will not generate anything, but they will be included in
#:      the final sequence. Final sequence will be separated with
#:      provided substring DIV or by <space> by default. If PRE
#:      is given each number will be prefixed by it. If SUF is 
#:      given each number will be suffixed by it. Base of the final
#:      numbers is determined by BASE option which can be 8, 10 or 16.
#:      If parameter is not supplied, random range is generated.
#:
#: DEPENDENCIES:
#:      none
#:
#: EXAMPLE:
#:      bb_range 1,3-5,9  # outputs: 1,3,4,5,9
#:      bb_range 161-162 -b16 -p'\xc2\x'  # outputs: \xc2\xA1 \xc2\xA2
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: SYNOPSIS:
#:      bb_range [-p PRE] [-s SUF] [-d DIV] [-b BASE] [-n STEP] LIST
#:
#: OPTIONS:
#:
#:     -p|--pre|--prefix PRE
#:      Specify prefix to each resulting number.
#:
#:     -s|--suf|--suffix SUF
#:      Specify suffix to each resulting number.
#:
#:     -d|--div|--diveder DIV
#:      Specify separator between resulting numbers.
#:
#:     -b|--base BASE
#:      Specify base for the resulting numbers.
#:      The base can be 8 (octal), 10 (decimal) or 16 (hexadecimal).
#:
#:     -n|--step STEP
#:      Specify a step between resulting numbers.
#:
#:      Argument to each option above can be specified in various ways:
#:      - separated by space or equal sign from its option
#:        e.g. --prefix X or --prefix=X
#:      - In case of short, single letter options, the argument can also 
#:        be given without any separator (e.g. -pX or -b16)
#:      Order of options and parameter is not important.
#:
#: PARAMETERS:
#:      LIST <string>
#:      Comma-separated list of integers or integer ranges.
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
#:      2 - Parameter empty
#:      3 - Invalid input
#:      4 - Not an integer
#:      5 - Unsupported base
#========================================================================
bb_range() {

#                                                                    ABOUT
#-------------------------------------------------------------------------
 local bbapp="${FUNCNAME[0]}"
 local bbnfo="[bing-bash] $bbapp v.0.12"
 local usage="USAGE: $bbapp [-p PRE] [-s SUF] [-d DIV] [-b BASE] [-n STEP] LIST"

#                                                                     HELP
#-------------------------------------------------------------------------
 [[ $1 =~ ^(-u|--usage)$ ]] && { printf "%s\n" "$usage"; return 0; }
 [[ $1 =~ ^(-v|--version)$ ]] && { printf "%s\n" "$bbnfo"; return 0; }
 [[ $1 =~ ^(-h|--help)$ ]] && {
  printf "\e[7m%s\e[0m\n" "$bbnfo"
  printf "\e[1m%s\e[0m\n" "$usage"
  cat <<-EOFF
	Generates numeric sequence.

	DESCRIPTION:
	  Generates numeric sequence from given list. List comprises
	  comma-separated ranges and/or integers (1,3-7,9-12,15).
	  Ranges are inclusive. Final sequence will be separated with
	  user supplied argument to -d option (<space> by default). 
	  Base of numbers in resulting sequence is determined by the
	  BASE argument, which can be 8, 10 or 16. If no parameter
	  supplied, random range is generated.

	OPTIONS:
	  -b, --base            Base of the resulting numbers.
	  -n, --step            Step between resulting numbers.
	  -p, --pre, --prefix   String by which to prefix each number.
	  -s, --suf, --suffix   String by which to suffix each number.
	  -d, --div, --divider  String by which to separate numbers.
	  -h, --help            Show program help.
	  -u, --usage           Show program usage.
	  -v, --version         Show program version.
	EXAMPLE:
	EOFF
	  printf "  bb_range 1,3-5,9-7   \e[2m# outputs: 1 3 4 5 9 8 7\e[0m\n"
	  printf "  bb_range 161-163 -b16 -px  \e[2m# outputs: xA1 xA2 xA3\e[0m\n"
	return 0
 }

#                                                                      SET
#-------------------------------------------------------------------------
 shopt -s extglob extquote; shopt -u nocasematch; set -o noglob
 trap "set +o noglob" RETURN ERR SIGHUP SIGINT SIGTERM


#                                                                   ASSIGN
#=========================================================================
local bbRange    # input range
local bbPre      # prefix to each number in result
local bbSuf      # suffix to each number in result
local bbDiv      # separator char between resulting sequence
local bbBase     # base of resulting numbers (8|10|16)
local bbStep     # step between numbers

while (( $# > 0 )); do
  case $1 in
    -d=*|--div=*|--divider=*) bbDiv="${1#*=}";;
          -d|--div|--divider) bbDiv="${2?}"; shift;;
                         -d*) bbDiv="${1#??}";;

     -p=*|--pre=*|--prefix=*) bbPre="${1#*=}";;
           -p|--pre|--prefix) bbPre="${2?}"; shift;;
                         -p*) bbPre="${1#??}";;

     -s=*|--suf=*|--suffix=*) bbSuf="${1#*=}";;
           -s|--suf|--suffix) bbSuf="${2?}"; shift;;
                         -s*) bbSuf="${1#??}";;

               -b=*|--base=*) bbBase="${1#*=}";;
                   -b|--base) bbBase="${2?}"; shift;;
                         -b*) bbBase="${1#??}";;

               -n=*|--step=*) bbStep="${1#*=}";;
                   -n|--step) bbStep="${2?}"; shift;;
                         -n*) bbStep="${1#??}";;

   --) shift; bbRange="$1"; set --;;
    *) bbRange="$1";;
  esac
shift
done


#                                                                   CHECKS
#=========================================================================

#                                        RANGE
#----------------------------------------------
if [[ -z "$bbRange" ]]; then
  local bbG=$RANDOM
  bbRange="${bbG: -4:1}-${bbG: -1:1},${bbG: -2:1}-${bbG: -3:1}"
else
  # passed by name?
  [[ ! "$bbRange" =~ ^[[:digit:]] ]] && bbRange="${!bbRange}"
fi

# check if valid range
[[ ! "$bbRange" =~ ^[[:digit:],-]+$ ]] && return 3

# check if single range
# [[ ! "$bbRange" =~ ^[[:digit:]]+-[[:digit:]]+$ ]] && return 3

#                                       DIVIDER
#----------------------------------------------
bbDiv="${bbDiv:- }"

#                                          BASE
#----------------------------------------------
bbBase="${bbBase:-10}"
if ((bbBase !=8)) && ((bbBase !=10)) && ((bbBase !=16)); then return 5; fi

#                                          STEP
#----------------------------------------------
bbStep="${bbStep:-1}"
[[ ! "$bbStep" =~ ^[[:digit:]]+$ ]] && return 3


# local
# return
# echo "bbDiv: $bbDiv"
# printf "Prefix: %q\n" "$bbPre"
# printf "Suffix:: %q\n" "$bbSuf:"
# echo "bbBase: $bbBase"
# echo "bbRange: $bbRange"

#                                                                  PROCESS
#=========================================================================
local bbMIN bbMAX bbArray bbNum
local bbSq=""

# explode list (1,5-8,10-15) by comma
IFS=, read -a bbArray <<< "$bbRange"

for bbNum in "${bbArray[@]}"; do
  # if element is a range (10-15)
  if [[ "$bbNum" =~ ^[[:digit:]]+-[[:digit:]]+$ ]]; then

#                                                          RANGE
# --------------------------------------------------------------

    bbMIN="${bbNum%-*}" # 10
    bbMAX="${bbNum#*-}" # 15
    
   if ((bbMIN < bbMAX)); then

#                               LOW-HI SEQUENCE
#----------------------------------------------
    while ((bbMIN <= bbMAX)); do
      if ((bbBase == 16)); then
        bbSq+="${bbPre}$(printf "%X" $bbMIN)${bbSuf}${bbDiv}" # hex
      elif ((bbBase == 8)); then
        bbSq+="${bbPre}$(printf "%o" $bbMIN)${bbSuf}${bbDiv}" # oct
      else
        bbSq+="${bbPre}${bbMIN}${bbSuf}${bbDiv}" # dec
      fi
      ((bbMIN += bbStep))
    done


   else # ¯\_(ツ)_/¯

#                               HI-LOW SEQUENCE
#----------------------------------------------
    while ((bbMIN >= bbMAX)); do
      if ((bbBase == 16)); then
        bbSq+="${bbPre}$(printf "%X" $bbMIN)${bbSuf}${bbDiv}" # hex
      elif ((bbBase == 8)); then
        bbSq+="${bbPre}$(printf "%o" $bbMIN)${bbSuf}${bbDiv}" # oct
      else
        bbSq+="${bbPre}${bbMIN}${bbSuf}${bbDiv}" # dec
      fi
      ((bbMIN -= bbStep))
    done
   fi # end min < max

#                                                  SINGLE NUMBER
# --------------------------------------------------------------
  else
    [[ ! "$bbNum" =~ ^[[:digit:]]+$ ]] && return 4
    # ...just add it to the sequence
    if ((bbBase == 16)); then
      bbSq+="${bbPre}$(printf "%X" $bbNum)${bbSuf}${bbDiv}" # hex
    elif ((bbBase == 8)); then
      bbSq+="${bbPre}$(printf "%o" $bbNum)${bbSuf}${bbDiv}" # oct
    else
      bbSq+="${bbPre}${bbNum}${bbSuf}${bbDiv}" # dec
    fi
  fi
done

bbSq="${bbSq%$bbDiv}"

#                                                                   OUTPUT
#=========================================================================
printf "%s" "$bbSq"
# printf "%b" "$bbSq"
return 0

}
# $BING_FUNC/range.bash
