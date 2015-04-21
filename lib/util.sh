#!/bin/bash

# Id: git-versioning/0.0.14 lib/util.sh

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


