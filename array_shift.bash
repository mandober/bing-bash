#!/bin/bash bingmsg
#==================================================================
#: FILE: array_shift
#: PATH: $BING/func/arrays/array_shift
#: TYPE: function
#:
#: AUTHOR:
#:      bing-bash by mandober <zgag@yahoo.com>
#:      https://github.com/mandober/bing-bash
#:      za Ǆ - Use freely at owns risk
#:      7-Mar-2016 (last revision)
#:
#: NAME: 
#:      array_shift
#:
#: BRIEF: 
#:      Shift array values.
#:
#: DESCRIPTION:
#:      Shifts the first value of the ARRAY off and 
#:      returns it, shortening the array by one element and moving
#:      everything down. Indexes, in indexed array, will be packed 
#:      (modified to start counting from zero). Keys in associative
#:      array will not be changed.
#:
#: DEPENDENCIES:
#:      bb_err
#:
#: EXAMPLE:
#:      array_shift ARRAY VAR
#:
#: SYNOPSIS:
#:      array_merge ARRAY_A ARRAY_B ARRAY
#:
#: OPTIONS: 
#:      
#:
#: PARAMETERS:
#:      <array> ARRAY_A - an array (indexed or associative)
#:
#: STDOUT:
#:      the shifted value (0), or null if array is empty or is not an array (1).
#:
#: STDERR:
#:      Error message
#:
#: RETURN CODE:
#:		0 - great success
#:	    not 0 - see err file
#==================================================================

array_shift() {

### ABOUT
local bbapp="${FUNCNAME[0]}"
local bbnfo="[bing-bash] $bbapp v.0.5"
local usage="USAGE: $bbapp ARRAY VAR"

### DEPENDENCIES

### PRECHECK
[[ $# -eq 0 ]] && { bb_err 51; printf "${usage}\n" >&2; return 51; }
[[ $# -gt 3 ]] && { bb_err 52; printf "${usage}\n" >&2; return 52; }

### HELP
[[ $1 =~ ^(-u|--usage)$ ]] && { printf "${usage}\n"; return 0; }
[[ $1 =~ ^(-v|--version)$ ]] && { printf "${bbnfo}\n"; return 0; }
[[ $1 =~ ^(-h|--help)$ ]] && {
	cat <<-EOFF
	$bbnfo
	  Shift array values.
	$usage

	EOFF
	return 0
}

### SET
 shopt -s extglob 		# Enable extended regular expressions
 shopt -s extquote		# Enables $'' and $"" quoting
 shopt -u nocasematch 	# regexp case-sensitivity
 set -o noglob			# Disable globbing. Enable it upon return:
 trap "set +o noglob" RETURN ERR SIGHUP SIGINT SIGTERM


### PARAMS

# 1) array_shift ARRAY NAME 
# 	 return 1st element, remove it from array and shift the rest down
#    put returned value in variable NAME
# 2) array_shift --left N ARRAY NAME
#    return Nth element, remove it from array and shift the rest down
# pop:
# 3) array_shift --right ARRAY NAME
#    return Nth element, remove it from array and shift the rest up
#

# array_push — Push one or more elements onto the end of array
# array_pop — Pop the element off the end of array
# array_shift — Shift an element off the beginning of array
# array_unshift — Prepend one or more elements to the beginning of an array

local bbArrayName="$1"
local -n bbArrayRef="$1"

local bbFirst="${2:-BING_VAR}"

### PROCESS
local bbKey

for bbKey in "${!bbArrayRef[@]}"; do
	BING_VAR="${bbArrayRef[$bbKey]}"
	break
done

# echo "$BING_VAR"
read $bbFirst <<< "$BING_VAR"

array_remove $bbArrayName $bbKey

}
