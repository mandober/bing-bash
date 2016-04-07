#!/bin/bash bingmsg
#=========================================================================
#: FILE: array_merge.bash
#: PATH: $BING_FUNC/array_merge.bash
#: TYPE: function
#:   NS: shell:bash:mandober:bing-bash:function:bb_array_merge
#:  CAT: arrays
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: AUTHOR:
#:      bing-bash by Ivan Ilic <ivanilic1975@gmail.com>
#:      https://github.com/mandober/bing-bash
#:      za Ǆ - Use freely at owns risk
#:      7-Apr-2016 (last revision)
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: NAME:
#:      bb_array_merge
#:
#: BRIEF:
#:      Merge arrays.
#:
#: DESCRIPTION:
#:      Merges the elements of two or more arrays into resulting array.
#:      User can supply name for the resulting array and optionally
#:      specify mode and type of resulting array. The type of resulting
#:      array will usually be automatically determined: if at least one
#:      array is associative, the resulting array will be associative too.
#:      Otherwise it will be indexed, but the user can force the type
#:      with adequate argument (a|i) to the --type option. For example,
#:      `bb_array_merge ind1 ind2 --type a'  will force resulting array
#:      to be associative even though both passed arrays are indexed.
#:      The argument to --mode option determines what happens when two
#:      arrays have the same key:
#:      --mode=s (-ms) skips that element i.e. keeps previous value
#:      --mode=o (-mo) overwrites previous with the new value
#:      --mode=a (-ma) appends new to the previous value
#:      
#: DEPENDENCIES:
#:      bb_array_clone
#:
#: EXAMPLE:
#:      bb_array_merge array1 array2 array3 -o=merged -m=o
#:      bb_array_merge -omerged -ti arr_ind arr_ass
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: SYNOPSIS:
#:      bb_array_merge [-o OUT] [-m s|o|a] [-t i|a] ARRAY1 ARRAY2 ...
#:
#: OPTIONS:
#:      
#:    -o, --out <option> OUT <argument> <identifier> 
#:      Argument to -o option, OUT, is the user supplied name that will
#:      be used as a name for the resulting array; if not supplied, it
#:      defaults to BING_MERGED.
#:
#:    -m, --mode <option> s|o|a <argument> <enum>
#:      If latter array has the same key as former, than the argument
#:      to -m option (-m s|o|a) determines what happens:
#:      -ms, --mode=s   Skip latter value i.e. keep former value
#:      -mo, --mode=o   Overwrite former with latter value
#:      -ma, --mode=a   Append latter to former value
#:      If -m option is supplied its argument is required.
#:
#:    -t, --type <option> i|a <argument> <enum>
#:      Argument (i|a) to --type option can force the type of resulting array.
#:      The forced type can be `i' for indexed or `a' for associative array.
#:      If this option is not supplied the type for resulting array is 
#:      determined automatically (assoc. if at least 1 array is assoc.).
#:      
#:      Option arguments can be passed after `=' sign (-o=name),
#:      as the next argument (-o name) or, only in case of short
#:      options, immediately after the option (-oname).
#:      
#:
#: PARAMETERS:
#:
#:      ARRAY1 <array>
#:      First, indexed or associative, array.
#:
#:      ARRAY2 <array>
#:      Second, indexed or associative, array.
#:
#:      ... <array>
#:      Sequential indexed or associative, arrays.
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
#:      5  Wrong argument to mode option 
#:      6  Wrong argument to type option 
#:      7  Invalid identifier
#=========================================================================
bb_array_merge() {

#                                                                    ABOUT
#-------------------------------------------------------------------------
 local -r bbapp="${FUNCNAME[0]}"
 local -r bbnfo="[bing-bash] $bbapp v.0.4"
 local -r usage="USAGE: $bbapp [-o OUT] [-m s|o|a] [-t i|a] ARRAY ..."

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
	Merge two or more arrays.
	
	DESCRIPTION:
	  Merges the elements of two or more arrays into the resulting array
	  NAME. User can supply the name for resulting array and optionally
	  specify mode and type of resulting array. The type of resulting
	  array will usually be automatically determined: if at least one
	  array is associative, the resulting array will be associative too;
	  otherwise it will be indexed. User can force (override) the type
	  with adequate argument (a|i) to the --type option. For example,
	  'bb_array_merge ind1 ind2 --type a' will force resulting array to
	  be associative even though both supplied arrays are of indexed type.
	  The argument to --mode option determines what happens when two
	  arrays have the same key:
	  --mode=s (-ms) skips that element i.e. keeps previous value
	  --mode=o (-mo) overwrites previous with the new value
	  --mode=a (-ma) appends new to the previous value
	  Option arguments can be passed after '=' sign (-o=name),
	  as the next argument (-o name) or, only in case of short
	  options, immediately after the option (-oname).

	OPTIONS:
	-o, --out OUT
	  Argument to -o option, OUT, is the user supplied name that will
	  be used as a name for the resulting array; if not supplied, it
	  defaults to BING_MERGED.

	-m, --mode s|o|a
	  If latter array has the same key as former, than the argument
	  to -m option (-m s|o|a) determines what happens:
	  -ms, --mode=s   Skip latter value i.e. keep former value
	  -mo, --mode=o   Overwrite former with latter value
	  -ma, --mode=a   Append latter to former value
	  If -m option is supplied its argument is required.
	
	-t, --type i|a
	  Argument (i|a) to --type option can force the type of resulting array.
	  The forced type can be 'i' for indexed or 'a' for associative array.
	  If this option is not supplied the type for resulting array is 
	  determined automatically (assoc. if at least 1 array is assoc.).

	-h, --help        Show program help.
	-u, --usage       Show program usage.
	-v, --version     Show program version.

	EXAMPLES:
	  bb_array_merge array1 array2 array3 -omerged -mo
	  bb_array_merge -o=Indx assoc1 assoc2 -m=s -t=i

	EOFF
	return 0
 }

