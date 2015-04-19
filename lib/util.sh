#!/bin/bash

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


