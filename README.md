# bing-bash  
  
## `bing-bash` - bash functions library  
  

### About  
Library of bash functions providing miscellaneous functionalities: dealing with strings and arrays, symbol table management, alternatives for usual shell utilities, etc.  
   
  
### Quick start  
Just take and source the functions you need.  
All functions are standalone, they don't depend on any other function or file from this library.  


### Description
The library is composed using native bash's (4.3) abilities, without unnecessary forking (when possible) or usage of external tools (if faster). Single process bash shell was in high regard as well as bash's specific functionalities (bashisms). Made and tested with bash 4.3 (and 4.4-beta).
  
Functions are meant to be sourced, though some of them could be executed as well. All functions are standalone and they don't need any other function or file from this library, but as a convenience there are some function management capabilities available; see `bing-bash`, `load` and `bb` file to enable some of them, like function autoloading and managing function's aliases.
  
  
### Usage
* Files containing functions can be sourced individually and then functions can be called as usual. This way functions will, of course, stay resident, but at least this memory-occupying, environment-polluting way will keep the functions instantly available.
* One level down in comparison to the above is to have functions marked for autoloading, but this is not a true autoloading as in other shells. Namely, when marked for autoloading, a stand-in, eponymous function will be created, only a few lines long (as opposed to sourcing the whole function's body) whose purpose is to source its complete definition when first called.
* The last and most environment friendly way is to call functions through `bb` function dispatcher that will load called function, pass arguments to it and unload it when done. This way is also convenient during fiddling with function's body, as it always sources the current function's code.
  
  
### Conventions  
A parameter to a function can be passed by name or by value.  
* Array variables are always passed by name (without $).  
* Scalar variables can be passed by name (without $) or by value (with $, as usual).  

As a convenience, instead of passing a variable by value, possibly with quotations (e.g. `function "$var"`) you can just type `function var` to pass it by name. Naturally, a value can also be passed directly (`function "abcd"`), in which case there may be unexpected results if it happens that a variable by that name (variable called `abcd`) already exist. (Ah, the price for typing less).  

Since array variables cannot be passed around in bash (nor can be exported), they are always passed by name only. Trying to pass an array with `$array` will just pass its first element and passing an array as `${array[@]}` could work at the cost of having its indices/keys discarded; not to mention passing 2 or more arrays.  
  
  
### List of functions and their subroutines:  
(Some functions encompass functionality, that maybe should've been split across several functions, as subroutines)  
    
* `bb_typeof`  
  Pretty dump arrays and their attributes is its main purpose.  
  Type and qualify given string: identify it as set or unset variable, indexed or associative array, shell keyword, etc. With `-t` option, only the type, as a single word is returned: unset, variable, indexed, associative; also those returned by type builin: alias, keyword, function, builtin or file.  
  
* `bb_explode`  
Convert a string to array by splitting it by substring which can be a single or multi-character substring. Also convert a string to array of individual characters.  
  
* `bb_implode`  
Convert an array to string.  
  
* `bb_array_clone`  
Clone an array.  
  
* `bb_range`  
Generate number sequences from ranges list (e.g. 1,4-8,10,12-22,30-35,50).  
  
* `bb_venn`  
Venn diagrams related functions: find union, intersection, difference, complement.  
  
* `bb_strpos`  
Find the position of the first occurrence of a substring in a string.
  
* `bb_pad`  
Pad a string by appending char(s) after each character of the string. 
  
* `bb_array_convert`  
Convert indexed to associative array or vice versa.  
  
* `in_array`  
Checks if a value (variable or array) exists in an array.  
  
* `bb_array_merge`  
Merge two arrays into third.  
  
* `bb_array_remove`  
Remove array elements.  
  
* `bb_array_shift`  
Shift the first value of the array off and return it.  
  
* `bb_array_sort`  
Sort an array in different ways. Remove duplicated values from an array.  
  
* `bb_load`  
Check and source functions. Mark functions for autoloading. Resolve function's full path.  
  
* `bb_trim`
Trim leading, trailing and intermediate whitespace.  
  
* `bb_to`  
Conversions: e.g. ascii to hex, octal, decimal, etc.  
  
* `bb_sql`
Routines dealing with sqlite database.  
  
* `bb_is`  
Subroutines for pattern matching.  
  
* `bb_get`  
Subroutines Routines that collect information: variable attributes, variable/array length, etc.  
  
* `bb_array`
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
- etc.
  
  
  
  
  
### Definitions (used in desciptions):  
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
