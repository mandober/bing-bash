#==================================================================
#: FILE: typeof.bash
#: PATH: $BING_FUNC/typeof.bash
#: TYPE: function
#:
#: AUTHOR:
#:      bing-bash by mandober <zgag@yahoo.com>
#:      https://github.com/mandober/bing-bash
#:      za Ǆ - Use freely at owns risk
#:      8-Mar-2016 (last revision)
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: NAME:
#:      bb_typeof
#:
#: BRIEF:
#:      Variable typing and dumping.
#:
#: DESCRIPTION:
#:      Started as a function mostly used to pretty print array to the
#:      screen, but anything can be passed to this function and it'll
#:      return its type. Variables must be passed by name (without $)
#:      in which case its value and attributes will be shown. With -t
#:      option, only the type, as a single word is returned.
#:      (If this file is sourced, `typeof' function will be defined in the
#:      current shell environment and also exported (making it available
#:      in all environments). If this file is executed it will behave as
#:      any script: it will have its own separate environment and access
#:      to exported shell variables only).
#:
#: DEPENDENCIES:
#:      builtins: type
#:
#: EXAMPLE:
#:      typeof -t BASH_ALIASES   # outputs: `associative'
#:      typeof BASH_VERSINFO     # dumps array BASH_VERSINFO
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: SYNOPSIS:
#:      typeof [-t] NAME
#:      typeof NAME [-t]   # works too
#:
#: OPTIONS: 
#:      -t, --type
#:      Return the type, as a single word. 
#:
#: PARAMETERS:
#:      NAME <string>
#:      bare word, name, identifier, variable, array, anything.
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: STDOUT:
#:    * Outputs only the type of the parameter (with -t option )
#:    * Type, value and attributes of the parameter (if variable)
#:    * Help, usage, version (if explicitly requested)
#:
#: STDERR:
#:      Error messages.
#:
#: RETURN CODES:
#:      0  success
#:      2  Positional parameters error
#==================================================================

bb_typeof() {

### ABOUT
local -r bbapp="${FUNCNAME[0]}"
local -r bbnfo="[bing-bash] $bbapp v.0.47"
local -r usage="USAGE: $bbapp [-t] NAME"

### PRECHECK
if [[ $# -eq 0 || $# -gt 2 ]]; then
  printf "\e[2m%s: %s\e[0m\n" "$bbapp" "Positional parameters error" >&2
  return 2
fi

### HELP
[[ $1 =~ ^(-u|--usage)$ ]] && { printf "%s\n" "$usage"; return 0; }
[[ $1 =~ ^(-v|--version)$ ]] && { printf "%s\n" "$bbnfo"; return 0; }
[[ $1 =~ ^(-h|--help)$ ]] && {
	cat <<-EOFF
	$bbnfo
	  Variable typing and dumping.
	$usage
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

### SET
 shopt -s extglob 		# Enable extended regular expressions
 shopt -s extquote		# Enables $'' and $"" quoting
 shopt -u nocasematch 	# regexp case-sensitivity
 set -o noglob   		# Disable globbing (set -f). re-enable:
 trap "set +o noglob" RETURN ERR SIGHUP SIGINT SIGTERM


### PARAMS
local bbParamName 
local type=0

while [[ -n "${1}" ]]; do
  case $1 in
   -t|--type) type=1;;
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
[[ "$bbDeclare" ]] && { printf "$bbDeclare\n" && return 0; }


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
	if [[ $type -eq 1 ]]; then
		printf "unset\n"
	else
		printf "$bbParamName is not set\n"
	fi
	return 0
fi


## SET VAR
# At this point NAME is set (but might be null) variable or array. 
# Anyway, it must be listed in symbols table as `declare xx NAME ...'
# where xx are its attributes - get them from element1 after exploding
# this statement. 
bbDeclare=($bbDeclare)

## Scrutinize attributes
# Possible attributes a variable can have are a) type attributes (-aA),
# respectively: variable OR indexed array OR associative array; 
# b) casing attributes (ulc): uppercase OR lowercase OR title-case; and
# c) other attributes (inxrt): integer, reference, export, 
# read-only, trace

case ${bbDeclare[1]} in
#	=========================== INDEXED ARRAY =============================

 *a*)
	[[ $type -eq 1 ]] && { printf "indexed\n"; return 0; }

	local -n bbArrayRef="$bbParamName"
	local -i bbNum=1
	local bbK
	local bbKey bbCurr bbMax=0

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
	for bbK in "${!bbArrayRef[@]}"; do
	  printf "\e[2m%2d.\e[0m %7s: %-*s \e[2m%5s\e[0m\n" \
	  "${bbNum}" "[${bbK}]" $bbMax "${bbArrayRef[$bbK]}" "${#bbArrayRef[$bbK]}"
	  (( bbNum++ ))
	done

 ;;&


#	========================= ASSOCIATIVE ARRAY ===========================

 *A*)
	[[ $type -eq 1 ]] && { printf "associative\n"; return 0; }

	local -n bbArrayRef="$bbParamName"
	local -i bbNum=1
	local i
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
	for i in "${!bbArrayRef[@]}"; do
	  printf "\e[2m%2d.\e[0m %*s: %-*s \e[2m%5s\e[0m\n" \
	  "${bbNum}" $bbMaxK "[$i]" $bbMax "${bbArrayRef[$i]}" "${#bbArrayRef[$i]}"
	  (( bbNum++ ))
	done

 ;;&


#	================================= VAR =================================

 -[-linuxcrt]*)
		[[ $type -eq 1 ]] && { printf "variable\n"; return 0; }
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
