#!/bin/bash bingmsg
#=========================================================================
# FILE: venn.bash
# PATH: $BING_FUNC/venn.bash
# TYPE: function
#   NS: shell:bash:mandober:bing-bash:function:bb_venn
#  CAT: arrays
#
# AUTHOR:
#      bing-bash by Ivan Ilic <ivanilic1975@gmail.com>
#      https://github.com/mandober/bing-bash
#      za Ǆ - Use freely at owns risk
#      10-Apr-2016 (last revision)
#
#-------------------------------------------------------------------------
# NAME: 
#      bb_venn
#
# BRIEF: 
#      Venn diagrams related functions.
#
# DESCRIPTION:
#      Calculates union, intersection, difference and complement resulting (indexed) array for inputs, which can be indexed arrays, associative arrays, variables or strings. Internally, everything is converted to indexed array and than calculated: input indexed arrays are left alone; input associative arrays are convert to indexed with thier keys discarded; input variables and strings are exploded by character into indexed array of characters.
#    * If input is 2 parameters, everything works as expected.
#    * In case of 3 or more parameters: 
#      - UNION works as expected:         A ∪ B  ∪ C  ∪ D
#      - INTERSECTION does not, it is:  ((A ∩ B) ∩ C) ∩ D
#      - DIFFERENCE, the same as above: ((A Δ B) Δ C) Δ D
#      - COMPLEMENT, the same as above: ((A \ B) \ C) \ D
#      
#    * Venn functions: 
#                 setA {abcde}
#                 setB {abfg}
#        union: A ∪ B  {abcdefg}
# intersection: A ∩ B  {ab}
#   difference: A Δ B  {cdefg}
#   complement: A \ B  {cde}
#               B \ A  {fg}
#      
# DEPENDENCIES:
#      
#
# EXAMPLE:
#      
#
#-------------------------------------------------------------------------
# SYNOPSIS:
#      bb_venn 
#
# OPTIONS: 
#      -u, --union          Return union of setA and setB.
#      -i, --intersection   Return intersection of setA and setB.
#      -d, --difference     Return difference of setA and setB.
#      -a, --complement-a   Return complement of setA in setA and setB.
#      -b, --complement-b   Return complement of setB in setA and setB.
#      
#
# PARAMETERS:
#      
#
#-------------------------------------------------------------------------
# STDOUT:
#      -
#
# STDERR:
#      Error messages, usage
#
# RETURN STATUS:
#      0  great success
#      1  miserable failure
#      2  Parameter error
#      3  Variable is not variable
#      4  Parameter is not an array
#      5  Wrong argument to mode option 
#      6  Wrong argument to type option 
#      7  Invalid identifier
#      8  Not in interactive shell
#
#=========================================================================
bb_venn () {

#                                                                    ABOUT
#-------------------------------------------------------------------------
 local -r bbapp="${FUNCNAME[0]}"
 local -r bbnfo="[bing-bash] $bbapp v.0.11"
 local -r usage="USAGE: $bbapp SET0 -u|i|d|a|b SET1"

#                                                                 PRECHECK
#-------------------------------------------------------------------------
 if [[ $# -eq 0 ]]; then
   printf "\e[2m%s: %s\e[0m\n" "$bbapp" "Parameter error" >&2
   printf "%s\n" "$usage" >&2
   return 2
 fi

#                                                                     HELP
#-------------------------------------------------------------------------
 [[ $1 =~ ^(--usage)$ ]] && { printf "%s" "$usage\n"; return 0; }
 [[ $1 =~ ^(-v|--version)$ ]] && { printf "%s" "$bbnfo\n"; return 0; }
 [[ $1 =~ ^(-h|--help)$ ]] && {
	printf "\e[7m%s\e[0m\n" "$bbnfo"
	printf "\e[1m%s\e[0m\n" "$usage"
	cat <<-EOFF
	Venn diagrams related functions.
	
	DESCRIPTION:
	  Return elements as a product of relation between set A
	  and set B, where relation is one of union, intersection,
	  and set B, complement.

	OPTIONS:
	  -u, --union          Return union of setA and setB.
	  -i, --intersection   Return intersection of setA and setB.
	  -d, --difference     Return difference of setA and setB.
	  -a, --complement-a   Return complement of setA in setA and setB.
	  -b, --complement-b   Return complement of setB in setA and setB.
	      --help           Show program help.
	      --usage          Show program usage.
	      --version        Show program version.
	EXAMPLES:
	                   setA={ecabde}
	                   setB={gbfga}
	          union: A U B ={abcdefg}
	   intersection: A ∩ B ={ab}
	     difference: A Δ B ={cdefg}
	   complement-a: A - B ={cde}
	   complement-b: B - A ={fg}
	EOFF
	return 0
 }

#                                                                      SET
#-------------------------------------------------------------------------
 shopt -s extglob extquote; shopt -u nocasematch; set -o noglob
 trap "set +o noglob" RETURN ERR SIGHUP SIGINT SIGTERM


#                                                                   ASSIGN
#=========================================================================
local bbOut            # output name
local bbRel            # relation u|i|d|a|b
local -a bbParams=()   # input params
local bbParam          # input param
local bbV              # verbosity level (0|1|2|3) quiet|error|fatal|debug

while (( $# > 0 )); do
  case $1 in
       -o=*|--out=*) bbOut="${1#*=}";;
           -o|--out) bbOut="${2?}"; shift;;
                -o*) bbOut="${1#??}";;

   -v=*|--verbose=*) bbV="${1#*=}";;
       -v|--verbose) bbV="${2?}"; shift;;
                -v*) bbV="${1#??}";;

       -r=*|--rel=*) bbRel="${1#*=}";;
           -r|--rel) bbRel="${2?}"; shift;;
                -r*) bbRel="${1#??}";;

         -u|--union) bbRel=u;;
  -i|--intersection) bbRel=i;;
    -d|--difference) bbRel=d;;
 -c|-a|--complement) bbRel=c;;
  -b|--complement-b) bbRel=b;;

   --) shift; bbParams+=("$@"); break;;

    *) bbParams+=("$1");;
  esac
  shift
