#!/bin/bash bingmsg
#==================================================================
#: FILE: bb
#: PATH: $BING/func/bb
#: TYPE: function
#:
#: AUTHOR:
#:      bing-bash by mandober <zgag@yahoo.com>
#:      https://github.com/mandober/bing-bash
#:      za Ǆ - Use freely at owns risk
#:      3-Mar-2016 (last revision)
#:
#: NAME: 
#:      bb
#:
#: DESCRIPTION:
#:      Functions dispatcher.
#:
#: DEPENDENCIES:
#:      -
#:
#: EXAMPLE:
#:      
#:
#: SYNOPSIS:
#:      
#:
#: OPTIONS: 
#:      
#:
#: PARAMETERS:
#:      
#:
#: STDOUT:
#:      
#:
#: STDERR:
#:      Error messages
#:
#: RETURN CODE:
#:		0  (no errors)
#:	    55 Positional parameters error
#==================================================================

bb () {

### ABOUT
local bbapp="${FUNCNAME[0]}"
local bbnfo="[bing-bash] $bbapp v.0.13"
local usage="USAGE: $bbapp FUNCTION"

### CHECKS
[[ $# -eq 0 ]] && { bb_err 51; printf "${usage}\n" >&2; return 51; }

### HUV
[[ $1 =~ ^(--usage)$ ]] && { printf "${usage}\n"; return 0; }
[[ $1 =~ ^(--version)$ ]] && { printf "${usage}\n"; return 0; }
[[ $1 =~ ^(--help)$ ]] && {
	cat <<-EOFF
	$bbnfo
	  Functions dispatcher. Sourcing and calling functions.
	$usage
	OPTIONS:
	   -h, --help        Show program help.
	   -u, --usage       Show program usage.
	   -v, --version     Show program version.
	EOFF
	return 0
}

### SET
 shopt -s extglob 		# Enable extended regular expressions
 shopt -s extquote		# Enables $'' and $"" quoting
 shopt -u nocasematch 	# regexp case-sensitivity
 set -o noglob			# Disable globbing. Enable it upon return:
 trap "set +o noglob" RETURN ERR SIGHUP SIGINT SIGTERM


### PARAMS


bbTemp="$(bb_get --attr "$bbArrayName")"
[[ "$bbTemp" =~ ^A[[:alpha:]]*$ ]] && { echo -n "associative" && return 0; }
[[ "$bbTemp" =~ ^a[[:alpha:]]*$ ]] && { echo -n "indexed" && return 0; }



local bbMethod bbVarName bbVarValue

if [[ "${1}" =~ ^[[:alpha:]_][[:alnum:]_]*\.[[:alpha:]]+$ ]]; then
	# Case #1: quasi methods, dot operator
	# bb VAR.METHOD
	# e.g. bb var.trim
	# Part before dot is, identifier i.e. variable's name (without $).
	# Part after is one of the supported methods (so only alpha chars allowed).
	bbMethod="${1#*.}"
	bbVarName="${1%.*}"
	# Get var's value. First, check if var is set 
	[[ -z "$(declare -p "${bbVarName}" 2>/dev/null)" ]] && return 60
	bbVarValue="${!bbVarName}"
	shift
	#@TODO: chaining
	# e.g. bb var.trim.bb_explode

else
	# Case #2: argument to method
	# bb METHOD VAR
	# e.g. bb trim var, bb trim "$var", bb trim " abc   \t def "
	# In this form, variable is passed as argument to a method and it can be
	# passed by name (without $) or by value (with $). 
	# The following procedure will first assume that variable is passed by name
	# and it will check for existance of variable by that name. If found, the
	# variable's value is retieved. If not, the variable itself is considered 
	# value (a string) to be acted upon.
	bbMethod="${1}"
	bbVarName="${2}"
	if [[ -z "$(declare -p "${bbVarName}" 2>/dev/null)" ]]; then
		bbVarValue="${bbVarName}"
	else
		bbVarValue="${!bbVarName}"
	fi
	shift 2
fi



echo "bbMethod: $bbMethod"
echo "bbVarName: $bbVarName"
echo "bbVarValue: $bbVarValue"
echo "Rest: $@"


# case $bbMethod in
#   typeof) bb_load1 typeof; typeof "$bbVarName" "$@";;
#  bb_explode) bb_load1 bb_explode "$@";;
#        *) return 112;;
# esac


# case $1 in
      # is) shift; . "$BING_FUNC/is";  bbis "$@";;
     # get) shift; . "$BING_FUNC/get"; bb_get "$@";;
 # bb_explode) shift; . "$BING_FUNC/bb_explode"; bb_explode "$@";;
 # implode) shift;	. "$BING_FUNC/implode"; implode "$@";;
   # clone) shift;	. "$BING_FUNC/clone";   clone   "$@";;
   # array) shift; . "$BING_FUNC/array"; bb_array "$@";;
       # *) echo 'USAGE: bb BING-FUNC PARAMS' 1>&2 && return 112;;
# esac

}
