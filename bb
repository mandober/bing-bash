#!/bin/bash sourceme
#=======================================================================
#: FILE: bb
#: PATH: $BING_FUNC/bb
#: TYPE: internal function
#:   NS: shell:bash:mandober:bing-bash:function:bb
#:  CAT: system
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: AUTHOR:
#:      bing-bash by Ivan Ilic <ivanilic1975@gmail.com>
#:      https://github.com/mandober/bing-bash
#:      za Ǆ - Use freely at owns risk
#:      7-Mar-2016 (last revision)
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: NAME: 
#:      bb
#:
#: BRIEF:
#:      Function dispatcher.
#:
#: DESCRIPTION:
#:      Source and call the appropriate function and pass arguments to it.
#:      Unload (unset) the called function when done. When using this, pass
#:      parameter i.e. function to call without the prefix `bb_`. 
#:
#: DEPENDENCIES:
#:      none
#:
#: EXAMPLE:
#:      bb range ARGS...  # will load bb_range function and pass args
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: SYNOPSIS:
#:      bb FUNCTION ARGS
#:
#: OPTIONS:
#:      none
#:
#: PARAMETERS:
#:      FUNCTION <string>
#:      Name of the function to source.
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: STDOUT:
#:      Help, usage, version (if explicitly requested).
#:
#: STDERR:
#:      Error messages.
#:
#: RETURN CODE:
#:      0  success
#:      1  Access problem or no such function
#:      2  No such function
#=======================================================================
bb () {

#                                                                    ABOUT
#-------------------------------------------------------------------------
 local -r bbapp="${FUNCNAME[0]}"
 local -r bbnfo="[bing-bash] $bbapp v.0.0.8"
 local -r usage="USAGE: $bbapp FUNCTION ARGS"

#                                                                 PRECHECK
#-------------------------------------------------------------------------
 if [[ $# -eq 0 ]]; then
   printf "\e[2m%s: %s\e[0m\n" "$bbapp" "Parameter empty" >&2
   printf "%s\n" "$usage" >&2
   return 9
 fi

#                                                                     HELP
#-------------------------------------------------------------------------
 [[ $1 =~ ^(-u|--usage)$ ]] && { printf "%s" "$usage\n"; return 0; }
 [[ $1 =~ ^(-v|--version)$ ]] && { printf "%s" "$bbnfo\n"; return 0; }
 [[ $1 =~ ^(-h|--help)$ ]] && {
	printf "\e[7m%s\e[0m\n" "$bbnfo"
	printf "\e[1m%s\e[0m\n" "$usage"
	cat <<-EOFF
	Functions dispatcher.

	DESCRIPTION:
	  Source and call the appropriate function and pass arguments to it;
	  unload called function when done. When using this, pass parameter
	  i.e. function to call without the prefix 'bb_'.

	OPTIONS:
	   -h, --help        Show program help.
	   -u, --usage       Show program usage.
	   -v, --version     Show program version.
	EOFF
	return 0
 }

#                                                                      SET
#-------------------------------------------------------------------------
 shopt -s extglob     # Enable extended regular expressions
 shopt -s extquote    # Enables $'' and $"" quoting
 shopt -u nocasematch # regexp case-sensitivity
 set -o noglob        # Disable globbing. Enable it upon return:
 trap "set +o noglob" RETURN ERR SIGHUP SIGINT SIGTERM

# `bb' will load the passed function
# pass through the args and... then what?
# leave it alone, unload it or make it autoloadable?

#                                                                  PROCESS
#=========================================================================
local bbFunc
local bbReturn
bbFunc="${1#bb_}"
shift



case $bbFunc in

#                                BING-BASH ENV
#---------------------------------------------
env) bingenv;;

#                               BING-BASH CONF
#---------------------------------------------
list) bingenv --list;;


#                          FUNCTION DISPATCHER
#---------------------------------------------
$bbFunc)
  local bbFPath
  
  # check allowed chars
  [[ ! "$bbFunc" =~ [[:alnum:]\._-]+ ]] && return 4

  # resolve function's file path
  bbFPath="$(bb_load --resolve $bbFunc)"

  # if no such file
  if [[ ! -r "$bbFPath" ]]; then
    echo "No such file or no read permissions"
    return 1
  fi

  # source the function
  . "$bbFPath"

  # pass through the args
  bb_$bbFunc "$@"

  # catch function's return code
  bbReturn=$?

  # What now? Should the function
  # be left alone, unloaded or
  # reverted to autoloadable state?

  # unset the function
  # unset -f bb_$bbFunc

  # revert function to autoloadable state
  bb_load --auto $bbFunc

  # return catched code
  return $bbReturn
;;


*) return 2;;

esac

return 0

} # $BING_FUNC/bb
