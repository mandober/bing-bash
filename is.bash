#!/bin/bash bingmsg
#========================================================================
#: FILE: is.bash
#: PATH: $BING_FUNC/is.bash
#: TYPE: function
#:   NS: shell:bash:mandober:bing-bash:function:bb_is
#:  CAT: helpers
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#:
#: AUTHOR:
#:      bing-bash by Ivan Ilic <ivanilic1975@gmail.com>
#:      https://github.com/mandober/bing-bash
#:      za Ǆ - Use freely at owns risk
#:      20-Apr-2016 (last revision)
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: NAME: 
#:      bb_is
#:
#: BRIEF: 
#:      Patterns matching subroutines.
#:
#: DESCRIPTION:
#:      True or false pattern matching subroutines that can
#:      validate strings, numbers, options, ranges, filenames, paths,
#:      variables and arrays.
#:      See description in code below for each routine.
#:
#: DEPENDENCIES:
#:      none
#:
#: EXAMPLES:
#:      bb_is --opt "-c"
#:      bb_is --set var
#:      bb_is --sparse array
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
#: SYNOPSIS:
#:      bb_is --PROPERTY NAME
#:
#: OPTIONS:
#:      There are no classic options; in fact, they are just calls
#:      to particular subroutine.
#:
#: PARAMETERS:
#:      NAME <string>
#:      A string or name of a variable.
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
#: STDOUT:
#:      Help, usage, version (if explicitly requested).
#:
#: STDERR:
#:      Error messages.
#:
#: RETURN CODE:
#:		 0 TRUE
#:     1 FALSE
#:     2 Wrong number of parameters
#:     3 Positional parameters empty
#:     4 Not an indexed array
#:     5 No such subroutine
#=======================================================================
bb_is() {

#                                                                    ABOUT
#-------------------------------------------------------------------------
 local -r bbapp="${FUNCNAME[0]}"
 local -r bbnfo="[bing-bash] $bbapp v.0.32"
 local -r usage="USAGE: $bbapp --PATTERN STRING"

#                                                                 PRECHECK
#-------------------------------------------------------------------------
 if [[ $# -eq 0 ]]; then
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
	Pattern matching subroutines.

	CLASSES:
	   alpha - alphabetic characters [A-Za-z]
	   alnum - alphabetic or numeric characters [A-Za-z0-9]
	    word - letters, numbers and underscores [A-Za-z0-9_]
	   lower - lowercase alphabetic characters [a-z] (97-122)
	   upper - uppercase alphabetic characters [A-Z] (65-90)
	   digit - decimal digits [0-9] (48-57)
	  xdigit - hexadecimal digits [0-9A-Fa-f]
	   blank - all horizontal whitespace [SPACE, TAB, VT)
	   space - whitespace characters (SPACE, TAB, VT, NL, FF, CR)
	   ascii - ASCII characters
	   cntrl - control characters (0-31,127)
	   graph - printable characters, excluding space. ASCII range 33-126
	   print - all printable characters, including space. ASCII 32-126
	   punct - punctuation characters

	TYPES:
	       id - is string a valid identifier
	  integer - is string an integer
	    float - is string a float
	    range - is string a number range (e.g. 1,3-6,9,11-15)

	OPTIONS:
	          opt - check if string is either short or long option
	     opt-long - check if string is a long option (e.g. --an-example)
	    opt-short - check if string is a short option (e.g. -x)
	  opt-complex - check if string is a complex option (e.g.--dir=/bin)

	FILESYSTEM:
	     filename - is it POSIX compliant portable filename
	     pathname - is it POSIX compliant portable pathname
	        alias - is it POSIX compliant portable name for an alias

	SYMBOLS TABLE:
	          set - check if variable is set
	         null - check if variable is null
	     function - check if function is loaded
	        array - check if variable is array
	      indexed - check if array is indexed
	  associative - check if array is associative
	      numeric - check if array is numeric
	       packed - check if indexed array is packed
	       sparse - check if indexed array is a sparse

	EOFF
	return 0
 }

#                                                                      SET
#-------------------------------------------------------------------------
 shopt -s extglob extquote; shopt -u nocasematch; set -o noglob
 trap "set +o noglob" RETURN ERR SIGHUP SIGINT SIGTERM


#                                                                   CHECKS
#=========================================================================
 # Option
 if [[ -n "$1" ]]; then
   local bbOpt="$1"
   shift
   bbOpt="${bbOpt#--}"
   bbOpt="${bbOpt#-}"
 else
   printf "\e[2m%s: %s\e[0m\n" "$bbapp" \
    "Positional parameter empty" >&2
   printf "%s\n" "$usage" >&2
   return 3
 fi

 # Name
 if [[ -z "$1" ]]; then
   printf "\e[2m%s: %s\e[0m\n" "$bbapp" \
    "Positional parameter empty" >&2
   return 4
 fi



case $bbOpt in

#                                                                  CLASSES
#=========================================================================
  #
  # DESCRIPTION: 
  #    Check if characters belong to the following classes:
  #      alpha - alphabetic characters [A-Za-z]
  #      alnum - alphabetic or numeric characters [A-Za-z0-9]
  #       word - letters, numbers and underscores [A-Za-z0-9_]
  #      lower - lowercase alphabetic characters [a-z] (97-122)
  #      upper - uppercase alphabetic characters [A-Z] (65-90)
  #      digit - decimal digits [0-9] (48-57)
  #     xdigit - hexadecimal digits [0-9A-Fa-f]
  #      blank - all horizontal whitespace [SPACE, TAB, VT)
  #      space - whitespace characters (SPACE, TAB, VT, NL, FF, CR)
  #      ascii - ASCII characters
  #      cntrl - control characters (0-31,127)
  #      graph - printable characters, excluding space. ASCII range 33-126
  #      print - all printable characters, including space. ASCII 32-126
  #      punct - punctuation characters. Punctuation symbols:
  #              !"#$%&'()*+,-./ (ASCII: 33-47)
  #                      :;<=>?@ (ASCII: 58-64) 
  #                       [\]^_` (ASCII: 91-96) 
  #                         {|~} (ASCII: 123-127)
  # 
  alpha) [[ "$1" =~ ^[[:alpha:]]+$ ]]  && return 0;;
  alnum) [[ "$1" =~ ^[[:alnum:]]+$ ]]  && return 0;;
   word) [[ "$1" =~ ^[[:alnum:]_]+$ ]] && return 0;;
  lower) [[ "$1" =~ ^[[:lower:]]+$ ]]  && return 0;;
  upper) [[ "$1" =~ ^[[:upper:]]+$ ]]  && return 0;;
  digit) [[ "$1" =~ ^[[:digit:]]+$ ]]  && return 0;;
 xdigit) [[ "$1" =~ ^[[:xdigit:]]+$ ]] && return 0;;
  blank) [[ "$1" =~ ^[[:blank:]]+$ ]]  && return 0;;
  space) [[ "$1" =~ ^[[:space:]]+$ ]]  && return 0;;
  ascii) [[ "$1" =~ ^[[:ascii:]]+$ ]]  && return 0;;
  cntrl) [[ "$1" =~ ^[[:cntrl:]]+$ ]]  && return 0;;
  graph) [[ "$1" =~ ^[[:graph:]]+$ ]]  && return 0;;
  print) [[ "$1" =~ ^[[:print:]]+$ ]]  && return 0;;
  punct) [[ "$1" =~ ^[[:punct:]]+$ ]]  && return 0;;

