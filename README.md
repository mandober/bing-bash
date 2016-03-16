# bing-bash   
   
## `bing-bash` - bash functions library   
   

No forks, no external tools - single process bash shell.   
Tested with bash 4.3 and 4.4-beta.
Portability disregarded, bashisms preferred.   
Collection of bash functions.
   
  
## List of functions/subroutines:  
  

### Strings, variables, functions:  

`bb_typeof`
- Identify given string as set or unset variable, array, shell keyword, etc.
- Dump variables (pretty print arrays) and their attributes   

`bb_explode`   
- Convert a string to array
- Convert a string to array of chars

`bb_implode`
- Convert an array to string

`bb_venn`
- Venn diagrams related functions: find union, intersection, difference, complement) 

`bb_trim`
- Trim leading, trailing and intermediate whitespace.

`bb_range`
- Generate sequences (e.g. 1,4-8,10,12-22,30-35,50)

`bb_load`
- Check and source functions
- Mark functions for autoloading
- Resolve function's full path

`bb_sql`
- Routines dealing with sqlite database

`bb_err`
- Display error and debug messages


### Arrays:  

`in_array`
- Checks if a value (variable or array) exists in an array

`bb_array_clone`
- Clone (and optionally re-index) an array  

`bb_array_convert`
- Convert indexed to associative array or vice versa

`bb_array_merge`
- Merge two arrays into third

`bb_array_remove`
- Remove array element(s)

`bb_array_shift`
- Shift the first value of the array off and return it

`bb_array_sort`
- Sort an array n different ways
- Remove duplicated values from an array


`bb_array`
- Quick dump of array
- Identify array as indexed or associative
- Identify indexed array as numeric
- Return number of array elements
- Return keys of an array
- Return values of an array
- Return empty keys of an array
- Re-index an indexed sparse array
- Remove unset elements from array
- Pack and squeeze an array


### Match pattern, identify, qualify:  

`bb_is`
IS functions

`bb_get`
GET functions

`bb_do`
DO functions
  
  
  
  
Each function declares a list of dependencies (other function from this package they need) and although they all count on `bb_err` function in order to display meaningful error messages, they will still work without it (in which case you can look up the error code in `err.bash` file manually). All other dependencies are absolutely required (at least for the time being).
Namely, there's a dilemma whether to make each function dependencies free on account of code repetition and bigger memory footprint. In this case there would be a significant gain in execution speed, and m4 macro processor would be used to deal with code repetition.
