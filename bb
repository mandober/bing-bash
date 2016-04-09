#!/bin/bash bingmsg
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
#:      Functions dispatcher.
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
#:      0  great success
#:      1  miserable failure
#:      2  No such function
#=======================================================================

bb () {

#                                                                    ABOUT
#-------------------------------------------------------------------------
 local -r bbapp="${FUNCNAME[0]}"
 local -r bbnfo="[bing-bash] $bbapp v.0.7"
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


#                                                                  PROCESS
#=========================================================================
local bbOpt
bbOpt="${1#bb_}"

case $bbOpt in

 typeof)
    shift; . "$BING_FUNC/typeof.bash"
    bb_typeof "$@"; unset -f bb_typeof;;

 explode) 
    shift; . "$BING_FUNC/explode.bash";
    bb_explode "$@"; unset -f bb_explode;;

 implode) 
    shift; . "$BING_FUNC/implode.bash";
    bb_implode "$@"; unset -f bb_implode;;
 
 array_clone) 
    shift; . "$BING_FUNC/array_clone.bash";
    bb_array_clone "$@"; unset -f bb_array_clone;;

 array_merge) 
    shift; . "$BING_FUNC/array_merge.bash";
    bb_array_merge "$@"; unset -f bb_array_merge;;

 array_convert) 
    shift; . "$BING_FUNC/array_convert.bash";
    bb_array_convert "$@"; unset -f bb_array_convert;;

 array_remove) 
    shift; . "$BING_FUNC/array_remove.bash";
    bb_array_remove "$@"; unset -f bb_array_remove;;

 array_shift) 
    shift; . "$BING_FUNC/array_shift.bash";
    bb_array_shift "$@"; unset -f bb_array_shift;;

 array_sort) 
    shift; . "$BING_FUNC/array_sort.bash";
    bb_array_sort "$@"; unset -f bb_array_sort;;

 in_array) 
    shift; . "$BING_FUNC/in_array.bash";
    bb_in_array "$@"; unset -f bb_in_array;;

 array) 
    shift; . "$BING_FUNC/array.bash";
    bb_array "$@"; unset -f bb_array;;

 range) 
    shift; . "$BING_FUNC/range.bash";
    bb_range "$@"; unset -f bb_range;;

 venn) 
    shift; . "$BING_FUNC/venn.bash";
    bb_venn "$@"; unset -f bb_venn;;
 
 strpos) 
    shift; . "$BING_FUNC/strpos.bash";
    bb_strpos "$@"; unset -f bb_strpos;;

 pad) 
    shift; . "$BING_FUNC/pad.bash";
    bb_pad "$@"; unset -f bb_pad;;

 trim) 
    shift; . "$BING_FUNC/trim.bash";
    bb_trim "$@"; unset -f bb_trim;;

 load) 
    shift; . "$BING_FUNC/load.bash";
    bb_load "$@"; unset -f bb_load;;

 is) 
    shift; . "$BING_FUNC/is.bash";
    bb_is "$@"; unset -f bb_is;;

 get) 
    shift; . "$BING_FUNC/get.bash";
    bb_get "$@"; unset -f bb_get;;

 to) 
    shift; . "$BING_FUNC/to.bash";
    bb_to "$@"; unset -f bb_to;;

 sql) 
    shift; . "$BING_FUNC/sql.bash";
    bb_sql "$@"; unset -f bb_sql;;

 *) return 2;;

esac

} # $BING_FUNC/bb