#                                                                    TYPES
#=========================================================================
  #
  # DESCRIPTION:
  #       id  Identifier i.e. name for variable. It must be composed of
  #           alnum and underscore chars, but number must not be 1st char.
  #      int  Check if input is positive or negative integer.
  #    float  Check if input is a float (e.g. 1.1).
  #    range  Check if input number is a range (e.g. 1-10).
  #     
     id) [[ "$1" =~ ^[[:alpha:]_][[:alnum:]_]*$ ]]     && return 0;;
    int) [[ "$1" =~ ^-?[[:digit:]]+$ ]]                && return 0;;
  float) [[ "$1" =~ ^-?[[:digit:]]+\.[[:digit:]]+$ ]]  && return 0;;
  range) [[ "$1" =~ ^[[:digit:]]+-[[:digit:]]+$ ]]     && return 0;;
 # number) 
      # allowed chars: 0-9 , . - (^ e E)
      # -?\.?(\d+)(([\.,eE]\d+)+)?
      # [[ ! "$1" =~ ^[[:digit:],\.-]+$ ]] && return 1
      # [[ "$1" =~ ^-?\.?[[:digit:]]+([\.,eE]?[[:digit:]]+)?$ ]] && return 0
      # ;;

#                                                               FILESYSTEM
#=========================================================================
  #
  # DESCRIPTION:
  #     
  #    filename  Check if STRING is a valid POSIX compliant portable
  #              filename [A-Za-z0-9.-_] (hyphen must not be 1.char).
  #     
  #    pathname  Check if STRING is a valid POSIX compliant portable
  #              pathname [A-Za-z0-9.-_/]
  #     
  #       alias  Check if STRING is a valid POSIX compliant portable
  #              name for alias [A-Za-z0-9.-_/!%,@]
  #     
  filename) [[ "$1" =~ ^[[:alnum:]\._][[:alnum:]\._-]*$ ]] && return 0;;

  pathname) [[ "$1" =~ ^[[:alnum:]\.\/_-]+$ ]] && return 0;;

     alias) [[ "$1" =~ ^[[:alnum:]\.\/_!@%,-]+$ ]] && return 0;;

