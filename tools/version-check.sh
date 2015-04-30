#!/bin/bash

# Id: git-versioning/0.0.16-dev+20150430-2146 tools/version-check.sh

V_PATH_LIST=$(cat $1)
VER_STR=$2

e=0
for doc in $V_PATH_LIST
do
  # XXX: should want to know if any mismatches, regardless wether one matches
  grep -i 'version.*'$2 $doc >> /dev/null && {
    echo "Version match in $doc"
  } || { 
    echo "Version mismatch in $doc" 1>&2
    e=$(( $e + 1 ))
  }
done

exit $e
