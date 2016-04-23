#!/bin/bash bingmsg
#=======================================================================
#: FILE: trim.bash
#: PATH: $BING_FUNC/strings/trim.bash
#: TYPE: function
#:       shell:bash:mandober:bing-bash:function:bb_trim
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: AUTHOR:
#:      bing-bash by Ivan Ilic <ivanilic1975@gmail.com>
#:      https://github.com/mandober/bing-bash
#:      za Ǆ - Use freely at owns risk
#:      1-Apr-2016 (last revision)
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: NAME: 
#:      bb_trim
#:
#: BRIEF:
#:      Trim string.
#:
#: DESCRIPTION:
#:      Trim leading, trailing and intermediate whitespace
#:      off variable. Whitespace: new line, tab and space.
#:
#: DEPENDENCIES:
#:      none
#:
#: EXAMPLE:
#:      bb_trim "abcdef"
#:      bb_trim "$var"
#:      bb_trim $var
#:      bb_trim var
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: SYNOPSIS:
#:      bb_trim STRING
#:
#: OPTIONS: 
#:      none
#:
#: PARAMETERS:
#:      STRING <string>
#:      String to trim.
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: STDOUT:
#:      none
#:
#: STDERR:
#:      Error messages.
#:
#: RETURN CODE:
#:      0  great success
#:      1  miserable failure
#:      9  Parameter error
#=======================================================================

bb_trim() {

#                                                                  ABOUT
#                                                                  =====
 local -r bbapp="${FUNCNAME[0]}"
 local -r bbnfo="[bing-bash] $bbapp v.0.0.8"
 local -r usage="USAGE: $bbapp [±vEteranfc] STRING"

#                                                               PRECHECK
#                                                               ========
  if [[ $# -eq 0 ]]; then
    printf "\e[2m%s: %s\e[0m\n" "$bbapp" "Parameter error" >&2
    printf "%s\n" "$usage" >&2
    return 9
  fi

#                                                                   HELP
#                                                                   ====
 [[ $1 =~ ^(-u|--usage)$ ]] && { printf "%s\n" "$usage"; return 0; }
 [[ $1 =~ ^(-V|--version)$ ]] && { printf "%s\n" "$bbnfo"; return 0; }
 [[ $1 =~ ^(-h|--help)$ ]] && {
	cat <<-EOFF
	$bbnfo
	  Trim a string.
	$usage
	  Trim leading, trailing and intermediate whitespace off string.
	OPTIONS:
	   --help        Show program help.
	   --usage       Show program usage.
	   --version     Show program version.
	EOFF
	return 0
 }

#                                                                    SET
#                                                                    ===
 shopt -s extglob extquote; shopt -u nocasematch; set -o noglob
 trap "set +o noglob" RETURN ERR SIGHUP SIGINT SIGTERM


#                                                                 PARAMS
#                                                                 ======
local bbOpt bbString

# ASSIGN PARAMS
while [[ -n "${1+def}" ]]; do
  case $1 in
    # options
    # [-+]+([v|E|t|e|r|a|n|f|c]) )
    [-+]+([[:alpha:]]) )
      bbOpt="$1"
    ;;

    # string
    --)
      # end of options
      bbString="$2"
      set --
    ;;

    *)
      # passed by value
      bbString="$1"
      # passed by name
      declare -p "$1" &>/dev/null && bbString="${!1}"
    ;;
  esac
  shift
done


# v|E|t|e|r|a|n|f|c
echo "bbOpt: :$bbOpt:"
echo "String: :$bbString:"
# vEteranfc


# =================
local bbCntrl bbGetOpt
bbCntrl="vEteranfc"
if bbGetOpt="$(getopt -q -- $bbCntrl "$bbOpt")"; then
	echo "GetOpt: »$bbGetOpt«"
fi


return 
# =================





local bbOpt1="vEteranfc"
local bbOpt2="v|E|t|e|r|a|n|f|c"


case $bbOpt in

# -[vEteranfc])
\+*([v|E|t|e|r|a|n|f|c]) )
	echo +
	bbString="${bbString//[[:space:]]}"
	# bbString="${bbString//[![:print:]]}"
	bbString="${bbString//[vEteranfc]}"
