#!/bin/bash sourceme
#                                                                       ID
#-------------------------------------------------------------------------
#    FILE: $BING/func/typeof.bash
#    TYPE: function
#     CAT: helpers
#      NS: shell:bash:mandober:bing-bash:bb_typeof
#                                                                  PROJECT
#-------------------------------------------------------------------------
#   TITLE: bing-bash - Bash Functions Library
#  AUTHOR: Ivan Ilic <ivanilic1975@gmail.com>
#    SITE: https://github.com/mandober/bing-bash
# LICENSE: GPLv3
#    DATE: 12-May-2016 (latest revision)
#                                                                  DETAILS
#-------------------------------------------------------------------------
#  NAME:
#       bb_typeof - Variables typing and dumping
# 
#  SYNOPSIS:
#       bb_typeof [-t] NAME ...
# 
#  DESCRIPTION:
#       Started as a function mostly used to pretty dump array to the
#       screen, became a function to type and qualify names passes to
#       it. Still, when used with variable gives info about it such as
#       its value and attributes. Variable are passed by name (no $).
#       With -t option, only the type, as a single word is returned.
#       Types returned are: unset variable, variable, indexed array,
#       associative array; also the types returned by `type` builin:
#       alias, keyword, function, builtin or file.
# 
#  OPTIONS:
#       -t, --type <flag>
#       Return the type, as single word. 
# 
#  OPERANDS:
#       NAME <string>
#       bare word, name, identifier, variable, array, etc.
#                                                                   OUTPUT
#-------------------------------------------------------------------------
#  STDOUT:
#       Type, value and attributes of the parameter.
#       With -t option prints type as a single word.
# 
#  STDERR:
#       Error messages.
# 
#  ENVIRONMENT:
#       none
#
#  RETURN CODE:
#       0  success
#       1  failure
#       2  Parameter empty
#                                                                     INFO
#-------------------------------------------------------------------------
#  DEPENDENCIES:
#       none
#
#  SEE ALSO:
#       type (builtin)
#
#  NOTES:
#       Best used when sourced. It can be executed as well, but in
#       that case it will run in its own, separate, environment, so
#       current environment varables won't be available unless exported
#       (and arrays can't be exported).
#
#  EXAMPLES:
#       bb_typeof -t BASH_ALIASES              # outputs: `associative'
#       bb_typeof BASH_VERSINFO                # dumps array BASH_VERSINFO
#       bb_typeof PATH SHELLOPTS BASHOPTS LS_COLORS
# 
#=========================================================================
bb_typeof() {
#                                                                    ABOUT
#-------------------------------------------------------------------------
 local bbapp="${FUNCNAME[0]}"
 local bbnfo="[bing-bash] $bbapp v.0.53"
 local usage="USAGE: $bbapp [-t] NAME ..."

#                                                                 PRECHECK
#-------------------------------------------------------------------------
 if (($#==0)); then
    printf "\e[2m%s: %s\e[0m\n" "$bbapp" "Positional parameter empty" >&2
    printf "%s\n" "$usage" >&2
    return 2
 fi

#                                                                     HELP
#-------------------------------------------------------------------------
 [[ $1 =~ ^(-u|--usage)$ ]] && { printf "%s\n" "$usage"; return 0; }
 [[ $1 =~ ^(-v|--version)$ ]] && { printf "%s\n" "$bbnfo"; return 0; }
 [[ $1 =~ ^(-h|--help)$ ]] && {
  printf "\e[7m%s\e[0m\n" "$bbnfo"
  printf "\e[1m%s\e[0m\n" "$usage"
  cat <<-EOFF
	Variable typing and dumping.
	
	DESCRIPTION:
	  Pass an identifier (without \$), name or word NAME to 
	  check its type and dump its value and attributes. 
	  With -t option, only the type, as a single word, is 
	  returned. Returned types are:
	   - 'unset' - for unset variables
	   - 'associative' - for associative arrays
	   - 'indexed' - for indexed arrays
	   - 'variable' - for set varables
	   or: 'alias', 'keyword', 'function', 'builtin' or 'file'
	   as reported by the 'type' builtin.

	OPTIONS:
	   -t, --type        Return type as a single word.
	   -h, --help        Show program help.
	   -u, --usage       Show program usage.
	   -v, --version     Show program version.

	EXAMPLES:
	   $bbapp -t BASH_ALIASES
	   $bbapp BASH_VERSINFO
	   $bbapp PATH SHELLOPTS BASHOPTS LS_COLORS
	EOFF
	return 0
 }

#                                                                      SET
#-------------------------------------------------------------------------
 shopt -s extglob         # Enable extended regular expressions
 shopt -s extquote        # Enables $'' and $"" quoting
 shopt -u nocasematch     # regexp case-sensitivity
 set -o noglob            # Disable globbing (set -f).
 trap "set +o noglob" RETURN ERR SIGHUP SIGINT SIGTERM


#                                                                   ASSIGN
#=========================================================================
local bbIn=""       # input param
local bbType=0      # Type flag: 0=extensive 1=single word output

while (( $# > 0 )); do
  case $1 in

    -t|--type) bbType=1; shift;;

    --) shift; bbIn+="$@"; set --;;

    -*)
        # test getopt version
        getopt -T
        (($? != 4)) && {
          cat <<-EOFF >&2
					Your version of getopt cannot be used to normalize the suplied
					options. Please try again, but supply normalized options: no
					componded short options and no abbreviated long options.
					EOFF
          return 7
        }

        local bbGetopt=$(getopt -quo -v:t -l verbose:,type -- "$@")
        # echo "\"$bbGetopt\""
        bbGetopt="${bbGetopt# }"
        bbGetopt="${bbGetopt// -- / }"
        bbGetopt="${bbGetopt/% --/}"
        # echo "\"$bbGetopt\""
        eval set -- "$bbGetopt"
    ;;

    *) bbIn+="$1 "; shift;;
  esac
done


#                                         DEFAULTS
# ------------------------------------------------
bbIn="${bbIn% }"

# return operands to $@
eval set -- "$bbIn"
bbIn=""

#                                                                  PROCESS
#=========================================================================
# list opernads
for bbIn; do

#                                                             TYPE BUILTIN
#=========================================================================
# As a convenience, first check NAME with bash's `type -t` builtin.
# This will type NAME as: alias, keyword, function, builtin, file.
# If `type` does return something, print it and return.
local bbDeclare
bbDeclare="$(type -t "$bbIn" 2>/dev/null)"

if [[ -n "$bbDeclare" ]]; then
    if (( bbType == 1 )); then
      printf "%s\n" "$bbDeclare"
    else
      printf " \e[2m%s\e[0m %s\n" "Name:" "$bbIn"
      printf " \e[2m%s\e[0m %s\n" "Type:" "$bbDeclare"
    fi

else
  #                                                              UNSET VAR
  #=======================================================================
  # In order to assume the NAME is a variable (whether set or not),
  # first check if NAME is a valid shell identifier. If `set -o nounset'
  # is not enabled, all non-set variables are in fact treated as undefined 
  # variables when referenced - variables with null value. Of course, they
  # are not in symbols table, so check there to identify them. 
  # Return `unset' if they are not there.

  # assign `decalare -p NAME' to bbDeclare. 
  # If assignment is empty then NAME is unset (non-set) variable.
  if ! bbDeclare="$(declare -p "$bbIn" 2>/dev/null)"; then
    if (( bbType == 1 )); then
      printf "%s\n" "unset"
    else
      printf " \e[2m%s\e[0m %s\n" "Name:" "$bbIn"
      printf " \e[2m%s\e[0m %s\n" "Type:" "unset"
    fi
  fi

fi

#                                               VARIABLE - SCALAR OR ARRAY
#=========================================================================
# At this point NAME is set (but might be null) variable:
# whether scalar or array, it is in symbols table nonetheless.
bbDeclare=( $bbDeclare )
## Scrutinize attributes
# Possible attributes for var: 
#  a) type attributes    (-aA): var OR indexed OR assoc. array.
#  b) casing attributes  (ulc): uppercase, lowercase, title-case.
#  c) other attributes (inxrt): integer, ref, export, readonly, trace.


case ${bbDeclare[1]} in
#                                                            INDEXED ARRAY
#=========================================================================
 *a*)
  (( bbType == 1 )) && { printf "%s\n" "indexed"; continue; }

  local bbKey bbCurr
  local -n bbArrayRef="$bbIn"
  local -i bbNum=1
  local bbMax=0

  # max (in chars) value
  for bbKey in "${!bbArrayRef[@]}"; do
    bbCurr=${#bbArrayRef[$bbKey]}
    bbMax=$(( bbCurr > bbMax ? bbCurr : bbMax ))
  done

  printf " \e[2m%s\e[0m %s\n" "Name:" "$bbIn"
  printf " \e[2m%s\e[0m " "Type:"
  printf "indexed array [%s]\n" "${#bbArrayRef[@]}"

  # title
  printf "\e[2m%s. %7s %-*s %5s\e[0m\n" \
  " no" "key " $bbMax "value" "len"

  # value
  local bbK
  for bbK in "${!bbArrayRef[@]}"; do
    printf "\e[2m%2d.\e[0m %7s: %-*s \e[2m%5s\e[0m\n" \
    "${bbNum}" "[${bbK}]" $bbMax \
    "${bbArrayRef[$bbK]}" "${#bbArrayRef[$bbK]}"
    (( ++bbNum ))
  done
  printf "\n"
 ;;&

#                                                        ASSOCIATIVE ARRAY
#=========================================================================
 *A*)
  (( bbType == 1 )) && { printf "%s\n" "associative"; continue; }

  local -n bbArrayRef="$bbIn"
  local -i bbNum=1
  local bbKey bbCurr bbMax=0 bbCurrKey bbMaxK=0

  # max (in chars) value and kay
  for bbKey in "${!bbArrayRef[@]}"; do
    bbCurr=${#bbArrayRef[$bbKey]}
    bbMax=$(( bbCurr > bbMax ? bbCurr : bbMax ))
    bbCurrKey=${#bbKey}
    bbMaxK=$(( bbCurrKey > bbMaxK ? bbCurrKey : bbMaxK ))
  done
  (( bbMaxK += 2 ))

  printf " \e[2m%s\e[0m %s\n" "Name:" "$bbIn"
  printf " \e[2m%s\e[0m " "Type:"
  printf "associative array %s\n" "[${#bbArrayRef[@]}]"

  # title
  printf "\e[2m%s. %*s %-*s %5s\e[0m\n" \
    " no" $bbMaxK "key " $bbMax "value" "len"

  # value
  local bbK
  for bbK in "${!bbArrayRef[@]}"; do
    printf "\e[2m%2d.\e[0m %*s: %-*s \e[2m%5s\e[0m\n" \
    "${bbNum}" $bbMaxK "[$bbK]" $bbMax \
    "${bbArrayRef[$bbK]}" "${#bbArrayRef[$bbK]}"
    (( ++bbNum ))
  done
  printf "\n"
 ;;&

#                                                              SCALAR VARS
#=========================================================================
# if 1. attribute was (-) than var is scalar
 -[-linuxcrt]*)
    # if --type, output single word type
    (( bbType == 1 )) && { printf "%s\n" "variable"; continue; }
    
    # otherwise output name, type and value
    local bbValue="${!bbIn}"
      printf " \e[2m%s\e[0m %s\n" "Name:" "$bbIn"
    if [[ $bbValue =~ : ]]; then 
      printf " \e[2m%s\e[0m %s\n" "Type:"  "variable (colon separated values)"
      printf "\e[2m%s\e[0m\n" "Value:"
      printf "       %s\n" ${bbValue//:/ }
    else
      printf " \e[2m%s\e[0m %s\n" "Type:" "variable"
      printf "Value: %s \e[2m[%s]\e[0m\n" "$bbValue" "${#bbValue}"
    fi
 ;;&

#                                                               ATTRIBUTES
#=========================================================================
# remaining attributes
 *[linuxcrt]*) printf "Attributes:\n";;&
  *i*) printf "integer "      ;;&
  *r*) printf "readonly "     ;;&
  *x*) printf "export "       ;;&
  *l*) printf "lowercasing "  ;;&
  *c*) printf "capitalizing " ;;&
  *u*) printf "uppercasing "  ;;&
  *n*) printf "reference "    ;;&
  *t*) printf "trace "        ;;&
  *[linuxcrt]*) printf "\n";;
esac
printf "\n"


done # end list opernads


return 0
}
# $BING_FUNC/typeof.bash
