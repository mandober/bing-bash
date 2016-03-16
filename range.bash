#!/bin/bash bingmsg
#==================================================================
#:Name:  range
#:Path:  $BING/func/strings/range
#:Type:  function
#:Deps:  bb_err, bbis
#:
#:Author:
#:    [bing-bash] by mandober <zgag@yahoo.com>
#:    https://github.com/mandober/bing-bash
#:    za Ǆ - Use freely at own's risk
#:    Last revision: 3-Mar-2016
#:
#:Description:
#:	  Generate sequences from given ranges list. List can be
#:	  a single range (5-10) or a comma-separated list of ranges
#:	  (12-22,30-35). Ranges are inclusive. Single values (2,5)
#:	  will not generate anything, but they will be included in
#:	  the final sequence.
#:
#:Examples:
#:    bb_range 10-20
#:    bb_range 1,3-7,9,12-16
#:
#:Usage:
#:    bb_range LIST
#:
#:Options:
#:    no options
#:    
#:Params:
#:    <string> LIST - comma-separated ranges [\d,-]
#:    
#:Returns:
#:    void
#:    
#:Return Codes: 
#:    0 success
#:    
#:    
#==================================================================

bb_range() {

local bbMIN bbMAX
local bbSequence=
local bbTempArray bbNum


# bb_explode list by comma
bb_explode "$1" -d=',' bbTempArray

for bbNum in "${!bbTempArray[@]}"; do

	if bbis --range "${bbTempArray[$bbNum]}"; then
		# 5-8, 1000-5000000
		bbMIN="${bbTempArray[$bbNum]%-*}"
		bbMAX="${bbTempArray[$bbNum]#*-}"
		
		if ! bbis --int "$bbMIN"; then return 1; fi
		if ! bbis --int "$bbMAX"; then return 1; fi

		while [[ $bbMIN -le $bbMAX ]]; do
			bbSequence+="${bbMIN},"
			(( bbMIN++ ))
		done

	else
		if ! bbis --int "${bbTempArray[$bbNum]}"; then return 1; fi
		bbSequence+="${bbTempArray[$bbNum]},"
	fi

done

bbSequence="${bbSequence%,}"
echo "$bbSequence"
}
