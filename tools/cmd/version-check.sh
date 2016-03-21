#!/bin/bash

# Id: git-versioning/0.0.28-dev+20160321-0517 tools/cmd/version-check.sh

# External hook for git-vesioning.
# See V_CHECK=$V_TOP_PATH/tools/version-check.sh

test -n "$APP_ID" || exit 42

V_PATH_LIST=$(cat $1)
VER_STR=$2

e=0
for doc in $V_PATH_LIST
do
  # FIXME: scan all [id|version]...[app-name] lines, fail on version mismatch

  # XXX: should want to know if any mismatches, regardless wether one matches

  test "$doc" = "$V_MAIN_DOC" && {
    continue
  } || {
    ( grep -i 'version.*\<'$2'\>.*'$APP_ID $doc \
        || grep -i '[Ii]d[:=].*\<'$2'\>.*'$APPID $doc ) >> /dev/null && {
      echo "Version match in $doc"
    } || {
      echo "Version mismatch in $doc" 1>&2
      e=$(( $e + 1 ))
    }
  }
done

exit $e