#                                                                  OPTIONS
#=========================================================================
  #
  #   DESCRIPTION: 
  #      opt-short  Check if STRING is a short option (e.g. -t)
  #       opt-long  Check if STRING is a long option (e.g. --long-option)
  #            opt  Check if STRING is a short or long option
  #    opt-complex  Check if STRING is a complex option
  #                 (e.g. --file-name=/bin/name)
  #
  opt-short) [[ "$1" =~ ^-[[:alpha:]]$ ]] && return 0;;
  opt-long) [[ "$1" =~ ^--[[:alpha:]][[:alpha:]-]+$ ]] && return 0;;
  opt) [[ "$1" =~ ^-[[:alpha:]]$ ]] || \
        [[ "$1" =~ ^--[[:alpha:]][[:alpha:]-]+$ ]] && return 0;;
  opt-complex)
  [[ "$1" =~ ^--?[[:alnum:]-]+([:=][[:alnum:]\+\./_-]+)?$ ]] && return 0;;

#                                                                VARIABLES
#=========================================================================
  #
  #  DESCRIPTION: 
  #
  #        set  Check if VAR is set (but it can be null)
  #       null  Check if VAR is set and not null
  #   function  Check if FUNCTION is loaded
  #
  set) [[ -n "$(declare -p "$1" 2>/dev/null)" ]] && return 0;;

  null) [[ -z "${!1}" ]] && return 0;;

  function)
    if declare -F "$1" &>/dev/null; then
      return 0
    fi
 ;;

