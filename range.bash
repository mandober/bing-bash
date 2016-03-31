#!/bin/bash
#========================================================================
#: FILE: range.bash
#: PATH: $BING_FUNC/range.bash
#: TYPE: function
#:       shell:bash:mandober:bing-bash:function:bb_range
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: AUTHOR:
#:      bing-bash by Ivan Ilic <ivanilic1975@gmail.com>
#:      https://github.com/mandober/bing-bash
#:      za Ǆ - Use freely at owns risk
#:      25-Mar-2016 (last revision)
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
#:      the final sequence. Final sequence will be separated with
#:      provided substring DIV or by <space> by default. If PRE
#:      is given each number will be prefixed by it. If SUF is 
#:      given each number will be suffixed by it. Base of the final
#:      numbers is determined by BASE option which can be 8, 10 or 16.
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
#:      bb_range [-p PRE] [-s SUF] [-d DIV] [-b BASE] LIST
#:      bb_range [-pPRE] [-sSUF] [-dDIV] [-bBASE] LIST
#:
#: OPTIONS:
#:
#:     -p|--pre|--prefix <option> PRE <argument>
#:      With -p option user can specify PRE char(s) that will be
#:      used to prefix each resulting number.
#:
#:     -s|--suf|--suffix <option> SUF <argument>
#:      With -s option user can specify SUF char(s) that will be
#:      used to suffix each resulting number.
#:
#:     -d|--div|--diveder <option> DIV <argument>
#:      With -d option user can specify DIV char(s) that will be
#:      used to separate resulting numbers. 
#:
#:     -b|--base <option> BASE <argument>
#:      With -b option user can specify base for the resulting numbers.
#:      The base can be 8 (octal), 10 (decimal) or 16 (hexadecimal).
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
#                                                                   ABOUT
#                                                                   =====
 local bbapp="${FUNCNAME[0]}"
 local bbnfo="[bing-bash] $bbapp v.0.12"
 local usage="USAGE: $bbapp [-p PRE] [-s SUF] [-d DIV] [-b BASE] LIST
       $bbapp [-pPRE] [-sSUF] [-dDIV] [-bBASE] LIST"

#                                                                PRECHECK
#                                                                ========
  if [[ $# -eq 0 ]]; then
    printf "\e[2m%s: %s\e[0m\n" "$bbapp" "Parameter empty" >&2
    printf "%s\n" "$usage" >&2
    return 2
  fi

#                                                                    HELP
#                                                                    ====
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
	  user supplied string DIV or with a <space> by default. 
	  If PRE string is given each number will be prefixed by it.
	  If SUF string is given each number will be suffixed by it. 
	  Base of the numbers in generated sequence is determined by
	  BASE argument, which can be 8, 10 or 16.
	OPTIONS:
	  -b, --base            Base of the resulting numbers.
	  -p, --pre, --prefix   String by which to prefix each number.
	  -s, --suf, --suffix   String by which to suffix each number.
	  -d, --div, --divider  String by which to separate numbers.
	  -h, --help            Show program help.
	  -u, --usage           Show program usage.
	  -v, --version         Show program version.
	EXAMPLE:
	EOFF
	  printf "  bb_range 1,3-5,9           \e[2m# outputs: 1,3,4,5,9\e[0m\n"
	  printf "  bb_range 161-163 -b16 -px  \e[2m# outputs: xA1 xA2 xA3\e[0m\n"
	return 0
 }

#                                                                     SET
#                                                                     ===
 shopt -s extglob extquote; shopt -u nocasematch; set -o noglob
 trap "set +o noglob" RETURN ERR SIGHUP SIGINT SIGTERM

#                                                                  PARAMS
#                                                                  ======
local bbDiv bbPrefix bbSuffix bbBase bbRange 

# assign params
while [[ "${1+def}" ]]; do
  case $1 in
      -d=*|--div=*|--divider=*) bbDiv="${1#*=}";;
            -d|--div|--divider) bbDiv="${2?}"; shift;;
                           -d*) bbDiv="${1#??}";;

       -p=*|--pre=*|--prefix=*) bbPrefix="${1#*=}";;
             -p|--pre|--prefix) bbPrefix="${2?}"; shift;;
                           -p*) bbPrefix="${1#??}";;

       -s=*|--suf=*|--suffix=*) bbSuffix="${1#*=}";;
             -s|--suf|--suffix) bbSuffix="${2?}"; shift;;
                           -s*) bbSuffix="${1#??}";;

                 -b=*|--base=*) bbBase="${1#*=}";;
                     -b|--base) bbBase="${2?}"; shift;;
                           -b*) bbBase="${1#??}";;
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

# defaults
bbDiv="${bbDiv:- }"
bbBase="${bbBase:-10}"
if ((bbBase !=8)) && ((bbBase !=10)) && ((bbBase !=16)); then return 5; fi

echo "bbDiv: $bbDiv"
echo "bbPrefix: $bbPrefix"
echo "bbSuffix: $bbSuffix"
echo "bbBase: $bbBase"
echo "bbRange: $bbRange"

#                                                                 PROCESS
#                                                                 =======
local bbMIN bbMAX bbArray bbNum
local bbSequence=""

# explode list (1,5-8,100-110) by comma
IFS=, read -a bbArray <<< "$bbRange"

for bbNum in "${bbArray[@]}"; do
  # if element is a range (100-110)
  if [[ "$bbNum" =~ [[:digit:]]+-[[:digit:]]+ ]]; then
    
    bbMIN="${bbNum%-*}" # 100
    bbMAX="${bbNum#*-}" # 110
    
    # GENERATE SEQUENCE
    while [[ $bbMIN -le $bbMAX ]]; do
      if ((bbBase == 16)); then
        bbSequence+="${bbPrefix}$(printf "%X" $bbMIN)${bbSuffix}${bbDiv}" # hex
      elif ((bbBase == 8)); then
        bbSequence+="${bbPrefix}$(printf "%o" $bbMIN)${bbSuffix}${bbDiv}" # oct
      else
        bbSequence+="${bbPrefix}${bbMIN}${bbSuffix}${bbDiv}" # dec
      fi
      (( bbMIN++ ))
    done

  # if element is a single number...
  else
    [[ ! "$bbNum" =~ ^[[:digit:]]+$ ]] && return 4
    # ...just add it to the sequence
      if ((bbBase == 16)); then
      bbSequence+="${bbPrefix}$(printf "%X" $bbNum)${bbSuffix}${bbDiv}" # hex
      elif ((bbBase == 8)); then
        bbSequence+="${bbPrefix}$(printf "%o" $bbNum)${bbSuffix}${bbDiv}" # oct
    else
      bbSequence+="${bbPrefix}${bbNum}${bbSuffix}${bbDiv}" # dec
    fi

  fi
done

# output result
printf "%s\n" "${bbSequence%$bbDiv}"
printf "%b\n" "${bbSequence%$bbDiv}"
return 0

}
# $BING_FUNC/range.bash