#                                                                      SET
#-------------------------------------------------------------------------
 shopt -s extglob extquote; shopt -u nocasematch; set -o noglob
 trap "set +o noglob" RETURN ERR SIGHUP SIGINT SIGTERM



#                                                                   ASSIGN
#=========================================================================
local bbOut         # resulting array's name
local bbMode        # mode: s(kip), o(verwrite), a(ppend), r(eindex)
local bbType        # force type of merged array: a(ssociative), i(ndexed)
local bbArrays=""   # passed arrays (as space separated list)

while (( $# > 0 )); do
  case $1 in
    -o=*|--out=*) bbOut="${1#*=}";;
        -o|--out) bbOut="${2?}"; shift;;
             -o*) bbOut="${1#??}";;

   -m=*|--mode=*) bbMode="${1#*=}";;
       -m|--mode) bbMode="${2?}"; shift;;
             -m*) bbMode="${1#??}";;
   
   -t=*|--type=*) bbType="${1#*=}";;
       -t|--type) bbType="${2?}"; shift;;
             -t*) bbType="${1#??}";;

    *) bbArrays+="$1 ";;
  esac
shift
done

# positionals: remove all then restore just params so that
# list of passed arrays will be in $@ (not in $bbArrays).
set -- $bbArrays
unset bbArrays

#                                                                   CHECKS
#=========================================================================
# Check and validate params. Find the type of each array.
local bbArray bbFlag bbInfType

# Determine resulting array type: if any array
# is associative, than resulting array is also.
# Initially, assume all are indexed (set flag to `i')
bbInfType="i"

for bbArray; do
  if bbFlag="$(declare -p "$bbArray" 2>/dev/null)"; then
    bbFlag=( $bbFlag )
    # see if it is an array at all
    [[ ! "${bbFlag[1]#?}" =~ ^[aA] ]] && {
      printf "\e[2m%s: %s\e[0m\n" "$bbapp" \
      "Parameter $bbArray is not an array" >&2
      return 4
    }
    # if associative, set flag `a'
    [[ "${bbFlag[1]#?}" =~ ^A ]] && bbInfType="a"
  else
    # error: param is not a set var
    printf "\e[2m%s: %s\e[0m\n" "$bbapp" \
    "Variable $bbArray is not set" >&2
    return 3
  fi
done

#                                                                     TYPE
#=========================================================================
# Inferred type of resulting array can be overridden, by passing
# `-t' option with `a' or `i' argument (a=associative, i=indexed)
# `-ti' or `-t=i' means force indexed array as resulting array and
# `-ti' or `-t=a' means force associative array as resulting array.
if [[ -n "$bbType" ]]; then
  bbType="${bbType:0:1}"
  [[ ! "$bbType" =~ ^[ai]$ ]] && return 6
else
  # if type isn't forced, type is inferred
  bbType="$bbInfType"
fi

#                                                                     MODE
#=========================================================================
if [[ -n "$bbMode" ]]; then
  # in case argument is not a single letter,
  # reduce it to the first letter (append => a)
  bbMode="${bbMode:0:1}"
  # error if that letter is not [soa]
  [[ ! "$bbMode" =~ ^[soa]$ ]] && return 5
