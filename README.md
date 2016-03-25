# bing-bash  
  
## `bing-bash` - bash functions library  
  
This library is composed using native bash's (4.3) abilities, without  
unnecessary forking or usage of external tools if possible or faster.  
Single process bash shell was in high regard as well as bash specific  
functionality, disregarding portability. All was made and tested with  
bash 4.3 and 4.4-beta.  
  
bing-bash is a collection of bash functions, meant to be sourced, but  
some of them can be directly executed as well.  All functions are now  
(or going to be soon) standalone - they won't need any other function  
or file in this library to work (possibly only the main initialization  
`bing-bash' file, file with common aliases, etc.).
  
  
## Quick start
Configure and source `bing-bash' file, or just source the  
functions/files of interest.  


## List of functions/subroutines:  
  

### Strings, variables:  

`bb_typeof`  
- Identify given string as set or unset variable, array, shell keyword, etc.
- Dump variables (pretty print arrays) and their attributes.   

`bb_explode`  
- Convert a string to array by splitting it by substring which can be a  
  single or multi character substring
- Convert a string to array of individual characters
- IN PROGRESS: guess the most probable delimiter

`bb_implode`
- Convert an array to string

`bb_venn`
- Venn diagrams related functions: find union, intersection, difference,  
  complement).

`bb_trim`
- Trim leading, trailing and intermediate whitespace.

`bb_range`
- Generate sequences (e.g. 1,4-8,10,12-22,30-35,50)
* Can be used as function or executable

`bb_to`
- Conversions: e.g. ascii to hex, octal, decimal...and similar


### Arrays:  

`bb_array_clone`
- Clone an array  

`in_array`
- Checks if a value (variable or array) exists in an array

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
* TODO: sort it out
  
### Match patterns, identify, qualify:  
  
`bb_is`
IS functions

`bb_get`
GET functions

`bb_do`
DO functions
  

### MISC

`bb_load`
- Check and source functions
- Mark functions for autoloading
- Resolve function's full path

`bb_sql`
- Routines dealing with sqlite database

`bb_err`
- Display error and debug messages
  
  
 