done

#                                                                 DEFAULTS
#=========================================================================

#                                        VERBOSITY
#-------------------------------------------------
((bbV==2)) && {
	echo "Out: $bbOut"
	echo "Ver: $bbV"
	echo "Rel: $bbRel"
}>&2

((bbV==3)) && { printf "\nINITIAL:\n"; local; }>&2

#                                                                 IDENTIFY
#=========================================================================
# All params should be indexed arrays.
# Identify params as indexed, associative, scalar and strings
# Convert if not indexed: explode scalars and strings by char
# convert associative to indexed
local bbFlag
local bbKey
local bbSet
local bbCount="${#bbParams[@]}"

for bbKey in "${!bbParams[@]}"; do
  local bbSetName="${bbParams[$bbKey]}"

  if bbFlag="$(declare -p "$bbSetName" 2>/dev/null)"; then

    local -n bbSet="${bbParams[$bbKey]}"
    # local -n bbSet=linux

    # param is var, get its attr
    bbFlag=( $bbFlag )
    bbFlag="${bbFlag[1]#?}"
    # echo "Flag: $bbFlag"

    # id attr
    case $bbFlag in
      a*) # indexed
          # echo "indexed: $bbSetName"
          eval "local -a SET$bbKey=( \"\${bbSet[@]}\" )"
          # typeof SET$bbKey
          local bbTemp
          eval "bbTemp=\$(printf '%s\\n' \"\${SET$bbKey[@]}\" | sort -u)"
          unset "SET$bbKey"
          mapfile -t "SET$bbKey" <<< "$bbTemp"
          # typeof SET$bbKey
      ;;

      A*) # assoc
				  # echo "assoc: $bbSetName"
          eval "local -a SET$bbKey=( \"\${bbSet[@]}\" )"
          # typeof SET$bbKey
          local bbTemp
          eval "bbTemp=\$(printf '%s\\n' \"\${SET$bbKey[@]}\" | sort -u)"
          unset "SET$bbKey"
          mapfile -t "SET$bbKey" <<< "$bbTemp"
          # typeof SET$bbKey
			;;

    	 *) # scalar
          # echo "scalar: $bbSetName (val: ${!bbSetName})"

          local bbSrc="${!bbSetName}"
          eval "local -a SET$bbKey=()"
          while ((${#bbSrc} > 0)); do
            eval "SET$bbKey+=( \"\${bbSrc:0:1}\" )"
            bbSrc="${bbSrc#?}"
          done
          # typeof SET$bbKey
          local bbTemp
          eval "bbTemp=\$(printf '%s\\n' \"\${SET$bbKey[@]}\" | sort -u)"
          unset "SET$bbKey"
          mapfile -t "SET$bbKey" <<< "$bbTemp"
          # typeof SET$bbKey
			 ;;
    esac

  else
    # var is not set  - explode value by char
    # echo "string: $bbSetName"

    local bbSrc="$bbSetName"
    eval "local -a SET$bbKey=()"
    while ((${#bbSrc} > 0)); do
      eval "SET$bbKey+=( \"\${bbSrc:0:1}\" )"
      bbSrc="${bbSrc#?}"
    done
    # typeof SET$bbKey
    local bbTemp
    eval "bbTemp=\$(printf '%s\\n' \"\${SET$bbKey[@]}\" | sort -u)"
    unset "SET$bbKey"
    mapfile -t "SET$bbKey" <<< "$bbTemp"
    # typeof SET$bbKey
  fi
done

# echo "Count: $bbCount"


((bbV==3)) && { printf "\nCHECKS:\n"; local; }>&2

#                                                                  PROCESS
#=========================================================================
case $bbRel in

#                                                    UNION
#---------------------------------------------------------
u) 
  # A --union B		# A={ace} ∪ B={ab} -> {abce}
  local -a BING_ARRAY=()
  local bbTemp
  # make refrence to each array in params, merge them
  local -n bbArrRef
  for bbArrRef in ${!SET*}; do
    BING_ARRAY+=( "${bbArrRef[@]}" )
  done
  # typeof BING_ARRAY
  bbTemp=$(printf "%s\n" "${BING_ARRAY[@]}" | sort -u)
  mapfile -t "$bbOut" <<< "$bbTemp"
  
  typeof $bbOut
  return 0
;;

#                                             INTERSECTION
#---------------------------------------------------------
i) 
  # A --intersection B    # A={ace} ∩ B={ab} -> {a}
  local -a BING_ARRAY=()
  local bbTemp

  # make refrence to each array in params, merge them
  local -n bbArrRef
  for bbArrRef in ${!SET*}; do
    BING_ARRAY+=( "${bbArrRef[@]}" )
  done
  # typeof BING_ARRAY
  bbTemp=$(printf "%s\n" "${BING_ARRAY[@]}" | sort | uniq -d)
  mapfile -t "$bbOut" <<< "$bbTemp"
  
  typeof $bbOut
  return 0
;;

#                                               DIFFERENCE
#---------------------------------------------------------
d)
	# A --difference B : A={ace} Δ B={ab} => {bce} 
	# U \ I: U={abce} \ I={a}   => {bce}
  local -a BING_ARRAY=()
  local bbTemp
  # make refrence to each array in params, merge them
  local -n bbArrRef
  for bbArrRef in ${!SET*}; do
    BING_ARRAY+=( "${bbArrRef[@]}" )
  done
  # typeof BING_ARRAY
  bbTemp=$(printf "%s\n" "${BING_ARRAY[@]}" | sort | uniq -u)
  mapfile -t "$bbOut" <<< "$bbTemp"
  
  typeof $bbOut
  return 0
;;

#                                               COMPLEMENT
#---------------------------------------------------------
c)
	# A --complement-a B : A={ace} \ B={ab} -> {ce}
  local -a BING_ARRAY=()
  local bbTemp a b
  # echo "Count: $bbCount"
  # typeof SET0
  # typeof SET1

  for a in "${SET0[@]}"; do
    for b in "${SET1[@]}"; do
      [[ "_$a" = "_$b" ]] && continue 2
    done
    BING_ARRAY+=( "$a" )
  done
  # typeof BING_ARRAY
  bbTemp=$(printf "%s\n" "${BING_ARRAY[@]}" | sort)
  mapfile -t "$bbOut" <<< "$bbTemp"
  
  typeof $bbOut
  return 0
;;

#                                          COMPLEMENT TEST
#---------------------------------------------------------
b)
  # A --complement-a B : A={ace} \ B={ab} -> {ce}
  local -a BING_ARRAY=()
  local bbTemp a b i
  # echo "Count: $bbCount"
  # typeof SET0
  # typeof SET1
  # typeof SET2

for n in "${!bbParams[@]}"; do
  bbTmp+="SET$n "
done
set -- $bbTmp

# take the 0th array as base array
local -n bbS0=$1
shift

# Compare values of base array with values of next (current) array.
# Remove elements from base array where values match. 
# bbS0 is base array (static)
# bbNext is current array (dynamic)

# local bbMatch   # counts matched values
local bbNextKey # holds current key of current array
local bbS0Key   # holds current key of base array

while (( $# > 0 )); do
  # refrence the current array
  local -n bbNext=$1
  # reset var that holds values of current array
  bbNextKey="" 

  # list keys/vals of current array
  for bbNextKey in "${!bbNext[@]}"; do
    # bbMatch=0

    # list keys/vals of base array
    for bbS0Key in "${!bbS0[@]}"; do
      # echo "bbNext: ${bbNext[$bbNextKey]}"
      # echo "bbS0: ${bbS0[$bbNextKey]}"

      # check if vals match
      if [[ "${bbNext[$bbNextKey]}" == "${bbS0[$bbNextKey]}" ]]; then
        unset "${bbS0[$bbNextKey]}" && break
      fi
    done

    # if ((bbMatch == 0)); then
      # key not found, ADD it to final array
      # BING_ARRAY+="${bbNext[$bbKey]}"
    # fi

  done

  # unset current array
  shift

done

bbTemp=$(printf "%s\n" "${bbS0[@]}" | sort)
mapfile -t "$bbOut" <<< "$bbTemp"

typeof bbS0

return 0

  # for a in "${SET0[@]}"; do
  #   for b in "${SET1[@]}"; do
  #     [[ "_$a" = "_$b" ]] && continue 2
  #   done
  #   BING_ARRAY+=( "$a" )
  # done
  # return
;;


#                                             COMPLEMENT-B
#---------------------------------------------------------
bb) 
	# B ---complement-b A : B={ab} \ A={ace} -> {b}
  local -a BING_ARRAY=()
  local bbTemp a b
  # echo "Count: $bbCount"
  # typeof SET0
  # typeof SET1

  for a in "${SET1[@]}"; do
    for b in "${SET0[@]}"; do
      [[ "_$a" = "_$b" ]] && continue 2
    done
    BING_ARRAY+=( "$a" )
  done
  # typeof BING_ARRAY
  bbTemp=$(printf "%s\n" "${BING_ARRAY[@]}" | sort)
  mapfile -t "$bbOut" <<< "$bbTemp"
  
  typeof $bbOut
  return 0
;;


*) return 1;;

esac

} # $BING_FUNC/venn.bash