else
  # If not supplied, mode defaults to skip (keep former value)
  bbMode="s"
fi

#                                                                      OUT
#=========================================================================
# Resulting array name, if supplied check validity
# If not supplied, OUT defaults to BING_MERGED
if [[ -n "$bbOut" ]]; then
  if [[ ! "$bbOut" =~ ^[[:alpha:]_][[:alnum:]_]*$ ]]; then
    printf "\e[2m%s: %s\e[0m\n" "$bbapp" "Invalid identifier" 1>&2
    return 7
  fi
else
  bbOut=BING_MERGED
fi



# DEBUG
# local
# echo "Arrays: $@"
# echo "Out: $bbOut"
# echo "Mode: $bbMode"
# echo "forced type: $bbType"
# echo "inferred type: $bbInfType"
# echo "THE Type: $bbType"


#                                             SPECIAL CASE: FORCED INDEXED
#=========================================================================
# if type of resulting array is inferred
# to be associative, but indexed type is forced
# then REINDEX and merge all arrays
if [[ $bbInfType == "a" && $bbType == "i" ]]; then
  unset BING_MERGED
  declare -ag BING_MERGED=()
  local -n bbArrRef
  for bbArrRef; do
    BING_MERGED+=( "${bbArrRef[@]}" )
  done

  # rename array
  if [[ "$bbOut" != BING_MERGED ]]; then
    local bbRename bbPattern
    bbRename="$(declare -p BING_MERGED 2>/dev/null)"
    bbPattern="declare -ag $bbOut="
    unset $bbOut
    eval "${bbRename/#declare*BING_MERGED=/$bbPattern}"
    unset BING_MERGED
  fi

  return 0
fi

#                                                               BASE ARRAY
#=========================================================================
# First step:
# copy 1st array to resulting array
[[ $bbType == a ]] && declare -Ag BING_ARRAY=() || declare -ag BING_ARRAY=()

# take the 1st array as base array
local -n bbA1=$1

# copy 1st array to resulting array
local bbKey
for bbKey in "${!bbA1[@]}"; do
  BING_ARRAY[$bbKey]="${bbA1[$bbKey]}"
done

# unset 1st array 
shift

#                                                            CURRENT ARRAY
#=========================================================================
# Second step:
# compare keys of 1.array with keys of current
# array before adding the 2. to resulting array
while (( $# > 0 )); do

  local -n bbNext=$1
  bbKey=""
  local bbMatch bbA1Key

  # list keys of current array
  for bbKey in "${!bbNext[@]}"; do
    bbMatch=0

    # list keys of 1. array
    for bbA1Key in "${!BING_ARRAY[@]}"; do
      # check if keys match
      [[ $bbKey == $bbA1Key ]] && ((++bbMatch))
    done

    if (( bbMatch == 0 )); then
      # key not found, ADD it and it's value
      BING_ARRAY[$bbKey]="${bbNext[$bbKey]}"
    else
      # key found - OVERWRITE former with latter value
      [[ $bbMode == o ]] && BING_ARRAY[$bbKey]="${bbNext[$bbKey]}"

      # key found - APPEND latter to former value
      [[ $bbMode == a ]] && BING_ARRAY[$bbKey]+="${bbNext[$bbKey]}"
    fi

  done

  # unset current array
  shift

done



#                                                             OTHER ARRAYS
#=========================================================================
# Third step (optional):
# if more than 2 params (arrays), call this func again
# with already merged and remaining params (arrays)
# if (( $# > 0 )); then
#   echo "CMD: bb_array_merge BING_ARRAY $@ -m$bbMode -o$bbOut -t$bbType"
#   bb_array_merge BING_ARRAY "$@" -m$bbMode -o$bbOut -t$bbType
#   typeof BING_ARRAY
# fi

#                                                          RESULTING ARRAY
#=========================================================================
# Final step:
# Rename resulting array to user supplied name
# typeof BING_ARRAY

local bbRename bbPattern
bbRename="$(declare -p BING_ARRAY 2>/dev/null)"

if [[ $bbType == i ]]; then
  bbPattern="declare -ag $bbOut="
else
  bbPattern="declare -Ag $bbOut="
fi

unset $bbOut
eval "${bbRename/#declare*BING_ARRAY=/$bbPattern}"
unset BING_ARRAY

return 0
} # $BING_FUNC/array_merge.bash

# cd $BING_FUNC
# . array_merge.bash
# bb_array_merge linux unix -oout
# typeof out
