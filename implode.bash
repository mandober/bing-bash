#!/bin/bash bingmsg
#=========================================================================
#: FILE: implode
#: PATH: $BING_FUNC/implode.bash
#: TYPE: function
#:   NS: shell:bash:mandober:bing-bash:function:bb_implode
#:  CAT: variables
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: AUTHOR:
#:      bing-bash by Ivan Ilic <ivanilic1975@gmail.com>
#:      https://github.com/mandober/bing-bash
#:      za Ǆ - Use freely at owns risk
#:      30-Mar-2016 (last revision)
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: NAME:
#:      bb_implode
#:
#: BRIEF:
#:      Convert an array to a string.
#:
#: DESCRIPTION:
#:      Convert an array into a string by inserting GLUE char(s)
#:      after each element, skipping array's null elements.
#:      * If not supplied GLUE defaults to space.
#:      * If NAME is not supplied it defaults to BING_IMPLODED.
#:
#: DEPENDENCIES:
#:      none
#:
#: EXAMPLE:
#:      bb_implode linux
#:      bb_implode BASH_VERSINFO -o aux
#:      bb_implode linux -g=':' -oaux
#:
#:      bb_implode linux -p \` -s \' -g, -o9
#:      # implode array linux by prefixing each element with tick (`)
#:      # suffixing each with quote (') and inserting comma (,) between each
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: SYNOPSIS:
#:      implode ARRAY [-g GLUE] [-w WRAP] [-o NAME]
#:      * order of parameters is not important
#:
#: OPTIONS:
#:      -g, --glue <option> GLUE <argument>
#:      With -g option user can specify char(s), that will be
#:      inserted after each element, after equal sign (e.g. -g='"')
#:      or as a following argument (e.g. -g '"').
#:      GLUE <char> <required> <argument> 
#:      Character(s) that will be inserted after each array element.
#:      This agrument is mandatory if -g option is specified.
#:
#:      -w, --wrap <option> WRAP <argument>
#:      With -w option user can specify char(s), that will be used as
#:      element's wrapping i.e. they will be inserted before and after
#:      each element. This argument is mandatory for -w option and it
#:      can be specified after equal sign (e.g. -g=':') or as the
#:      following argument (e.g. -g ', ').
#:      WRAP <char> <required> <argument>
#:      Substring composed of single or muliple characters that will
#:      be wrapped around each array element.
#:
#: PARAMETERS:
#:
#:      ARRAY <array>
#:      Array to implode. It is the only required parameter.
#:      Arrays must always be passed by name (without $).
#:
#:      NAME <identifier>
#:      Identifier for resulting string.
#:      If not given the default is BING_IMPLODED.
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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
#:      2  Invalid identifier
#:      4  Parameter is not an array
#:      9  Parameter empty
#=========================================================================
bb_implode() {

#                                                                    ABOUT
#-------------------------------------------------------------------------
 local -r bbapp="${FUNCNAME[0]}"
 local -r bbnfo="[bing-bash] $bbapp v.0.21"
 local -r usage="USAGE: $bbapp [-g GLUE] [-w WRAP]\
 [-s SUF] [-p PRE] [-o OUT] ARRAY"

#                                                                 PRECHECK
#-------------------------------------------------------------------------
  if [[ $# -eq 0 ]]; then
    printf "\e[2m%s: %s\e[0m\n" "$bbapp" "Parameter empty" >&2
    printf "%s\n" "$usage" >&2
    return 9
  fi

#                                                                     HELP
#-------------------------------------------------------------------------
 [[ $1 =~ ^(--version)$ ]] && { printf "%s\n" "$bbnfo"; return 0; }
 [[ $1 =~ ^(-u|--usage)$ ]] && { printf "%s\n" "$usage"; return 0; }
 [[ $1 =~ ^(-h|--help)$ ]] && {
 printf " \e[38;5;186m%s\e[0m\n" "$bbnfo"
 printf " \e[38;5;228m%s\e[0m\n" "$usage"
 echo " Convert an array to a string.

 \e[38;5;186mDESCRIPTION:\e[0m
   Convert an array into a string by inserting GLUE between
   elements, prefixing each with PRE, suffixing each with SUF,
   wrapping each element with WRAP chars, but skipping array's 
   null elements. If not supplied GLUE defaults to space.
   If NAME of resulting string is not supplied, NAME defaults to
   BING_IMPLODED.

 \e[38;5;186mOPTIONS:\e[0m
   -o, --out         Output variable of FD number.
   -g, --glue        Binding string.
   -p, --prefix      Prefix string.
   -s, --suffix      Suffix string.
   -w, --wrap        Wrapping string.

   -v, --verbose     Show program help.
   -h, --help        Show program help.
   -u, --usage       Show program usage.
       --version     Show program version.

 \e[38;5;186mEXAMPLE:\e[0m
   $bbapp BASH_VERSINFO ':' -obver
   $bbapp  linux -p \` -s \' -g, -o9
   \e[2m# implode array linux by prefixing each element with tick (\`)
   # suffixing each with quote (') and inserting comma (,) between each\e[0m
 "
 return 0
 }

#                                                                      SET
#-------------------------------------------------------------------------
 shopt -s extglob extquote; shopt -u nocasematch; set -o noglob
 trap "set +o noglob" RETURN ERR SIGHUP SIGINT SIGTERM


#                                                                   ASSIGN
#=========================================================================
local bbInput   # input array's name
local bbOut     # output variable's name
local bbGlue    # chars to use as glue
local bbWrap    # chars to use to wrap each element
local bbPre     # chars to use to prefix each element
local bbSuf     # chars to use to suffix each element
local bbV       # verbosity level (0|1|2|3) quiet|error|fatal|debug

while (( $# > 0 )); do
  case $1 in
    -v=*|--verbose=*) bbV="${1#*=}";;
        -v|--verbose) bbV="${2?}"; shift;;
                 -v*) bbV="${1#??}";;

        -o=*|--out=*) bbOut="${1#*=}";;
            -o|--out) bbOut="${2?}"; shift;;
                 -o*) bbOut="${1#??}";;

       -g=*|--glue=*) bbGlue="${1#*=}";;
           -g|--glue) bbGlue="${2?}"; shift;;
                 -g*) bbGlue="${1#??}";;

       -w=*|--wrap=*) bbWrap="${1#*=}";;
           -w|--wrap) bbWrap="${2?}"; shift;;
                 -w*) bbWrap="${1#??}";;

     -p=*|--prefix=*) bbPre="${1#*=}";;
         -p|--prefix) bbPre="${2?}"; shift;;
                 -p*) bbPre="${1#??}";;

     -s=*|--suffix=*) bbSuf="${1#*=}";;
         -s|--suffix) bbSuf="${2?}"; shift;;
                 -s*) bbSuf="${1#??}";;

   --) shift; bbInput="$1"; set --;;

    *) bbInput="$1";;

  esac
  shift
done

((bbV==2)) && {
  echo "ASSIGN:"
  echo "Verbosity: $bbV"
  echo "Out: $bbOut"
  echo "Glue: $bbGlue"
  echo "Wrap: $bbWrap"
  echo "Prefix: $bbPre"
  echo "Suffix: $bbSuf"
  echo "Input: $bbInput"
}>&2

#                                                                   CHECKS
#=========================================================================

#                                           OUTPUT
#-------------------------------------------------
case $bbOut in
  [[:alpha:]_]*([[:alnum:]_]) ) bbOut="$bbOut";;
  [1-9] ) bbOut="$bbOut";;
  "") bbOut=BING_IMPLODED;;
   *) printf "\e[2m%s: %s\e[0m\n" "$bbapp" "Invalid identifier $bbOut" >&2
      return 2;;
esac

((bbV==2)) && {
  echo "CHECKS:"
  echo "Out: $bbOut"
}>&2

#                                            INPUT
#-------------------------------------------------
# Check param is an array
local bbFlag

if bbFlag=$(declare -p "$bbInput" 2>/dev/null); then
  bbFlag=( $bbFlag )
  if [[ ! "${bbFlag[1]}" =~ ^-[aA] ]]; then
    printf "\e[2m%s: %s\e[0m\n" "$bbapp" "Parameter is not an array" >&2
    return 4
  fi
fi

# input array
local -n bbInputRef="$bbInput"

((bbV==2)) && {
  echo "Input: $bbInput"
  bb_typeof $bbInput
}>&2

#                                                                  IMPLODE
#=========================================================================
local bbVal bbString=""

for bbVal in "${bbInputRef[@]}"; do
	# skip null elements
	[[ -z "$bbVal" ]] && continue
  # add wrap + element + wrap + glue
  bbString+="${bbWrap}${bbPre}${bbVal}${bbSuf}${bbWrap}${bbGlue}"
done

# remove trailing glue
bbString="${bbString%$bbGlue}"

#                                           OUTPUT
#-------------------------------------------------
case $bbOut in
  1) # output result to FD1
    echo -en "\e[2mfd$bbOut: \e[0m" >&2
    echo "$bbString"
  ;;

  2) # output result to FD2
    echo -en "\e[2mfd$bbOut: " >&2
    echo "$bbString\e[0m" >&2
  ;;

  # 3) # output result to FD3
  #   echo -en "\e[33mfd$bbOut: \e[0m" >&2
  #   eval exec 3>&1
  #   echo "$bbString" >&3
  #   # echo "fd1: $bbString" 3>&1
  # ;;

  [3-9]) # output result to FD 3-9
    echo -en "\e[38;5;${bbOut}mfd$bbOut: \e[0m" >&2
    eval exec "$bbOut>&1"
    echo "$bbString" >&$bbOut
  ;;

  *) # Assign results to var
     read -r "$bbOut" <<< "$bbString"
  ;;
esac

return 0

} # $BING_FUNC/implode.bash

# fd3="$(bb_implode linux -o3 3>/dev/stdout 1>/dev/null 2>/dev/null)"
# fd3="$(bb_implode linux -o3 3>&1 1>/dev/null 2>/dev/null)"
# fd3="$(bb_implode linux -o3 3>&1 1>/dev/null 2>&1)"
# echo "$fd3"
