#!/bin/bash bingmsg
#=======================================================================
#: FILE: implode
#: PATH: $BING_FUNC/implode.bash
#: TYPE: function
#:
#: AUTHOR:
#:      bing-bash by Ivan Ilic <ivanilic1975@gmail.com>
#:      https://github.com/mandober/bing-bash
#:      za Ǆ - Use freely at owns risk
#:      26-Mar-2016 (last revision)
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
#:      
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
#:      NAME <variable identifier>
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
#:      0  great success
#:      1  miserable failure
#:      4  Parameter is not an array
#:      6  Invalid identifier
#:      9  Parameter empty
#=======================================================================

bb_implode() {

#                                                                  ABOUT
#                                                                  =====
 local -r bbapp="${FUNCNAME[0]}"
 local -r bbnfo="[bing-bash] $bbapp v.0.20"
 local -r usage="USAGE: $bbapp ARRAY [-g GLUE] [NAME]"

#                                                               PRECHECK
#                                                               ========
  if [[ $# -eq 0 ]]; then
    printf "\e[2m%s: %s\e[0m\n" "$bbapp" "Parameter empty" >&2
    printf "%s\n" "$usage" >&2
    return 9
  fi


#                                                                   HELP
#                                                                   ====
 [[ $1 =~ ^(-u|--usage)$ ]] && { printf "%s" "$usage\n"; return 0; }
 [[ $1 =~ ^(-v|--version)$ ]] && { printf "%s" "$bbnfo\n"; return 0; }
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

#                                                                    SET
#                                                                    ===
 shopt -s extglob extquote; shopt -u nocasematch; set -o noglob
 trap "set +o noglob" RETURN ERR SIGHUP SIGINT SIGTERM


#                                                                  PARAMS
#                                                                  ======
# Check that param is an array
local bbFlag
if bbFlag=$(declare -p "$1" 2>/dev/null); then
  bbFlag=( $bbFlag )
  if [[ ! "${bbFlag[1]}" =~ ^-[aA] ]]; then
    printf "\e[2m%s: %s\e[0m\n" "$bbapp" "Parameter is not an array" >&2
    return 4
  fi
fi

local bbArrayName bbGlue bbNewName

## ARRAY
bbArrayName="$1"
local -n bbArrayRef="$1"
shift

# assign params
while [[ "${1+def}" ]]; do
  case $1 in
    -g|--glue)
      bbGlue="${2?}"
      shift
    ;;

    -g=*|--glue=*)
      bbGlue="${1#*=}"
    ;;

    *) 
      # NAME
      bbNewName="${1:-BING_IMPLODED}"
      # check if NAME is a valid identifier
      if [[ ! "$bbNewName" =~ ^[[:alpha:]_][[:alnum:]_]*$ ]]; then
        printf "\e[2m%s: %s\e[0m\n" "$bbapp" "Invalid identifier" >&2
        return 6
      fi
    ;;
  esac
  shift
done

echo "ArrayName: $bbArrayName"
echo "Glue: $bbGlue"
echo "NewName: $bbNewName"


### IMPLODE
local bbVal bbString=""

for bbVal in "${bbArrayRef[@]}"; do
	
	# skip null elements
	[[ -z "$bbVal" ]] && continue
	
	# add element
	bbString+="$bbVal"
	
	# add glue
	bbString+="$bbGlue"
done

# remove trailing glue
bbString="${bbString%$bbGlue}"

### Assign the string to chosen name
read -r "$bbNewName" <<< "$bbString"

return 0

} # $BING_FUNC/implode.bash