#                                                                   ARRAYS
#=========================================================================
 array|indexed|associative|numeric|sparse|packed)
  #
  local bbFlag
  # Check input param is an array
  if ! bbFlag=$(declare -p "$1" 2>/dev/null); then
    printf "\e[2m%s: %s\e[0m\n" "$bbapp" \
     "Variable $1 is not set" >&2
    return 1
  fi
  bbFlag=( $bbFlag )
  if [[ ! "${bbFlag[1]}" =~ ^-[aA] ]]; then
    printf "\e[2m%s: %s\e[0m\n" "$bbapp" \
     "Parameter $1 is not an array" >&2
    return 1
  fi

  #                                         IS ARRAY
  #-------------------------------------------------
  #
  #  USAGE: 
  #      bb_is --array VAR
  #  
  #  DESCRIPTION: 
  #      Check if VAR is an array.
  # 
  [[ $bbOpt == array ]] && return 0

  #                                   IS ASSOCIATIVE
  #-------------------------------------------------
  #
  #  USAGE: 
  #      bb_is --associative ARRAY
  #  
  #  DESCRIPTION: 
  #      Check if ARRAY is associative array.
  # 
  if [[ $bbOpt == associative ]]; then
    [[ "${bbFlag[1]}" =~ ^-A ]] && return 0
  fi

  #                                       IS INDEXED
  #-------------------------------------------------
  #
  #  USAGE: 
  #      bb_is --indexed ARRAY
  #  
  #  DESCRIPTION: 
  #      Check if ARRAY is indexed array.
  # 
  if [[ $bbOpt == indexed ]]; then
    [[ "${bbFlag[1]}" =~ ^-a ]] && return 0
  fi


  #                                       IS NUMERIC
  #-------------------------------------------------
  #
  #  USAGE: 
  #      bb_is --numeric ARRAY
  #  
  #  DESCRIPTION: 
  #      Check if ARRAY is numeric array. All values
  #      must be integers (but empty elements allowed).
  # 
  if [[ $bbOpt == numeric ]]; then
    local bbVal
    local -n bbArrayRef="$1"
    for bbVal in "${bbArrayRef[@]}"; do
      [[ -z "$bbVal" ]] && continue
      [[ ! "$bbVal" =~ ^-?[[:digit:]]+$ ]] && return 1
    done
    return 0
  fi





  #                                       IF INDEXED
  #-------------------------------------------------
  # These checks are for indexed arrays only.
  # 
  # Indexed array can be:
  #    PACKED   starts from index 0 AND has contiguous indices
  #    SPARSE   if not packed
  # 
  if [[ "${bbFlag[1]}" =~ ^-a ]]; then
  # 
  # 
  
    #                                 IS PACKED/SPARSE
    #-------------------------------------------------
    #
    #  USAGE:
    #      bb_is --sparse|--packed ARRAY
    #
    #  DESCRIPTION:
    #      Check if ARRAY is sparse. Array is sparse if it
    #      does not start from index 0 AND does not have
    #      contiguous indices. Otherwise, it is packed.
    #
    if [[ $bbOpt == sparse || $bbOpt == packed ]]; then
      
      local bbCnt bbKeys bbSeq
      local -n bbArrayRef="$1"

      # count elements minus 1 to get max key value
      bbCnt=${#bbArrayRef[@]}
      # echo "Cnt: $bbCnt"
      ((--bbCnt))
      # generate sequence from 0 to max key
      bbSeq="$(eval echo {0..$bbCnt})"
      # echo "Seqs: $bbSeq"

      # generate sequence of array keys
      bbKeys="${!bbArrayRef[@]}"
      # echo "Keys: $bbKeys"

      # compare sequences
      if [[ $bbOpt == packed ]]; then
        [[ "$bbKeys" == "$bbSeq" ]] && return 0
      fi

      if [[ $bbOpt == sparse ]]; then
        [[ "$bbKeys" != "$bbSeq" ]] && return 0
      fi

      return 1
    fi
  
  else
    printf "\e[2m%s: %s\e[0m\n" "$bbapp" "Not an indexed array" >&2
    return 4
  fi # end group of checks for indexed arrays only

 return 1 # return false for arrays cases

 ;; # end the arrays cases


*) return 5;; # unknown subroutine

esac

} # $BING_FUNC/is.bash





# ** for arrays
# When is an array empty?
# There's bug in bash 4.3 (fixed in 4.4-beta), so declared array:
#    declare -a ARRAY
# although present in symbols table:
#    declare -p
#    -> ... declare -a arrayname='()' ...
# comes up as unset when checked alone with 
#    declare -p ARRAY
#    -bash: declare: arrayname: not found
# BUT declaring an empty array:
#    declare -a ARRAY=()
# does work and it comes up, as expected, when checked with:
#    declare -p ARRAY
#    -> declare -a arr1='()'
