[bing-bash]  
  
### NAME
`typeof` - variable typing and dumping   
  
### SYNOPSIS
`bb_typeof [-t] NAME`

### DESCRIPTION
Return type of identifier as indexed array, associative array or variable.     
Dump indexed and associative arrays and variables along with their attributes.  
An identifier NAME is first passed to `type` bash builtin that will return `alias`, `keyword`, `function`, `builtin` or `file` if NAME is one of these. If not, NAME is presumed to be a variable: if it is an unset variable, `unset` will be returned, otherwise NAME is further checked and `indexed` or `associative` is returned if it is an array. `variable` is returned in case NAME is not an array, but a set variable. These single words are returned when using the `-t` switch. Without it, the process is the same, but also variable's name, value and attributes are dumped to STDOUT.   
  
### OPTIONS
With `-t` option, only the type, as a single string, is returned.   
Returned types:  
- `alias`, `keyword`, `function`, `builtin` or `file`
- `unset` (unset variable)
- `indexed` (indexed array)
- `associative` (associative array)
- `variable` (set variable)
Without the `-t` option, output is more verbose and variable contents are also dumped.

### PARAMETER
Parameter NAME can be anything: variable's name, identifier, shell keyword, 
   
### RETURN STATUS
0  great success
1  miserable failure
2  Parameter empty

### RETURN VALUE

### EXAMPLES
  
```
$ typeof -t BASH_VERSINFO
indexed

$ typeof BASH_VERSINFO
    Name: BASH_VERSINFO
    Type: indexed array [6]		# [6] - number of elements
   Value:
     [0]: 4 [1]				# [1] - length of an element
     [1]: 3 [1]
     [2]: 42 [2]
     [3]: 4 [1]
     [4]: release [7]
     [5]: x86_64 [6]
    Attr: readonly

$ typeof -t BASH_ALIASES
associative

$ typeof BASH_ALIASES
   Name: BASH_ALIASES
   Type: associative array [4]
  Value:
     [la]: ls -la    [6]
   [cd..]: cd ..     [5]
  [unset]:           [0]	# null value
     [sv]: sudo vim  [8]
   
$ typeof UID
   Name: UID
   Type: variable
  Value: 101  		[3]
   Attr: integer readonly
```
