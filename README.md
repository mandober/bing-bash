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
  - [Operands](#operands)
* [List of functions](#list-of-functions)
* [Features](#features)
  
  
### About  
Library of bash functions comprising routines for dealing with variables, arrays, strings, functions, symbols table, etc.  
  
  
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
  
>
Names of variables local to functions all have `bb` prefix followed by capital letter (e.g. `bbParam`), so avoid passing similarly named parameters to minimize problems.
  
Names of environment variables used are all upper-cased and have `BING_` prefix (e.g. `BING_FUNC`).
  
#### Positional Parameters
Positional parameters are divided into options and operands (non-option parameters).  
Options are further divided into:  
* flags (options without arguments)  
* options that have required argument  
* options that have an optional argument  
  
Options are also divided into short (`-o`) and long options (`--long-option`).  
  
Operands can be explicitly separated from options by using double dash `--`; for example, `function -options -- PARAM1 PARAM2` in which case everything after '--' is treated as an operand, even if it starts with '-' or '--'. Otherwise (i.e. without '--'), **order** of options and operands is not important (unless specifically noted for a particular function).  
* If the same option is repeated, the latter will overshadow the former occurrence.
* If unrecognized option is supplied, it will be discarded.  
  
#### Short Options
A short option begins with a dash (-) followed by a single character.
* If the option has **no argument** it is called a simple option or a flag e.g. `-x`.  
* If the option has **required** argument it may be written:  
  - *immediately* after the option character, e.g. `-rREQ`  
  - as the *following* parameter, e.g. `-r REQ`  
* If the option has **optional** argument, it must be written *immediately* after the option character, e.g. `-rOPT`  
   
It is possible to specify several short options after one '-' (compounded short options), as long as all (except possibly the last) options are flags: `-xyz`, `-xyzr req`  
  
#### Long Options
A long option normally begins with double dash (--) followed by the long option name (which is a string of alphanumerics and dash).  
* If the long option has **no argument** it is called a simple option or a flag e.g. `--long-option`  
* If the option has *required* argument, it may be written:
  - as the *following* argument, e.g. `--option REQ`
  - after the *equal sign*, e.g. `--option=REQ`
* If the option has **optional** argument, it must be written after the *equal sign*, e.g. `--option=OPT`  
   
Long options may be **abbreviated**, as long as the abbreviation is 
  *unambiguous*, e.g. `--long` instead of `--long-option`.
    
> 
NOTE: Important thing to note about this library is that all functions will parse canonically provided parameters (i.e. no compounded short options, no abbreviations of long options) internally, in the body of function itself, which means faster execution. Otherwise `getopt` utility will be called to parse parameters, which may sometimes result in slower function's execution.  
  
#### Operands
An operand to a function can be passed by name or by value.  
* Array variables are always passed by name (without $).  
* Scalar variables can be passed by name (without $) or by value (with $, as usual).  
  
As a convenience, instead of passing a variable by value, possibly with quotations (e.g. `function "$var"`) you can just type `function var` to pass it by name.  
>
Naturally, a value can also be passed directly (`function "abcd"`), in which case there may be unexpected results if it happens that a variable by that name (a variable called `abcd`) already exist.  
  
Since arrays cannot be passed around in bash (nor exported), they are always passed by name (without $). Trying to pass an array with `$array` will only pass its zeroth element (if any) and passing an array as `${array[@]}` could work at the cost of having its indices/keys discarded; still not very practical, especially when two or more arrays need to be passed to a function.  

#### Common options
These 3 options are guaranteed to be accepted in all functions:  
`--help` show help  
`--usage` show usage  
`--version` show version  
Short-option equivalents of above options, `-h`, `-u` and `-v` (including their capital case form) are frequent, but are not to be relied upon as they might have been used for something else entirely.  
  
`-v, --verbose`
Most functions also accept setting of verbosity level via `-v, --verbose LEVEL` option, where optional option-argument LEVEL is: 0 for quiet - no error output, 1 for output of fatal error messages (default level), 2 for extensive informational output, 3 for debugging output; verbosity levels can also be set the traditional way as `-v, -vv, -vvv`, which correspond to levels 1, 2 and 3 respectively.
   
`-o, --out`
If a function accepts user supplied name for a variable that will hold function's resulting value, this is always achieved via `-o, --out NAME` option, followed by required option-argument NAME that must be valid identifier. If the option-argument is a number 1-9 (inclusive) the output will be sent to this file descriptor.   
   
  
### List of functions  
(at the moment, some functions encompass functionalities that perphaps shouldn't've been merged together in a single functions as subroutines)  
  
* `bb_typeof`   
Pretty dump arrays and their attributes is its main purpose.  
Type and qualify given string: identify it as set or unset variable, array, shell keyword, etc. With `-t` option, only the type, as a single word is returned: unset, variable, indexed, associative; also those returned by type builin: alias, keyword, function, builtin or file.  
(feat: [d][] [h][] [o][] [m][] [p][] [s][] [t][])  
  
* `bb_explode`  
Convert a string to array by splitting it by substring which can be a single or multi-character substring; convert a string to array of individual characters. Needs "predict a delimiter" feature.   
  
* `bb_implode`  
Convert an array to string. Specify wrapping, prefix, suffix and *glue* characters.  
  
* `bb_array_clone`  
Clone an array.  

* `bb_array_merge`  
Merge two or more arrays of any type (indexed and/or associative). User can force the type of resulting array and specify merging mode (reindex, skip, overwrite, append).  
  
* `bb_array_convert`  
Convert indexed to associative array or associative to index array, discarding the keys.  
  
* `bb_array_remove`  
Remove one or more element by specifying index/key. Remove many elements by specifying comma-separated list of strings (associative) or ranges (mainly for indexed arrays). 
  
* `bb_array_shift`  
Return the value of the first element by removing it and shifting remaining elements down.  
  
* `bb_array_sort`  
Sort array different ways. Remove duplicated values from an array.  

* `in_array`  
Checks if a value, scalar or array, exists in an array.  
    
* `bb_range`  
Generate numeric sequences from list of ranges and individual integers (e.g. 1,4-8,10,15-20,25-30). Specify numbers base and divider, prefix, suffix characters.  
  
* `bb_venn`  
Scalars, strings, arrays and Venn diagrams: union, intersection, difference, complement.  
  
* `bb_load`  
Load and unload functions. Mark functions for autoloading. Resolve functions path.  
   
* `bb_pad`  
Pad a string by appending char(s) after each character of the string. 
  
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
Identify array as associative and indexed.  
Identify indexed array as numeric, packed, sparse.  
Return array's keys, values, empty elements, max, min values.  
Squeeze an array.  
Pack an array.  
   
  
### Features  
Or tasks. Check-list of features that are, or need to be, implemented.  
`c` completions  
`d` documentation, rationale and steps included in comments   
`h` up to date --help  
`o` output result to given var or FD  
`m` man page completed  
`n` pass scalars (also) by name (in applicable functions)   
`p` positionals (parse canonical params before involving `getopt`)  
`s` standalone function (no deps on any other function)  
`t` tests provided  
`u` unified names for options across functions  
`v` Verbosity levels or TMI  
`-` possibility provided to get params from stdin  
    
  
[c]: #features  "completions"
[d]: #features  "documentation"
[h]: #features  "help"
[o]: #features  "output"
[m]: #features  "man"
[n]: #features  "pass-by-name"
[p]: #features  "positionals"
[s]: #features  "standalone"
[t]: #features  "tests"
[u]: #features  "unified"
[v]: #features  "verbosity"
  
  
### Definitions
(used in comments, help sections, man pages)   
**identifier**  a word consisting solely of underscores, digits and alphabetic characters from the POSIX portable character set. First char must not be a digit.  
`[[:alpha:]_][[:alnum:]_]+`  
**portable character set**  POSIX portable character set consists of 8 chars from Control Character Set: NULL, BELL, BACKSPACE, TAB, CARRIAGE RETURN, LINE FEED, VERTICAL TAB, FORM FEED and X characters from ASCII range 32-126.  
**FQPN**  Fully qualified path name.  
**name**  a word consisting solely of underscores, digits and alphabetics.  
**char**  Any character.  
**string**  Sequence of characters.  
**substring**  Sequence of characters that are part of the string.  
**filename**  POSIX portable filename, hyphen not 1st char.  
`[[:alnum:]._][[:alnum:].-_]+`  
**pathname**  POSIX portable filename, hyphen not 1st char.  
`[[:alnum:]._/][[:alnum:].-_/]+`   
**alias**  POSIX portable name of alias.  
`[[:alnum:].-_/!%,@]`  
**var**  Name of scalar or array variable.  
**scalar**  Name of scalar variable.  
**array**  Name of array variable.  
**assoc**  Array whose keys are strings.    
**indexed**  Array whose indexes are numeric.  
**packed array**  Indexed array with contiguous indexes that start from 0.  
**sparse array**  Indexed array with non-contiguous indexes.  
**whitespace**  Space, tab, vertical tab, new line.  
**flag**  Option with 2 states: present/absent.  
**argument**  Argument to an option.  
**required**  Required argument.  
**optional**  Optional argument.  
  
