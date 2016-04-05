#!/bin/bash bingmsg
#==================================================================
#: FILE: array_merge.bash
#: PATH: $BING_FUNC/array_merge.bash
#: TYPE: function
#:   NS: shell:bash:mandober:bing-bash:function:bb_array_merge
#:  CAT: arrays
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: AUTHOR:
#:      bing-bash by Ivan Ilic <ivanilic1975@gmail.com>
#:      https://github.com/mandober/bing-bash
#:      za Ǆ - Use freely at owns risk
#:      2-Apr-2016 (last revision)
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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
#==================================================================
# $BING_FUNC/array_merge.bash
bb_array_merge() {

#                                                                  ABOUT
#                                                                  =====
 local -r bbapp="${FUNCNAME[0]}"
 local -r bbnfo="[bing-bash] $bbapp v.0.4"
 local -r usage="USAGE: $bbapp [-o OUT] [-m s|o|a] [-t i|a] ARRAY1 ARRAY2 ..."

#                                                               PRECHECK
#                                                               ========
 if [[ $# -eq 0 ]]; then
   printf "\e[2m%s: %s\e[0m\n" "$bbapp" "Parameter error" >&2
   printf "%s\n" "$usage" >&2
   return 2
 fi

#                                                                   HELP
#                                                                   ====
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

#                                                                    SET
#                                                                    ===
 shopt -s extglob extquote; shopt -u nocasematch; set -o noglob
 trap "set +o noglob" RETURN ERR SIGHUP SIGINT SIGTERM


#                                                                  ASSIGN
#                                                                  ======
local bbOut bbMode bbType bbArrays
bbArrays=""
# assign params
while [[ "${1+def}" ]]; do
  case $1 in
  	# name for resulting array
    -o=*|--out=*) bbOut="${1#*=}";;
        -o|--out) bbOut="${2?}"; shift;;
             -o*) bbOut="${1#??}";;

   # mode: s(kip), o(verwrite), a(ppend), r(eindex)
   -m=*|--mode=*) bbMode="${1#*=}";;
       -m|--mode) bbMode="${2?}"; shift;;
             -m*) bbMode="${1#??}";;
   
   # force resulting array's type: a(ssociative), i(ndexed)
   -t=*|--type=*) bbType="${1#*=}";;
       -t|--type) bbType="${2?}"; shift;;
             -t*) bbType="${1#??}";;

  *) # arrays (space separated list)
    bbArrays+="$1 "
  ;;
  esac
shift
done

set -- $bbArrays
unset bbArrays

#                                                                DEFAULTS
#                                                                ========

# MODE
# default mode is skip (keep former value)
bbMode="${bbMode:-s}"
# in case argument is not a single letter,
# get just the first letter (append -> a)
bbMode="${bbMode:0:1}"
[[ ! "$bbMode" =~ ^[soar]$ ]] && return 5

# OUT
# Resulting array name
bbOut="${bbOut:-BING_MERGED}"

# debug
# echo "Arrays: $@"
# echo "Out: $bbOut"
# echo "Mode: $bbMode"


#                                                                    TYPE
#                                                                    ====
# Type of resulting array can be forced, by passing the
# `-t' option with `a' or `i' argument (a=associative, i=indexed)
# `-ti' or `-t=i' means force indexed array as resulting array and
# `-ti' or `-t=a' means force associative array as resulting array.
# If type is not forced it is inferred from passed arrays, so that
# if any of the passed arrays is associative than resulting is also.

local bbArray bbFlag bbTypes

# assume indexed type
bbTypes="i"

# Check vars, type passed words
for bbArray; do
	if bbFlag="$(declare -p "$bbArray" 2>/dev/null)"; then
		bbFlag=( $bbFlag )
		# check if array at all
	  [[ ! "${bbFlag[1]#?}" =~ ^[aA] ]] && {
	    printf "\e[2m%s: %s\e[0m\n" "$bbapp" "Parameter is not an array" >&2
	    return 4
	  }
	  # if associative, change it to a
	  [[ "${bbFlag[1]#?}" =~ ^A ]] && bbTypes="a"
	else
		# name is not a set var
	  printf "\e[2m%s: %s\e[0m\n" "$bbapp" "Variable is not set" >&2
	  return 3
	fi
done


# force resulting array type: a(ssociative), i(ndexed)
if [[ -n "$bbType" ]]; then
	bbType="${bbType:0:1}"
	[[ ! "$bbType" =~ ^[ai]$ ]] && return 6
	# echo "forced type: $bbType"
else
	# if type isn't forced, type is inferred type
  bbType="$bbTypes"
fi

# debug
# echo "inferred type: $bbTypes"
# echo "THE Type: $bbType"

#                                                                 PROCESS
#                                                                 =======

# if any of the passed arrays is assoc, resulting is too
unset BING_MERGED
[[ $bbType == a ]] && declare -Ag BING_MERGED=() || declare -ag BING_MERGED=()


# ====================================================== 1
### resulting array is always assoc
# declare -Ag BING_MERGED=()

local bbA1Keys bbKey

# take the 1st array as basearray
local bbA1Name=$1
local -n bbA1=$1
# make additional array of its keys only
bbA1Keys=( "${!bbA1[@]}" )

# copy 1st array to resulting array
for bbKey in "${!bbA1[@]}"; do
  BING_MERGED[$bbKey]="${bbA1[$bbKey]}"
done

# unset 1st array 
shift

# =================================================== Current

# take next array
local -n bbNext=$1
bbKey=""
local bbMatch
# compare keys of 1st array with keys of current array

# list keys of this array  # b c
for bbKey in "${!bbNext[@]}"; do
  
  bbMatch=0
  # list keys of 1. array # a b
  for bb1Key in "${bbA1Keys[@]}"; do
  	# if keys match
		[[ $bbKey == $bb1Key ]] && ((++bbMatch))
  done

  if (( bbMatch == 0 )); then
    # key not found, add it and it's value
  	BING_MERGED[$bbKey]="${bbNext[$bbKey]}"
  else
	  # key found - overwrite former with latter value
	  [[ $bbMode == o ]] && BING_MERGED[$bbKey]="${bbNext[$bbKey]}"

	  # key found - append latter to former value
	  [[ $bbMode == a ]] && BING_MERGED[$bbKey]+="${bbNext[$bbKey]}"
  fi

done

# ====================================================== Rest
# unset current array
shift

(( $# > 0 )) && {
  # call this func again with already merged and remaining arrays
	bb_array_merge BING_MERGED $@ -o $bbOut -m $bbMode
}

# ====================================================== Out
# typeof BING_MERGED

# Rename final array
bb_array_clone BING_MERGED $bbOut

unset BING_MERGED

return 0

} # $BING_FUNC/array_merge.bash