;;

-+([v|E|t|e|r|a|n|f|c]) )
	echo -
	bbString="${bbString//[[:space:]]}"
	# bbString="${bbString//[![:print:]]}"
	bbString="${bbString//[vEteranfc]}"
;;

*v*) [[ ! "$bbOpt" =~ ^\+ ]] && bbString="${bbString//\\v}";;&
*t*) [[ ! "$bbOpt" =~ ^\+ ]] && bbString="${bbString//\\t}";;&
*e*) [[ ! "$bbOpt" =~ ^\+ ]] && bbString="${bbString//\\e}";;&
*r*) [[ ! "$bbOpt" =~ ^\+ ]] && bbString="${bbString//\\r}";;&
*a*) [[ ! "$bbOpt" =~ ^\+ ]] && bbString="${bbString//\\a}";;&
*n*) [[ ! "$bbOpt" =~ ^\+ ]] && bbString="${bbString//\\n}";;&
*f*) [[ ! "$bbOpt" =~ ^\+ ]] && bbString="${bbString//\\f}";;&
*c*) [[ ! "$bbOpt" =~ ^\+ ]] && bbString="${bbString//\\c}";;&
*E*) [[ ! "$bbOpt" =~ ^\+ ]] && bbString="${bbString//\\E}";;&

"")
	bbString="${bbString//[[:space:]]}"
	# bbString="${bbString//[![:print:]]}"
	bbString="${bbString//[vEteranfc]}"
;;

# xxx)
	# local bbOptString=abceEfnrtv
	# [[ ! "$bbOpt" =~ ^[-+][$bbOptString]+$ ]] && return 55
	# bbSign="${bbOpt:0:1}"
	# bbSign= -|+
	
	# trims STRING (= trims -abceEfnrtv STRING)
	# trims ALL control chrs

	# trims +tn STRING (= trims -abceEfrv STRING)
	# trim all control chrs EXCEPT t and n
	
	# trims -tn STRING (= trims +abceEfrv STRING)
	# trim just t and n

	# bbOpt="${bbOpt#?}"
	# local -i n="${#bbOpt}"
	# local j

	# if [[ "_$bbSign" = "_+" ]]; then
	# 	bbOpt="$(venn "$bbOptString" -a "$bbOpt")"
	# fi
	# echo $bbOpt

	# remove contr.chars
 #  	for (( j=0; j<=n-1; j++ )) { 
 # 		bbOptSingle="${bbOpt:$j:1}"

 # 		case $bbOptSingle in
 # 		    a) bbString="${bbString//\\a}";;
 # 		    b) bbString="${bbString//\\b}";;
 # 		    c) bbString="${bbString//\\c}";;
 # 		    e) bbString="${bbString//\\e}";;
 # 		    f) bbString="${bbString//\\f}";;
 # 		    n) bbString="${bbString//\\n}";;
 # 		    r) bbString="${bbString//\\r}";;
 # 		    t) bbString="${bbString//\\t}";;
 # 		    v) bbString="${bbString//\\v}";;
 # 		    E) bbString="${bbString//\\E}";;
 # 		    *) return 55;;
 # 		esac
 # 	}
# ;;
 
esac

bbString="${bbString//+([[:space:]])/ }"
bbString="${bbString#+([[:space:]])}"
bbString="${bbString%+([[:space:]])}"
printf ":%s:\n" "${bbString}"
return

bbArray=( $bbString )
bbString="$(printf "%s " "${bbArray[@]}")"
bbString="${bbString% }"
printf ":%s:\n" "${bbString}"

## return code
# if original string is equal to trimmed string, return 1 (in fact a failiure
# since `trim' didn't trim the string). If the string was trimmed return 0 
# (success). Since there's only 1 success code (0), return that also in case
# the string was trimmed down to empty string (null).

# [[ "$1" = "$bbString" ]] && return 1
return 0


## Control characters (abceEfnrtv)

# \a   		alert (bell)
# \b   		backspace
# \c   		suppress further output
# \e		an escape character
# \E   		an escape character
# \f   		form feed
# \n   		new line
# \r   		carriage return
# \t   		horizontal tab
# \v   		vertical tab

} # $BING_FUNC/strings/trim.bash
