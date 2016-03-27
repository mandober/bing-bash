# bing-bash  
  
## `bing-bash` - bash functions library  
  
````
This library is composed using native bash's (4.3) abilities, without  
unnecessary forking or usage of external tools if possible or faster.  
Single process bash shell was in high regard as well as bash specific  
functionality, disregarding portability. All was made and tested with  
bash 4.3 and 4.4-beta.  
  
bing-bash is a collection of bash functions, meant to be sourced, but  
some of them can be directly executed as well.  All functions are (or  
going to be soon) standalone -  they won't need any other function or  
file in this library to work (possibly only some initialization files  
such as `bing-bash', merely as a convenience, not requirement).  
````
  
  
## Quick start
Configure and source `bing-bash' file to enable some sort of function  
management like functions autoloading or just source single files of  
interest.  
  
  
## Using functions  
* Files containing functions can be sourced individually (functions are not dependent on any other function from this library) and called as usual. Sourcing files that contain functions will, of course, leave these functions in the memory, but at least all these memory-occupying functions will be at their most ready state.
* One level down in comparison to the above is to have functions marked for autoloading, although this is not a true function autoloading as in other shells; namely, when marked for autoloading, a stand-in eponymous function will be created (only a few lines long, as opposed to loading the whole function definition) that will source its true definition when first called.
* The last, and most environment and memory friendly, way is to call functions through `bb` function dispatcher that will load called function, pass arguments to it and unload it when done. Also, this way you can tinker with the function's code while always having the latest revision of function sourced when called.



## List of functions/subroutines:  
(some functions encompass functionality, that could be split  
across several individual functions, as subroutines)  
  
* `bb_typeof`  
  Identify given string as set or unset variable, array, shell keyword, etc.  
  Dump variables (pretty print arrays) and their attributes.   
  
* `bb_explode`  
  Convert a string to array by splitting it by substring which can be a  
  single or multi character substring.  
  Convert a string to array of individual characters.  
  (in progress: guess the most probable delimiter)  
  
* `bb_implode`  
  Convert an array to string  
  
* `bb_range`  
  Generate sequences (e.g. 1,4-8,10,12-22,30-35,50)  
  
  
  
(everything below needs final touches:)

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
  
  
### MISC (match patterns, identify, qualify) 
  
`bb_is`
IS functions

`bb_get`
GET functions

`bb_do`
DO functions
  
`bb_venn`
- Venn diagrams related functions: find union, intersection, difference,  
  complement).

`bb_trim`
- Trim leading, trailing and intermediate whitespace.

`bb_to`
- Conversions: e.g. ascii to hex, octal, decimal...and similar

`bb_load`
- Check and source functions
- Mark functions for autoloading
- Resolve function's full path

`bb_sql`
- Routines dealing with sqlite database

`bb_err`
- Display error and debug messages
  
  
 
-----

## FILE LIST:  
  
README.md  
bing-bash  
bing_aliases  
bing_samples  
bb  
typeof.bash  
explode.bash  
implode.bash  
range.bash  

