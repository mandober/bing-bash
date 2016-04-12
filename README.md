# bing-bash  
  
## ![bingbash](https://img.shields.io/badge/bing-bash-orange.svg?style=flat-square) Bash functions library
  

* [About](#about)
* [Quick start](#quick-start)
* [Description](#description)
* [Usage](#usage)
* [Conventions](#conventions)
  - [Naming conventions](#naming-conventions)
  - [Positional parameters](#positional-parameters)
  - [Short options](#short-options)
  - [Long options](#long-options)
  - [Parameters (non-options)](#parameters-non-options)
* [List of functions](#list-of-functions)
* [Features](#features)
  
  
### About  
Library of bash functions comprising routines for dealing with variables, arrays, strings, symbols table, etc.  
  
  
### Quick Start
Just download and source the functions you need.   
Apart from few, all functions are standalone, they don't depend on any other function or file from this library. Those that are, have their dependencies specified in the corresponding help section.  
  
  
### Description
The library is composed using bash's (4.3) features, without unnecessary forking (when possible) or usage of external tools (unless faster). Single process bash shell was in high regard as well as bash's specific functionalities. Made and tested with bash 4.3 (and 4.4-beta).  
  
  
### Usage
Functions are meant to be sourced, though some of them could be executed as well. All functions are standalone and they don't need any other function or file from this library (unless explicitly stated), but as a convenience, there are some function management capabilities available (see `bing-bash`, `load` and `bb` files).
  
* Files containing functions can be sourced individually and then functions can be called as usual. This way functions will, of course, stay resident, but at least all the environment-polluting code will make the functions instantly responsive.
* One level down in comparison to the above is to have functions marked for autoloading; although not a true autoloading, as in other shells. Namely, when marked for autoloading, a stand-in, eponymous function will be created, only a few lines long (as opposed to the whole function's body) whose purpose is to source its complete definition when first called.
* The last and most environment friendly way is to call functions through `bb` function dispatcher that will load called function, pass arguments to it and unload it when done. This way is also convenient during fiddling with function's body, as it always sources the current function's code.  
  
  
### Conventions
  
#### Naming Conventions
Names of all functions are prefixed with `bb_` as an attempt to pseudo-namespace them so they won't collide with other eponymous tools, scripts and functions. On the other hand, files that define these functions are named without such prefix, with a `.bash` extension added. This makes it easy to separate files that contain functions from other files; the exceptions to this is `load` file that has no extension (because it contains autoloading function code).  
  
If you're sure no naming collisions exist on your system, you can, of course, make aliases (e.g. `alias typeof=bb_typeof`) to shorten function's names; some aliases are already defined in `bing_aliases` file. 
  
Names of variables local to functions all have `bb` prefix followed by capital letter (e.g. `bbParam`), so avoid passing similarly named parameters to minimize problems.
  
Names of environment variables used are all upper-cased and have `BING_` prefix (e.g. `BING_FUNC`).
  
#### Positional Parameters
Positional parameters are divided into options and parameters (non-options).
Options are further divided into: flags (options without arguments), options that have an optional argument, options that have required argument. Options are also divided into short (`-o`) and long options (`--long-option`).  
  
Parameters can be explicitly separated from options by using double dash `--`; for example, `function -o ARG1 --long-option ARG2 -- PARAM` in which case everything after '--' is treated as a parameter, even if it starts with '-' or '--'. Otherwise (i.e. without '--'), order of options and parameters is not important (unless specifically noted in function's help section). If the same option is repeated, the latter will overshadow the former occurrence. If unrecognized option is supplied, it will be discarded.  
  
#### Short Options
A short option begins with a dash (-) followed by a single character.
* If the option has **no argument** it is called a simple option or a **flag** (e.g. `-x`).  
* If the option has **required** argument it may be written:
  - **immediately** after the option character, e.g. `-rreq`
  - as the **following** parameter, e.g. `-r req`
* If the option has **optional** argument, it must be written:
  - **immediately** after the option character, e.g. `-rreq`
* It is possible to specify several short options after one '-', as long as all (except possibly the last) options are flags: `-xyz`, `-xyzr req`
  
#### Long Options
A long option normally begins with double dash (--) followed by the long option name.
* If the option has **required** argument, it may be written:
  - **immediately** after option name, e.g. `--optionREQUIRED`
  - as the **following** argument, e.g. `--option REQUIRED`
  - after the **equal** sign, e.g. `--option=REQUIRED`
* If the option has **optional** argument, it must be written:
  - **immediately** after option name, e.g. `--optionOPTIONAL`
  - after the **equal** sign, e.g. `--option=OPTIONAL`
* Long options may be **abbreviated**, as long as the abbreviation is 
  **unambiguous**, e.g. `--long` instead of `--long-option`.
   
#### Parameters (non-options)
A parameter to a function can be passed by name or by value.  
* Array variables are always passed by name (without $).  
* Scalar variables can be passed by name (without $) or by value (with $, as usual).  
  
As a convenience, instead of passing a variable by value, possibly with quotations (e.g. `function "$var"`) you can just type `function var` to pass it by name. Naturally, a value can also be passed directly (`function "abcd"`), in which case there may be unexpected results if it happens that a variable by that name (variable called `abcd`) already exist. (Ah, the price for typing less).  
  
Since arrays cannot be passed around in bash (nor exported), they are always passed by name (without $). Trying to pass an array with `$array` will only pass its zeroth element (if any) and passing an array as `${array[@]}` could work at the cost of having its indices/keys discarded; still not very practical, especially when two or more arrays need to be passed to a function.  
  
### List of functions  
(Some functions encompass functionalities, that might've been split across several functions, as subroutines)  
  
* `bb_typeof`   
Pretty dump arrays and their attributes is its main purpose.  
Type and qualify given string: identify it as set or unset variable, indexed or associative array, shell keyword, etc. With `-t` option, only the type, as a single word is returned: unset, variable, indexed, associative; also those returned by type builin: alias, keyword, function, builtin or file.  
````feat:
[d](#features "documentation") 
[h](#features "help section")
[m](#features "man page") 
[n](#features "pass by name") 
[t](#features "tests") 
[s](#features "standalone") 
````
  
* `bb_explode`  
Convert a string to array by splitting it by substring which can be a single or multi-character substring. Also convert a string to array of individual characters.  
feat: `d` `h` `m` `n` `t` `s` 
  
* `bb_implode`  
Convert an array to string. Specify wrapping and glue characters.  
  
* `bb_array_clone`  
Clone an array.  

* `bb_array_merge`  
Merge two or more arrays of any type (indexed and/or associative). User can force the type of resulting array and specify merging mode (reindex, skip, overwrite, append).  
  
* `bb_array_convert`  
Convert indexed to associative array or vice versa.  
  
* `bb_array_remove`  
Remove array elements. Remove element with specified index/key from an array. Remove several elements by specifying them as comma-separated list of integers and/or ranges. Optionally, if name for the resulting array is specified, the original array will be left intact.  
  
* `bb_array_shift`  
Shift the first value of the array off and return it.  
  
* `bb_array_sort`  
Sort array different ways. Remove duplicated values from an array (make unique).  
* `in_array`  
Checks if a value (variable or array) exists in an array.  
    
* `bb_range`  
Generate numeric sequences from list of ranges and individual integers (e.g. 1,4-8,10,15-20,25-30). Specify numbers base and divider, prefix, suffix characters.  
  
* `bb_venn`  
Venn diagrams related functions: union, intersection, difference, complement.  
  
* `bb_strpos`  
Find the position of the first occurrence of a substring in a string.  
  
* `bb_pad`  
Pad a string by appending char(s) after each character of the string. 

* `bb_load`  
Source functions. Mark functions for autoloading. Resolve functions path.  
  
* `bb_trim`  
Trim leading, trailing and intermediate whitespace.  
  
* `bb_to`  
Conversions between hex, octal, decimal, ascii.  
  
* `bb_sql`  
Routines dealing with sqlite database.  
  
* `bb_is`  
Pattern matching subroutines: qualify string as alphabetic, alpha-numeric, etc.; qualify name as valid identifier, filename, path; qualify variables as set, null, indexed, associative, etc.    
  
* `bb_get`  
Collect information about variables, their attributes, arrays, variable's length and type, etc.  
  
* `bb_array`  
Array quick dump.  
Identify array as indexed, associative, numeric.  
Return keys, values, empty elements.  
Remove unset elements.  
Re-index a sparse array.  
Pack and squeeze an array.  
  
  
### Features  
Implement or check that everything is as described above.  
`c` completions  
`d` documentation (in comments of function's file)  
`h` current --help option  
`o` output result to stdout and/or to given var  
`m` man page  
`n` pass variables by name  
`p` parse positionals as described (compound short, abbreviated long options)  
`s` standalone  
`t` tests  
`v` verbosity levels  
`?` option to get parameters from stdin  

  
  
### Definitions  
(used in function's comments or help section)  
````
<char>        One or more characters, usually non-alnum
<string>      Any sequence of characters
<substring>   Sequence of characters that are part of some string
<identifier>  Sequence of alnum chars and underscore [A-Za-z_]
<name>        Portable sequence of characters
<filename>    Portable filename [A-Za-z0-9.-_] (hyphen not 1.char)
<pathname>    Portable pathname [A-Za-z0-9.-_/]
<alias>       Portable alias    [A-Za-z0-9.-_/!%,@]
<flag>        Option with 2 states: present/absent
<option>      Short (-o) or long option (--option)
<argument>    Argument to an option
<required>    Required argument
<optional>    Optional argument
<var>         Variable.
<scalar>      'Plain', non-array variable 
<array>       Any array
<indexed>     indexed array
<assoc>       Associative array
<space>
<whitespace>  Space, tab, vertical tab, new line
<integer>
<digit>
````
  
