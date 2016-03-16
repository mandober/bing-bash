#!/bin/bash bingmsg
#==================================================================
#: FILE: implode
#: PATH: $BING/func/implode.bash
#: TYPE: function
#:
#: AUTHOR:
#:      bing-bash by mandober <zgag@yahoo.com>
#:      https://github.com/mandober/bing-bash
#:      za Ǆ - Use freely at owns risk
#:      9-Mar-2016 (last revision)
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: NAME:
#:      bb_implode
#:
#: BRIEF:
#:      Convert an array into a string.
#:
#: DESCRIPTION:
#:      Convert an array into a string by inserting character(s)
#:      GLUE after each element, skipping array's null elements.
#:      * If not supplied GLUE defaults to comma.
#:      * If NAME is not supplied it defaults to BING_IMPLODED.
#:
#: DEPENDENCIES:
#:      bb_err
#:
#: EXAMPLE:
#:      implode BASH_VERSINFO -g '.' var1
#:      implode Array -g='.' var1
#:      implode Array
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: SYNOPSIS:
#:      implode ARRAY [-g GLUE] [NAME]
#:
#: OPTIONS:
#:      -g, --glue  
#:      Specify glue char(s) after equal sign (e.g. -g=':')
#:      or as a following argument (e.g. -g ', ').
#:
#: PARAMETERS:
#:
#:      ARRAY <array>
#:      Array to implode. It is the only required parameter.
#:      Arrays must always be passed by name (without $).
#:
#:      GLUE <char>
#:      Substring composed of single or muliple characters that will
#:      be inserted after each array element.
#:
#:      NAME <identifier>
#:      Identifier for resulting string.
#:      If not given the default is BING_IMPLODED.
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: RETURN TO ENVIRONMENT:
#:      <variable identifier> NAME
#:      Creates a variable, containg the resulting imploded string,
#:      called NAME, if name is provided. Otherwise this variable is
#:      called BING_IMPLODED.
#:
#: STDOUT:
#:      Help, usage, version (if explicitly requested).
#:
#: STDERR:
#:      Error messages.
#:
#: RETURN CODE:
#:		0  - success
#:	    non 0 - see err file
#==================================================================

bb_implode() {

#   ABOUT
#
local bbapp=$FUNCNAME
local bbnfo="[bing-bash] $bbapp v.15"
local usage="USAGE: $bbapp ARRAY [-g GLUE] [NAME]"

#   DEPENDENCIES
#
[[ -z "$(declare -F bb_err 2>/dev/null)" ]] && . $BING/func/err

#   PRECHECK
#
[[ $# -eq 0 ]] && { bb_err 51; printf "${usage}\n" >&2; return 51; }
[[ $# -gt 3 ]] && { bb_err 52; printf "${usage}\n" >&2; return 52; }

#   HELP
#
[[ $1 =~ ^(-u|--usage)$ ]] && { printf "${usage}\n"; return 0; }
[[ $1 =~ ^(-v|--version)$ ]] && { printf "${bbnfo}\n"; return 0; }
[[ $1 =~ ^(-h|--help)$ ]] && {
	cat <<-EOFF
	$bbnfo
	  Convert an array to a string.
	$usage
	  Convert an array into a string by inserting GLUE after each
	  element, skipping array's null elements. If not supplied GLUE
	  defaults to comma. If NAME of resulting string is not supplied,
	  NAME defaults to BING_IMPLODED.
	OPTIONS:
	   -g, --glue        Binding string.
	   -h, --help        Show program help.
	   -u, --usage       Show program usage.
	   -v, --version     Show program version.
	EXAMPLE:
	  $bbapp BASH_VERSINFO '.' bashversion
	EOFF
	return 0
}

#   SET
#
shopt -s extglob 		# Enable extended regular expressions
shopt -s extquote		# Enables $'' and $"" quoting
shopt -u nocasematch 	# regexp case-sensitivity
set -o noglob			# Disable globbing. Enable it upon return:
trap "set +o noglob" RETURN ERR SIGHUP SIGINT SIGTERM


#   PARAMS
#

#
# ARRAY
local bbArrayName="$1"
local -n bbArrayRef="$1"
! bbis --array "$bbArrayName" && { errors 63; return 63; }

#
# GLUE
local bbGlue
case $2 in
	-g|--glue)
		bbGlue="${2?}"
		shift
	;;

	-g=*|--glue=*)
		bbGlue="${2#*=}"
	;;

	-|--)
		bbGlue=','
	;;

	*)
		bb_err 55
		return 55
	;;
esac

#3 NAME
local bbNewName
bbNewName="${3:-BING_IMPLODED}"
! bbis --id "$bbNewName" && { errors 61; return 61; }


### IMPLODE
local j
local bbString=
for j in "${!bbArrayRef[@]}"; do
	# skip null elements
	[[ -z "${bbArrayRef[$j]}" ]] && continue
	# add element
	bbString+="${bbArrayRef[$j]}"
	# add glue
	bbString+="$bbGlue"
done
# remove trailing glue
bbString="${bbString%$bbGlue}"

### Assign the string to chosen name
read -r "$bbNewName" <<< "$bbString"
}
