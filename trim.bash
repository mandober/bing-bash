#!/bin/bash bingmsg
#==================================================================
#: FILE: trim.bash
#: PATH: $BING/func/trim.bash
#: TYPE: function
#:
#: AUTHOR:
#:      bing-bash by mandober <zgag@yahoo.com>
#:      https://github.com/mandober/bing-bash
#:      za Ǆ - Use freely at own's risk
#:      3-Mar-2016 (last revision)
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: NAME: 
#:      bb_trim
#:
#: DESCRIPTION:
#:      Trim leading, trailing and intermediate whitespace
#:      off variable. Whitespace: new line, tab and space
#:
#: DEPENDENCIES:
#:      -
#:
#: EXAMPLE:
#:      bb_trim 52
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: SYNOPSIS:
#:      bb_err ERRCODE
#:
#: OPTIONS: 
#:      (no options)
#:
#: PARAMETERS:
#:      <integer> ERRCODE - error number
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: STDOUT:
#:      <nothing>
#:
#: STDERR:
#:      Error message
#:      Debug message (if debugging enabled)
#:
#: RETURN CODE:
#:		0  (no errors)
#:	    55 Positional parameters error
#==================================================================

bb_trim() {
local bbapp="${FUNCNAME[0]}"
local bbnfo="[bing-bash] $bbapp v.0.9"
local usage="USAGE: $bbapp STRING"

[[ $# -ne 1 ]] && { bb_err 52; echo "$usage" >&2; return 52; }

[[ $1 =~ ^(--usage)$ ]] && { echo "$usage"; return 0; }
[[ $1 =~ ^(--version)$ ]] && { echo "$bbnfo"; return 0; }
[[ $1 =~ ^(--help)$ ]] && {
	cat <<-EOFF
	$bbnfo
	Trim function
	$usage
	Trim leading, trailing and intermediate whitespace off variable.
	OPTIONS:
	   --help        Show program help.
	   --usage       Show program usage.
	   --version     Show program version.
	EOFF
	return 0
}

### READY
set -o noglob
trap "set +o noglob" RETURN ERR SIGHUP SIGINT SIGTERM


### PROCESS
case $# in
0) bb_err 51; echo "$usage" >&2; return 51;;
 
1) local bbVal="$1"
	bbVal="${bbVal//\\t}"
	bbVal="${bbVal//\\v}"
	bbVal="${bbVal//\\n}"
	bbVal="${bbVal//\\r}"
	bbVal="${bbVal//\\f}"
	bbVal="${bbVal//\\a}"
	bbVal="${bbVal//\\b}"
	bbVal="${bbVal//\\c}"
	bbVal="${bbVal//\\e}"
	bbVal="${bbVal//\\E}"
;;
 
2)	#@TODO
	local bbOpt="$1"
	local bbVal="$2"
	local bbOptString=abceEfnrtv
	[[ ! "$bbOpt" =~ ^[-+][$bbOptString]+$ ]] && return 55
	bbSign="${bbOpt:0:1}"
	# bbSign= -|+
	
	# trims STRING (= trims -abceEfnrtv STRING)
	# trims ALL control chrs

	# trims +tn STRING (= trims -abceEfrv STRING)
	# trim all control chrs EXCEPT t and n
	
	# trims -tn STRING (= trims +abceEfrv STRING)
	# trim just t and n

	bbOpt="${bbOpt#?}"
	local -i n="${#bbOpt}"
	local j

	if [[ "_$bbSign" = "_+" ]]; then
		bbOpt="$(venn "$bbOptString" -a "$bbOpt")"
	fi
	echo $bbOpt

	# remove contr.chars
	for (( j=0; j<=n-1; j++ )) { 
		bbOptSingle="${bbOpt:$j:1}"
		case $bbOptSingle in
		    a) bbVal="${bbVal//\\a}";;
		    b) bbVal="${bbVal//\\b}";;
		    c) bbVal="${bbVal//\\c}";;
		    e) bbVal="${bbVal//\\e}";;
		    f) bbVal="${bbVal//\\f}";;
		    n) bbVal="${bbVal//\\n}";;
		    r) bbVal="${bbVal//\\r}";;
		    t) bbVal="${bbVal//\\t}";;
		    v) bbVal="${bbVal//\\v}";;
		    E) bbVal="${bbVal//\\E}";;
		    *) return 55;;
		esac
	}

;;
 
*) bb_err 52; echo "$usage" >&2; return 52;;

esac



bbArray=( $bbVal )
bbVal="$(printf "%s " "${bbArray[@]}")"
bbVal="${bbVal% }"
printf "%s" "${bbVal}"

## return code
# if original string is equal to trimmed string, return 1 (in fact a failiure
# since `trim' didn't trim the string). If the string was trimmed return 0 
# (success). Since there's only 1 success code (0), return that also in case
# the string was trimmed down to empty string (null).
[[ "$1" = "$bbVal" ]] && return 1
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

}
typeof "${BASH_SOURCE[@]}"
bbtrim "$@"
unset -f bbtrim
