# bing-bash  
  
## `bing-bash` - bash functions library  
  
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
  
  
## Quick start
Configure and source `bing-bash' file to enable some sort of function
management like functions autoloading or just source single files of
interest.  
  
  
## Using functions  
* Files containing functions can be sourced individually (functions are not dependent on any other function from this library) and called as usual. Sourcing files that contain functions will, of course, leave these functions in the memory, but at least all these memory-occupying functions will be at their most ready state.
* One level down in comparison to the above is to have functions marked for autoloading, although this is not a true function autoloading as in other shells; namely, when marked for autoloading, a stand-in eponymous function will be created (only a few lines long, as opposed to loading the whole function definition) that will source its true definition when first called.
* The last, and most environment and memory friendly, way is to call functions through `bb` function dispatcher that will load called function, pass arguments to it and unload it when done. Also, this way you can tinker with the function's code while always having the latest revision of function sourced when called.  
  
  
## Conventions  
Parameters to function can be passed by name or value.  
* Array variables are always passed by name (without $). 
* Scalar variables can be passed by name (without $) or by value (with $, as usual).   
As a convenience, instead of passing a scalar variable the usual way, possibly with quotations e.g. `bb_func "$var"` you can just type `bb_func var`. Of course, a value can aways be passed directly: `bb_func "abcd"` or `bb_func abcd`, in which case the unexpected can happen if there is already a variable named `abcd` (the price for less typing).  
Since array variables cannot be passed around in bash (nor can be exported), they are always passed by name (trying to pass an array with `$array` will just pass its first element and passing an array as `${array[@]}` can work, but at the cost of having its indices/keys discarded). 
  
  
## List of functions/subroutines:  
(some functions encompass functionality, that could be split
across several individual functions, as subroutines)  
  
* `bb_typeof`  
  Identify given string as set or unset variable, array, shell keyword, etc.  Dump variables, pretty print arrays and their attributes.  
  Started as a function mostly used to pretty dump array to the screen, became a function to type and qualify names passes to it. Still, when used with variable gives info about it such as its value and attributes. Variable are passed by name (without $ sign). With `-t` option, only the type, as a single word is returned. Types returned are: unset variable, variable, indexed array, associative array; also the types returned by `type` builin: alias, keyword, function, builtin or file.
  
* `bb_explode`  
  Convert a string to array by splitting it by substring which can be a
  single or multi-character substring. 
  Convert a string to array of individual characters.  
  (in progress: guess the most probable delimiter)  
  
* `bb_implode`  
  Convert an array to string.  

* `bb_array_clone`  
  Clone an array.  
  
* `bb_range`  
  Generate number sequences from ranges list (e.g. 1,4-8,10,12-22,30-35,50).  
  
* `bb_strpos`  
  Find the position of the first occurrence of a substring in a string.

* `bb_pad`  
  Pad a string by appending char(s) after each character of the string. 
  
* `bb_array_convert`  
  Convert indexed to associative array or vice versa.
  
  
  
(everything below needs final touches:)  
  
### Arrays:  
  
`in_array`
- Checks if a value (variable or array) exists in an array

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
  
  
  
  
  
  
#### FILES LIST:  
  
````
README.md
bing-bash           configuration
bing_aliases        bing-bash aliases
bing_samples        sample data
bb                  functions dispatcher
typeof.bash
explode.bash
implode.bash
range.bash

array_clone
array_convert

/strings/pad.bash
````
  
  
#### Definitions (used in desciptions):  
````
<char>        One or more characters, usually non-alnum
<string>      Any sequence of characters
<substring>   Sequence of characters that are part of some string
<identifier>  Sequence of alnum chars and underscore [A-Za-z_]
<name>        Portable sequence of characters
<filename>    POSIX portable filename [A-Za-z0-9.-_] but hyphen not 1.char
<pathname>    POSIX portable pathname [A-Za-z0-9.-_/]
<alias>       POSIX portable alias    [A-Za-z0-9.-_/!%,@]

<flag>        Option with 2 states: present/absent
<option>      Short (-o) or long option (--option)
<argument>    Argument to an option
<required>    Required argument
<optional>    Optional argument

<var>
<scalar>
<array>

<space>
<integer>
<digit>
````
