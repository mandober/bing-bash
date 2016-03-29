#!/bin/bash bingmsg
#=======================================================================
#: FILE: typeof.bash
#: PATH: $BING_FUNC/typeof.bash
#: TYPE: function
#:       shell:bash:mandober:bing-bash:function:bb_typeof
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
#:      bb_typeof
#:
#: BRIEF:
#:      Variable typing and dumping.
#:
#: DESCRIPTION:
#:      Started as a function mostly used to pretty dump array to the
#:      screen, became a function to type and qualify names passes to
#:      it. Still, when used with variable gives info about it such as
#:      its value and attributes. Variable are passed by name (no $),
#:      With -t option, only the type, as a single word is returned.
#:      * Types returned are: unset variable, variable, indexed array,
#:        associative array; also the types returned by `type' builin:
#:        alias, keyword, function, builtin or file.
#:
#: DEPENDENCIES:
#:      Bash builtins: type
#:
#: EXAMPLE:
#:      bb_typeof -t BASH_ALIASES   # outputs: `associative'
#:      bb_typeof BASH_VERSINFO     # dumps array BASH_VERSINFO
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: SYNOPSIS:
#:      bb_typeof [-t] NAME
#:      bb_typeof NAME [-t]
#:
#: OPTIONS:
#:      -t, --type <option>
#:      Return the type, as single word. 
#:
#: PARAMETERS:
#:      NAME <string>
#:      bare word, name, identifier, variable, array, etc.
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
#: STDOUT:
#:      Type, value and attributes of the parameter.
#:      With -t option prints type as a single word.
#:
#: STDERR:
#:      Error messages.
#:
#: RETURN CODES:
#:      0  great success
#:      1  miserable failure
#:      9  Parameter empty
#=======================================================================

bb_typeof() {
#                                                                  ABOUT
#                                                                  =====
 local bbapp="${FUNCNAME[0]}"
 local bbnfo="[bing-bash] $bbapp v.0.50"
 local usage="USAGE: $bbapp [-t] NAME"

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
	printf "\e[7m%s\e[0m\n" "$bbnfo"
	printf "\e[1m%s\e[0m\n" "$usage"
	cat <<-EOFF
	Variable typing and dumping.
	
	DESCRIPTION:
	  Pass identifier's NAME (without \$) to check its type and 
	  dump its value and attributes. With -t option, only the 
	  type, as a single word, is returned. Returned types are:
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
	   $bbapp BASH_ALIASES
	   $bbapp BASH_VERSINFO
	EOFF
	return 0
 }

#                                                                    SET
#                                                                    ===
 shopt -s extglob 		# Enable extended regular expressions
 shopt -s extquote		# Enables $'' and $"" quoting
 shopt -u nocasematch 	# regexp case-sensitivity
 set -o noglob   		# Disable globbing (set -f). re-enable:
 trap "set +o noglob" RETURN ERR SIGHUP SIGINT SIGTERM


#                                                                 PARAMS
#                                                                 ======
local bbParamName
local tonly=0

while [[ "${1+def}" ]]; do
  case $1 in
    -t|--type) tonly=1;;
    *) bbParamName="$1";;
  esac
  shift
done

### MAIN

## TYPE BUILTIN
# As a convenience, first check NAME with bash's `type -t' builtin. This will
# type NAME as: alias, keyword, function, builtin, file. If `type' does return
# something, print it and return.

local bbDeclare
bbDeclare="$(type -t "$bbParamName" 2>/dev/null)"
[[ -n "$bbDeclare" ]] && { printf "%s\n" "$bbDeclare"; return 0; }


## UNSET VAR
# In order to assume the NAME is a variable (whether set or not),
# first check if NAME is a valid shell identifier. If `set -o nounset'
# is not enabled, all non-set variables are in fact treated as undefined 
# variables when referenced - variables with null value. Of course, they
# are not in symbols table, so check there to identify them. 
# Return `unset' if they are not there.

# assign `decalare -p NAME' to bbDeclare. 
# If assignment is empty then NAME is unset (non-set) variable.
if ! bbDeclare="$(declare -p "$bbParamName" 2>/dev/null)"; then
  if [[ $tonly -eq 1 ]]; then
    printf "%s\n" "unset"
  else
    printf "%s is not set\n" "$bbParamName"
  fi
  return 0
fi


## SET VAR
# At this point NAME is set (but might be null) variable or array. 
# Anyway, it must be listed in symbols table as `declare xx NAME ...'
# where xx are its attributes - get them from element1 after exploding
# this statement. 
bbDeclare=( $bbDeclare )

## Scrutinize attributes
# Possible attributes a variable can have are a) type attributes (-aA),
# respectively: variable OR indexed array OR associative array; 
# b) casing attributes (ulc): uppercase OR lowercase OR title-case; and
# c) other attributes (inxrt): integer, reference, export, 
# read-only, trace

case ${bbDeclare[1]} in
#	=========================== INDEXED ARRAY =============================

 *a*)
  [[ $tonly -eq 1 ]] && { printf "%s\n" "indexed"; return 0; }

  local bbKey bbCurr
  local -n bbArrayRef="$bbParamName"
  local -i bbNum=1
  local bbMax=0

  # max (in chars) value
  for bbKey in "${!bbArrayRef[@]}"; do
    bbCurr=${#bbArrayRef[$bbKey]}
    bbMax=$(( bbCurr > bbMax ? bbCurr : bbMax ))
  done

  printf " Name: %s\n" "$bbParamName"
  printf " Type: indexed array [%s]\n" "${#bbArrayRef[@]}"

  # title
  printf "\e[2m%s. %7s %-*s %5s\e[0m\n" " no" "key " $bbMax "value" "len"

  # value
  local bbK
  for bbK in "${!bbArrayRef[@]}"; do
    printf "\e[2m%2d.\e[0m %7s: %-*s \e[2m%5s\e[0m\n" \
    "${bbNum}" "[${bbK}]" $bbMax "${bbArrayRef[$bbK]}" "${#bbArrayRef[$bbK]}"
    (( ++bbNum ))
  done
 ;;&


#	========================= ASSOCIATIVE ARRAY ===========================

 *A*)
	[[ $tonly -eq 1 ]] && { printf "%s\n" "associative"; return 0; }

	local -n bbArrayRef="$bbParamName"
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

	printf "Name: %s\n" "$bbParamName"
	printf "Type: associative array %s\n" "[${#bbArrayRef[@]}]"

	# title
	printf "\e[2m%s. %*s %-*s %5s\e[0m\n" \
	  " no" $bbMaxK "key " $bbMax "value" "len"
	
	# value
	local bbK
	for bbK in "${!bbArrayRef[@]}"; do
	  printf "\e[2m%2d.\e[0m %*s: %-*s \e[2m%5s\e[0m\n" \
	  "${bbNum}" $bbMaxK "[$bbK]" $bbMax "${bbArrayRef[$bbK]}" "${#bbArrayRef[$bbK]}"
	  (( ++bbNum ))
	done

 ;;&


#	================================= VAR =================================

 -[-linuxcrt]*)
		[[ $tonly -eq 1 ]] && { printf "%s\n" "variable"; return 0; }

		local bbValue="${!bbParamName}"
		printf " Name: %s\n" "$bbParamName"
		printf " Type: variable\n"
		printf "Value: %s \e[2m[%s]\e[0m\n" "$bbValue" "${#bbValue}"
 ;;&


#	============================= ATTRIBUTES ==============================

 *[linuxcrt]*) printf "Attributes: "  ;;&
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

return 0

}
# $BING_FUNC/typeof.bash
