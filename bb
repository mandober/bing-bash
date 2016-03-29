#!/bin/bash bingmsg
#=======================================================================
#: FILE: bb
#: PATH: $BING/func/bb
#: TYPE: internal function
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: AUTHOR:
#:      bing-bash by Ivan Ilic <ivanilic1975@gmail.com>
#:      https://github.com/mandober/bing-bash
#:      za Ǆ - Use freely at owns risk
#:      26-Mar-2016 (last revision)
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
#:      Unload (unset) the called function when done.
#:      Actually, when using function autoloading substitute functionality
#:      this function is not particularly useful. 
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
#:      6  Variable not set
#:      8  No such function
#:      9  Parameter empty
#=======================================================================

bb () {

#                                                                   ABOUT
#                                                                   =====
 local -r bbapp="${FUNCNAME[0]}"
 local -r bbnfo="[bing-bash] $bbapp v.0.6"
 local -r usage="USAGE: $bbapp FUNCTION"

#                                                                PRECHECK
#                                                                ========
 if [[ $# -eq 0 ]]; then
   printf "\e[2m%s: %s\e[0m\n" "$bbapp" "Parameter empty" >&2
   printf "%s\n" "$usage" >&2
   return 9
 fi

#                                                                    HELP
#                                                                    ====
	[[ $1 =~ ^(-u|--usage)$ ]] && { printf "%s" "$usage\n"; return 0; }
	[[ $1 =~ ^(-v|--version)$ ]] && { printf "%s" "$bbnfo\n"; return 0; }
	[[ $1 =~ ^(-h|--help)$ ]] && {
	cat <<-EOFF
	$bbnfo
	  Functions dispatcher.
	$usage
	  Source and call the appropriate function and pass arguments to it;
	  unload called function when done. This function is not particularly
	  useful when using function autoloading; on the other hand, during
	  tinkering with the function's code it can be usefull as it always
	  loads the most recent function's definition from file.
	OPTIONS:
	   -h, --help        Show program help.
	   -u, --usage       Show program usage.
	   -v, --version     Show program version.
	EOFF
	return 0
}

#                                                                    SET
#                                                                    ===
 shopt -s extglob     # Enable extended regular expressions
 shopt -s extquote    # Enables $'' and $"" quoting
 shopt -u nocasematch # regexp case-sensitivity
 set -o noglob        # Disable globbing. Enable it upon return:
 trap "set +o noglob" RETURN ERR SIGHUP SIGINT SIGTERM


#                                                                PROCESS
#                                                                =======
case $1 in

 typeof)
  shift
  . "$BING_FUNC/typeof.bash"
  bb_typeof "$@"
  unset -f bb_typeof
 ;;

 explode) shift; . "$BING_FUNC/explode.bash"; bb_explode "$@"; unset -f bb_explode;;
 implode) shift; . "$BING_FUNC/implode.bash"; bb_implode "$@"; unset -f bb_implode;;
 
 range) shift; . "$BING_FUNC/implode.bash"; bb_implode "$@"; unset -f bb_implode;;
 
 array_clone) 
  shift; . "$BING_FUNC/array_clone.bash";
  bb_array_clone "$@"; unset -f bb_array_clone;;
  
 array_convert) 
  shift; . "$BING_FUNC/array_convert.bash";
  bb_array_convert "$@"; unset -f bb_array_convert;;



 *) return 8;;

esac
}


# git add README.md bing-bash bb bing_aliases bing_samples
# git add typeof.bash explode.bash implode.bash range.bash
# git add array_clone.bash

# git commit -m "bingo"
# git push -u origin master
