#!/bin/bash bingmsg
#=======================================================================
#: FILE: field.bash
#: PATH: $BING_FUNC/strings/field.bash
#: TYPE: function
#:   NS: shell:bash:mandober:bing-bash:function:bb_field
#:  CAT: strings
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: AUTHOR:
#:      bing-bash by Ivan Ilic <ivanilic1975@gmail.com>
#:      https://github.com/mandober/bing-bash
#:      za Ǆ - Use freely at owns risk
#:      2-Apr-2016 (last revision)
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: NAME:
#:      bb_field
#:
#: BRIEF:
#:      Return specific field.
#:
#: DESCRIPTION:
#:      Output specific field (fields are separated by white space)
#:      from the input string. Fields are 0 indexed.
#:
#: DEPENDENCIES:
#:      none
#:
#: EXAMPLE:
#:      bb_field -f1 abc def  # outputs: def
#:      bb_field abc def      # outputs: abc
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: SYNOPSIS:
#:      bb_field -f N STRING
#:      bb_field -f=N STRING
#:      bb_field -fN STRING
#:
#: OPTIONS:
#:      -f <option> N <argument>
#:      With -f option user can specify numeric argument corresponding
#:      to a particular field of the string. Default field is 0.
#:
#: PARAMETERS:
#:      STRING <string>
#:      String contains white-space separated fields (words).
#:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#: STDOUT:
#:      Outputs specified field.
#:
#: STDERR:
#:      Error messages.
#:
#: RETURN CODE:
#:      0  great success
#:      1  miserable failure
#:      2  Parameter empty
#=======================================================================

# cut style field ranges:
#   N    N'th field, counted from 1
#   N-   from N'th field, to end of line
#   N-M  from N'th to M'th field (inclusive)
#   -M   from first to M'th field (inclusive)
#   -    all fields
# Multiple fields/ranges can be separated with commas


bb_field() {
#                                                                  ABOUT
#                                                                  =====
 local -r bbapp="${FUNCNAME[0]}"
 local -r bbnfo="[bing-bash] $bbapp v.0.0.2"
 local -r usage="USAGE: $bbapp -fN STRING"

#                                                               PRECHECK
#                                                               ========
  if [[ $# -eq 0 ]]; then
    printf "\e[2m%s: %s\e[0m\n" "$bbapp" "Parameter empty" >&2
    printf "%s\n" "$usage" >&2
    return 2
  fi

#                                                                   HELP
#                                                                   ====
  [[ $1 =~ ^(-u|--usage)$ ]] && { printf "%s\n" "$usage"; return 0; }
  [[ $1 =~ ^(-v|--version)$ ]] && { printf "%s\n" "$bbnfo"; return 0; }
  [[ $1 =~ ^(-h|--help)$ ]] && {
	cat <<-EOFF
	$bbnfo
	  Pattern matching helper functions.
	$usage
	  PROPERTY is one of the following:
	        alpha - check if string consist of alphabetic chars only

	OPTIONS:
	   -h, --help        Show program help.
	   -u, --usage       Show program usage.
	   -v, --version     Show program version.
	EOFF
	return 0
 }

#                                                                    SET
#                                                                    ===
 shopt -s extglob extquote; shopt -u nocasematch; set -o noglob
 trap "set +o noglob" RETURN ERR SIGHUP SIGINT SIGTERM

#                                                                 PARAMS
#                                                                 ======
local bbField

unset bbFields
local -a bbFields=()

# assing
while [[ "${1+def}" ]]; do
  case $1 in
    -f=*|--field=*) bbField="${1#*=}";;
        -f|--field) bbField="${2?}"; shift;;
               -f*) bbField="${1#??}";;
    *) bbFields+=("$1");;
  esac
shift
done

# defaults
bbField="${bbField:-0}"

# debug
# echo "bbField: $bbField"
# typeof bbFields

# output
printf "%s" "${bbFields[$bbField]}"
return 0



} # $BING_FUNC/strings/field.bash
