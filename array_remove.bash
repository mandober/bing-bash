#!/bin/bash bingmsg
#==================================================================
#: FILE: array_remove.bash
#: PATH: $BING_FUNC/array_remove.bash
#: TYPE: function
#:   NS: shell:bash:mandober:bing-bash:function:bb_array_remove
#:  CAT: arrays
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: AUTHOR:
#:      bing-bash by Ivan Ilic <ivanilic1975@gmail.com>
#:      https://github.com/mandober/bing-bash
#:      za Ǆ - Use freely at owns risk
#:      7-Mar-2016 (last revision)
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: NAME: 
#:      bb_array_remove
#:
#: BRIEF: 
#:      Remove array element(s).
#:
#: DESCRIPTION:
#:      Remove element with key N from array, where N is a single
#:      array key, a comma-separated list of array keys or a range
#:      of keys; or any of this combined (e.g. 1,2,5,8-16,18,20-25).
#:      Ranges are inclusive. Besides being an index in indexed array,
#:      N can be a key in associative array. Optionally, if a NAME for
#:      a new array is provided than the resulting array will be stored
#:      in an array by that name, leaving the original array intact.  
#:
#: DEPENDENCIES:
#:      bb_range
#:
#: EXAMPLE:
#:      bb_array_remove varray 0
#:      bb_array_remove varray 1,2,5
#:      bb_array_remove varray 0,3,5-10,12,15-20
#:      bb_array_remove varray keyA
#:      bb_array_remove varray keyA,keyB,keyF
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: SYNOPSIS:
#:      bb_array_remove ARRAY [-o NAME] -r KEY[,KEY...]
#:
#: OPTIONS: 
#:
#:     -o, --out <option> NAME <argument> <identifier> 
#:      Argument to -o option, NAME, is the user supplied name that will
#:      be used as a name for the resulting array; if not supplied, it
#:      defaults to BING_MERGED.
#:      
#:     -r, --remove <option> KEY <argument> <subscript> 
#:      A single index/key or sequence of indices/keys specified as KEY 
#:      to be removed from indexed or associative array.
#:
#: PARAMETERS:
#:      ARRAY <array>
#:      An indexed or associative array from which the elements
#:      will be removed. Specifed, as always, by name (without $).
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: STDOUT:
#:      Help, usage, version (if explicitly requested).
#:
#: STDERR:
#:      Error messages.
#:
#: RETURN CODE:
#:      0  great success
#:      1  miserable failure
#:      2  Parameter error
#:      3  Variable is not variable
#:      4  Parameter is not an array
#:      6  Invalid identifier
#==================================================================

bb_array_remove() {

#                                                                    ABOUT
#-------------------------------------------------------------------------
 local -r bbapp="${FUNCNAME[0]}"
 local -r bbnfo="[bing-bash] $bbapp v.0.16"
 local -r usage="USAGE: $bbapp ARRAY [-o NAME] -r KEY[,KEY...]"

#                                                                 PRECHECK
#-------------------------------------------------------------------------
 if [[ $# -eq 0 ]]; then
   printf "\e[2m%s: %s\e[0m\n" "$bbapp" "Parameter error" >&2
   printf "%s\n" "$usage" >&2
   return 2
 fi

#                                                                     HELP
#-------------------------------------------------------------------------
 [[ $1 =~ ^(-u|--usage)$ ]] && { printf "%s" "$usage\n"; return 0; }
 [[ $1 =~ ^(-v|--version)$ ]] && { printf "%s" "$bbnfo\n"; return 0; }
 [[ $1 =~ ^(-h|--help)$ ]] && {
	printf "\e[7m%s\e[0m\n" "$bbnfo"
	printf "\e[1m%s\e[0m\n" "$usage"
	cat <<-EOFF
	Remove array elements.

	DESCRIPTION:
	  Remove a single element with specified index/key from an array; 
	  remove several elements by specifying them as comma-separated
	  list of integers and/or ranges (e.g. 1,2,5,8-16,18,20-25). 
	  Ranges are inclusive. Optionally, if name for the resulting
	  array is specified, the original array will be left intact.

	OPTIONS:
	  -h, --help        Show program help.
	  -u, --usage       Show program usage.
	  -v, --version     Show program version.

	EXAMPLES:
	   $bbapp arr -r0,3,5-10,12,15-20
	   $bbapp arr -r=KeyA,KeyB,KeyC
	EOFF
	return 0
 }

#                                                                      SET
#-------------------------------------------------------------------------
 shopt -s extglob extquote; shopt -u nocasematch; set -o noglob
 trap "set +o noglob" RETURN ERR SIGHUP SIGINT SIGTERM


#                                                                   ASSIGN
#=========================================================================
local bbArray       # input array's name
local bbRemove      # elements to remove
local bbOut         # output array's name

while (( $# > 0 )); do
  case $1 in
       -o=*|--out=*) bbOut="${1#*=}";;
           -o|--out) bbOut="${2?}"; shift;;
                -o*) bbOut="${1#??}";;

    -r=*|--remove=*) bbRemove="${1#*=}";;
        -r|--remove) bbRemove="${2?}"; shift;;
                -r*) bbRemove="${1#??}";;
   
    *) bbArray="$1";;
  esac
  shift
done




#                                                                   CHECKS
#=========================================================================
local bbFlag

#                                       INPUT ARRAY
#--------------------------------------------------
# check if param is set var
if ! bbFlag="$(declare -p "$bbArray" 2>/dev/null)"; then
  printf "\e[2m%s: %s\e[0m\n" "$bbapp" \
  "Parameter $bbArray is not set" >&2
  return 3
fi

# check if array
bbFlag=( $bbFlag )
if [[ ! "${bbFlag[1]}" =~ ^-[aA] ]]; then
  printf "\e[2m%s: %s\e[0m\n" "$bbapp" \
  "Parameter $bbArray is not an array" >&2
  return 4
fi

unset bbFlag
local -n bbArrayRef="$bbArray"

#                                          ELEMENTS
#--------------------------------------------------
# elements to remove
if [[ ! "$bbRemove" =~ [[:digit:]]+[,-]? ]]; then
  printf "\e[2m%s: %s\e[0m\n" "$bbapp" "Invalid range" >&2
  return 7
else
  if [[ -r $BING_FUNC/range.bash ]]; then
    . $BING_FUNC/range.bash
    bbRemove="$(bb_range "$bbRemove")"
  else
    printf "\e[2m%s: %s\e[0m\n" "$bbapp" \
    "Fatal errror: file range.bash not found" >&2
    return 8
  fi
fi


#                                              NAME
#--------------------------------------------------
# output array: original or new
if [[ -n "$bbOut" ]]; then
  # check if supplied name is valid
	[[ ! "$bbOut" =~ ^[[:alpha:]_][[:alnum:]_]*$ ]] && {
	  printf "\e[2m%s: %s\e[0m\n" "$bbapp" \
	  "Invalid identifier" >&2
	  return 6
	}
else
	# change original array
  bbOut=$bbArray
fi


local
#                                                                  PROCESS
#=========================================================================


#                             CHANGE ORIGINAL ARRAY
#--------------------------------------------------
local bbKey

# remove elements from original array
for bbKey in ${bbRemove[@]}; do
	unset -v "bbArrayRef[$bbKey]"
done

return 0


#                               CHANGE CLONED ARRAY
#--------------------------------------------------

# TODO: copy original array to an array with 
# user supplied name and then remove elements.



} # $BING_FUNC/array_remove.bash
