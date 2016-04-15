source ${0:a:h}/colors.zsh

readonly STATUS_LINES='^\((return status = 0)\|\|([0-9]\+ rows\? affected)\)$'
PARSE='zparseopts -D -E -- v=verbose -verbose=verbose h=help -help=help -csv=csv'
SCRIPTNAME=
DESCRIPTION=
ARGUMENTS=
YES=
NO=
OPTIONS=
TODAY=$(date +%Y%m%d)

day_of_week=$(date +%w)
if [[ $day_of_week == 1 ]]; then
  lookback=3
else
  lookback=1
fi

YESTERDAY=$(date --date="$lookback day ago" +%Y%m%d)

ONE_MONTH_AGO=$(date --date='-1 month' +%Y%m%d)
typeset -a ARGUMENT_NAMES
typeset -A DEFAULTS
typeset -A NO
typeset -A YES

description() {
  DESCRIPTION=$1
}

help() {
  cat <<END
$DESCRIPTION

Usage:
  $SCRIPTNAME [options] <arguments>

Arguments:
$ARGUMENTS
Options:
$OPTIONS     --csv             output as CSV
  -v --verbose         verbose output
  -h --help            show this message
END
  exit $1
}

argument() {
  local line
  zformat -f line '  %17.17a    %d' a:"<$1>" d:$2
  ARGUMENTS+="$line"$'\n'
  ARGUMENT_NAMES+=$1
}

option() {
  local line
  [[ -n $2 ]] && PARSE+=" $2:=$1"

  zformat -f line '  -%1.1s --%12.12l    %d' s:$2 l:$1 d:$3

  if [[ -n $4 ]]; then
    DEFAULTS+=($1 $4)
    line+=" (default: $4)"
  fi

  PARSE+=" -$1:=$1"
  OPTIONS+="$line"$'\n'
}

toggle() {
  local line
  local yes=1
  local no=0
  [[ -n $2 ]] && PARSE+=" $2=$1"
  [[ -n $4 ]] && yes=$4
  [[ -n $5 ]] && no=$5

  zformat -f line '  -%1.1s --%12.12l    %d' s:$2 l:$1 d:$3
  NO+=($1 $no)
  YES+=($1 $yes)

  PARSE+=" -$1=$1"
  OPTIONS+="$line"$'\n'
}

parse() {
  SCRIPTNAME=${1:t}
  shift

  # Show help if no arguments are supplied
  [[ $# -eq 0 ]] && (( $#ARGUMENTS )) && help

  eval $PARSE

  [[ -n $help ]] && help

  for k in ${(k)DEFAULTS}; do
    if [[ -n ${(P)k} ]]; then
      eval ${k}=${${(P)k}[2]}
    else
      eval ${k}=${DEFAULTS[$k]}
    fi
  done

  for t in ${(k)YES}; do
    if [[ -n ${(P)t} ]]; then
      eval ${t}=${YES[$t]}
    else
      eval ${t}=${NO[$t]}
    fi
  done

  for a in $ARGUMENT_NAMES; do
    if [[ $# -eq 0 ]]; then
      if [[ ! -n "${(P)a}" ]]; then
        help
      fi
    else
      eval ${a}=$1
      shift
    fi
  done
}

info() {
  if [[ -n $verbose ]]; then
    print $@
  fi
}

sql() {
  zparseopts -D -E -- l=list -list=list -no_commas=no_commas
  sql="$(cat)"

  if [[ -n $verbose ]]; then
    if type pygmentize > /dev/null; then
      print $sql | pygmentize -l sql
    else
      print $sql
    fi
    print
  fi

  fmt_args=()
  [[ -n $no_commas ]] && fmt_args+=(--no_commas)
  sql="set nocount on\nset proc_return_status off\n$sql"

  if [[ -n $list ]]; then
    print $sql | isql -w999 | sed -n -e '3,${s/^[[:blank:]]*//; p}'
  else
    print $sql | isql -w999
  fi
}

# Define a variable by reading from a heredoc in the form
#
# define VAR <<END
# abc
# 123
# END
define() {
  # Read line by line into a variable with name equal to the first argument
  IFS='\n' read -r -d '' ${1} || true

  # Strip final newline
  eval "${1}=\${(P)1%?}"
}

client_is() {
  [[ "$(getfile ClientAbbrev)" == "$1" ]]
}

table() {
  if [[ -n $ALT_DBF ]]; then
    schema=$ALT_DBF
  else
    schema=/usr/local/bfm/std/dbschema.dat
  fi
  grep -m 1 "^$1\\b" $schema | cut -d' ' -f2
}

first_word() {
  sed -n 3p | tr -d ' '
}

format_string() {
  format_sql "convert(char($1), $2)" $2 $3
}

format_number() {
  format_sql "convert(decimal($1, $2), $3)" $3 $4
}

format_date() {
  format_sql "str_replace(convert(char(10), $1, 121), \"/\", \"-\")" $1 $2
}

format_time() {
  format_sql "str_replace(convert(char(16), $1, 121), \"/\", \"-\")" $1 $2
}


format_sql() {
  if [[ -n $csv ]]; then
    if [[ -n $3 ]]; then
      print -- "$2 as $3"
    else
      print -- "$2"
    fi
  else
    [[ -n $3 ]] || 3="${2##*.}"
    print -- "$1 as $3"
  fi
}
