#!/bin/bash bingmsg
#==================================================================
#: FILE: err
#: PATH: $BING_FUNC/err
#: TYPE: function
#:
#: AUTHOR:
#:      bing-bash by mandober <zgag@yahoo.com>
#:      https://github.com/mandober/bing-bash
#:      za Ǆ - Use freely at owns risk
#:      11-Mar-2016 (last revision)
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: NAME: 
#:      bb_err
#:
#: BRIEF: 
#:      Display error message.
#:
#: DESCRIPTION:
#:      Display error messages. Also display debugging messages
#:      (if  debugging enabled). This function contains bb_ERRORS
#:      array that holds error messages for all functions used in
#:      this library.
#:
#: DEPENDENCIES:
#:      none
#:
#: EXAMPLE:
#:      bb_err 52 # prints: "Wrong number of positional parameters"
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: SYNOPSIS:
#:      bb_err ERRCODE
#:
#: PARAMETERS:
#:      ERRCODE <integer>
#:      Error code.
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: STDERR:
#:      Error (and debug) messages.
#:
#: RETURN CODE:
#:		0  ok
#:	    55 Positional parameters error
#==================================================================

bb_err() {
[[ $# -ne 1 ]] && { bb_err 55; return 55; }

# ERRORS ARRAY
local -a bb_ERRORS
bb_ERRORS[0]="SUCCESS"
bb_ERRORS[1]="ERROR"

bb_ERRORS[20]="Invalid identifier"
bb_ERRORS[30]="Out of range"

bb_ERRORS[35]="FPATH not set or null"

bb_ERRORS[48]="Parameter is not null"
bb_ERRORS[49]="Parameter is null"
bb_ERRORS[50]="Parameter null or not set"
bb_ERRORS[51]="Positional parameter absent"
bb_ERRORS[52]="Wrong number of positional parameters"
bb_ERRORS[53]="Positional parameter empty"
bb_ERRORS[54]="Wrong order of positional parameters"
bb_ERRORS[55]="Positional parameters error"

bb_ERRORS[58]="Parameter is not an indexed array"
bb_ERRORS[59]="Parameter is not an associative array"
bb_ERRORS[60]="Parameter is not set"
bb_ERRORS[61]="Invalid identifier"
bb_ERRORS[62]="Parameter is already an array"
bb_ERRORS[63]="Parameter is not an array"

bb_ERRORS[79]="Only indexed arrays can be packed"
bb_ERRORS[81]="No match"
bb_ERRORS[82]="Parameter is not declared"
bb_ERRORS[83]="ATTR not found - no such functionality"
bb_ERRORS[93]="File not found"
bb_ERRORS[111]="General error"
bb_ERRORS[193]="General function error"
bb_ERRORS[194]="Function not loaded"
bb_ERRORS[195]="Function error: no such subroutine"
bb_ERRORS[197]="Function error: 'array'"
bb_ERRORS[239]="No such function"
bb_ERRORS[241]="Not an valid option"


# ERROR MESSAGE
printf "\e[2m%s: [ERR%s] %s\e[0m\n" \
       "${FUNCNAME[1]}" "$1" "${bb_ERRORS[$1]}" >&2


# DEBUG MESSAGE
BING_DEBUG=${BING_DEBUG:-0}
if [[ $BING_DEBUG == 1 ]]; then
	printf "\e[38;5;240mLine: %s Function: %s (%s)\e[0m\n" \
	"${BASH_LINENO[0]}" "${FUNCNAME[1]}" "${BASH_SOURCE[1]}" >&2
fi

return 0
}
