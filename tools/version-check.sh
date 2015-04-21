#!/bin/bash

# Id: git-versioning/0.0.14 tools/version-check.sh

V_PATH_LIST=$(cat $1)
VER_STR=$2

e=0
for doc in $V_PATH_LIST
do
  grep -i 'version.*'$2 $doc >> /dev/null && {
    echo "Version matches $2 in $doc"
  } || { 
    echo "Version mismatch in $doc"
    e=1
  }
done

exit $e
