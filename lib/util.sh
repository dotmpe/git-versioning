#!/bin/bash

# Id: git-versioning/0.0.28-dev+20150823-1641 lib/util.sh

gitAddAll()
{
  for doc in $V_PATH_LIST
  do
    git add $V_TOP_PATH/$doc
  done
}

trueish()
{
  [ "$1" = "true" ] && {
    return 0
  } || {
    return 1
  }
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
log()
{
	[ -n "$(echo $*)" ] || return 1;
	echo "[$scriptname.sh:$cmd] $1"
}
note()
{
	[ -n "$(echo $*)" ] || return 1;
	echo "[$scriptname.sh:note] $1" 1>&2
}
err()
{
	[ -n "$(echo $*)" ] || return 1;
	echo "$1 [$scriptname.sh:$cmd]" 1>&2
	[ -n "$2" ] && exit $2
}


