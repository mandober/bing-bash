#!/bin/bash bingmsg
#==================================================================
#: FILE: venn.bash
#: PATH: $BING/func/venn.bash
#: TYPE: function
#:
#: AUTHOR:
#:      bing-bash by mandober <zgag@yahoo.com>
#:      https://github.com/mandober/bing-bash
#:      za Ǆ - Use freely at owns risk
#:      4-Mar-2016 (last revision)
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: NAME: 
#:      bb_venn
#:
#: BRIEF: 
#:      Venn diagrams related functions.
#:
#: DESCRIPTION:
#:      Venn functions: 
#:                 setA {abcde}
#:                 setB {abfg}
#:        union: A ∪ B  {abcdefg}
#: intersection: A ∩ B  {ab}
#:   difference: A Δ B  {cdefg}
#:   complement: A \ B  {cde}
#:               B \ A  {fg}
#:
#: DEPENDENCIES:
#:      bb_err
#:
#: EXAMPLE:
#:      bb_venn
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: SYNOPSIS:
#:      bb_venn 
#:
#: OPTIONS: 
#:      -u, --union          Return union of setA and setB.
#:      -i, --intersection   Return intersection of setA and setB.
#:      -d, --difference     Return difference of setA and setB.
#:      -a, --complement-a   Return complement of setA in setA and setB.
#:      -b, --complement-b   Return complement of setB in setA and setB.
#:      
#:
#: PARAMETERS:
#:      <string> FUNC - name of the function(s) to load
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: STDOUT:
#:      -
#:
#: STDERR:
#:      Error messages, usage
#:
#: RETURN CODE:
#:		0   (no errors)
#:		51  Positional parameter absent
#:		52  Wrong number of positional parameters
#==================================================================

bb_venn () {
local bbapp="${FUNCNAME[0]}"
local bbnfo="[bing-bash] $app v.0.4"
local usage="USAGE: $app A --relation B"

[[ $# -eq 0 ]] && { bb_err 51; printf "${usage}\n" >&2; return 51; }
[[ $# -gt 3 ]] && { bb_err 52; printf "${usage}\n" >&2; return 52; }

[[ $1 =~ ^(--usage)$ ]] && { printf "${usage}\n" >&2; return 0; }
[[ $1 =~ ^(--version)$ ]] && { printf "${bbnfo}\n" >&2; return 0; }
[[ $1 =~ ^(--help)$ ]] && {
	cat <<-EOFF
	$bbnfo
	  Venn diagrams related functions.
	$usage
	  Return elements as a product of relation between set A and set B,
	  where relation is one of union, intersection, difference or complement.
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

### SET
shopt -s extglob 		# Enable extended regular expressions
shopt -s extquote		# Enables $'' and $"" quoting
shopt -u nocasematch 	# regexp case-sensitivity
set -o noglob			# Disable globbing. Enable it upon return:
trap "set +o noglob" RETURN ERR SIGHUP SIGINT SIGTERM


### PARAMS
local A="$1"
local relation="$2"
local B="$3"

case $relation in

	-u|--union) # A --union B
		# A={ace} ∪ B={ab} -> {abce}
		local U=$A$B
		bb_explode $U -c arrayU
		bb_array_sort -u arrayU
		bb_implode arrayU -g=''
		echo "$BING_IMPLODED"
	;;


	-n|-i|--intersection) # A --intersection B
		# A={ace} ∩ B={ab} -> {a}
		local a b arrayA arrayB
		bb_explode $A -c arrayA
		bb_explode $B -c arrayB
		local BING_ARRAY=()

		for a in "${arrayA[@]}"; do
			for b in "${arrayB[@]}"; do
				[[ "_$a" = "_$b" ]] && BING_ARRAY+=( "$a" )
			done
		done

		bb_array_sort -u BING_ARRAY
		bb_implode BING_ARRAY -g=''
		echo "$BING_IMPLODED"
	;;


	-d|--difference) 
		# A --difference B : A={ace} Δ B={ab} -> {bce} 
		# U \ I: U={abce} \ I={a} -> {bce}
		local U=$A$B
		local u i arrayU arrayI
		bb_explode $U -c arrayU
		I="$(venn "$A" --intersection "$B")"
		bb_explode $I -c arrayI
		local BING_ARRAY=()

		for u in "${arrayU[@]}"; do
			for i in "${arrayI[@]}"; do
				[[ "_$u" = "_$i" ]] && continue 2
			done
			BING_ARRAY+=( "$u" )
		done

		bb_array_sort -u BING_ARRAY
		bb_implode BING_ARRAY -g=''
		echo "$BING_IMPLODED"
	;;


	-a|--complement-a) 
		# A --complement-a B : A={ace} \ B={ab} -> {ce}
		local a b arrayA arrayB
		bb_explode $A -c arrayA
		bb_explode $B -c arrayB
		local BING_ARRAY=()

		for a in "${arrayA[@]}"; do
			for b in "${arrayB[@]}"; do
				[[ "_$a" = "_$b" ]] && continue 2
			done
			BING_ARRAY+=( "$a" )
		done

		bb_array_sort -u BING_ARRAY
		bb_implode BING_ARRAY -g=''
		echo "$BING_IMPLODED"
	;;

	-b|--complement-b) 
		# B ---complement-b A : B={ab} \ A={ace} -> {b}
		local a b arrayA arrayB
		bb_explode $A -c arrayA
		bb_explode $B -c arrayB
		local BING_ARRAY=()

		for b in "${arrayB[@]}"; do
			for a in "${arrayA[@]}"; do
				[[ "_$a" = "_$b" ]] && continue 2
			done
			BING_ARRAY+=( "$b" )
		done

		bb_array_sort -u BING_ARRAY
		bb_implode BING_ARRAY -g=''
		echo "$BING_IMPLODED"
	;;


	*) return 52;;

esac
}
