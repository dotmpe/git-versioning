#!/bin/sh
set -e
test -n "$scriptpath" || scriptpath=$HOME/bin
test -d "$scriptpath" || { echo "scriptpath" >&2; exit 1; }
test -n "$local_lib" || local_lib=lib/util.sh

for llib in $local_lib
do
  htd ls-func $llib | sed 's/()//g' | while read fname
  do
    grep -l "^$fname()" $scriptpath/*.lib.sh | while read lib
    do
      echo $lib $fname
      htd diff-function $llib $fname $lib
    done
  done
done
# Id: git-versioning/0.2.9 tools/sh/sync-lib.sh
