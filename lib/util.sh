#!/bin/bash

# Id: git-versioning/0.0.31-dev+20160321-0713 lib/util.sh

gitAddAll()
{
  for doc in $V_PATH_LIST
  do
    git add $V_TOP_PATH/$doc
  done
}

sed_rewrite="sed "
[ "$(uname -s)" = "Darwin" ] && sed_rewrite="sed -i.applyBack "

# TODO: make sed fail on no match, return 1
function sed_rewrite_tag()
{
  $sed_rewrite "$1" $2 > $2.out
  sed_post $2
}
function sed_post()
{
  test -e $1.applyBack && {
    # Darwin BSD sed
    rm $1.applyBack $1.out
  } || {
    # GNU sed
    cat $1.out > $1
    rm $1.out
  }
}


# stdio/stderr/exit util
# 1:msg 2:exit
err()
{
  log "$1" 1>&2
  [ -z "$2" ] || exit $2
}

# 1:msg 2:exit
log()
{
  test -n "$verbosity" && std_v 1 || return 0
	[ -n "$(echo $*)" ] || return 1;
  key=$scriptname.sh
  test -n "$cmd" && key=${key}${bb}:${bk}${subcmd}
  echo "[$key] $1"
}

stderr()
{
  case "$(echo $1 | tr 'A-Z' 'a-z')" in

    * )
      ;;

  esac

  err "$2" $3
}

# std-v <level>
# if verbosity is defined, return non-zero if <level> is below verbosity treshold
std_v()
{
  test -z "$verbosity" && return || {
    test $verbosity -ge $1 && return || return 1
  }
}

std_exit()
{
  test "$1" != "0" -a -z "$1" && return 1 || exit $1
}

warn()
{
  std_v 4 || std_exit $2 || return 0
  stderr "Warning" "$1" $2
}
note()
{
  std_v 5 || std_exit $2 || return 0
  stderr "Notice" "$1" $2
}
info()
{
  std_v 6 || std_exit $2 || return 0
  stderr "Info" "$1" $2
}
debug()
{
  std_v 7 || std_exit $2 || return 0
  stderr "Debug" "$1" $2
}

# demonstrate log levels
std_demo()
{
  scriptname=std cmd=demo
  log "Log line"
  err "Log line"
  warn "Foo bar"
  note "Foo bar"
  info "Foo bar"
  debug "Foo bar"

  for x in warn note info debug
    do
      $x "testing $x out"
    done
}

trueish()
{
  test -n "$1" || return 1
  case "$1" in
    on|true|yes|1)
      return 0;;
    * )
      return 1;;
  esac
}



