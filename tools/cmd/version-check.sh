#!/bin/bash

set -e

# Id: git-versioning/0.2.1-dev tools/cmd/version-check.sh

# External hook for git-versioning.
# See V_CHECK=$V_TOP_PATH/tools/version-check.sh

test -n "$APP_ID" || exit 42
test -n "$VER_STR" || VER_STR=$1
test -n "$VER_STR" || exit 43
test -z "$2" || exit 44

e=0

while read doc
do
  # FIXME: scan all [id|version]...[app-name] lines, fail on version mismatch

  # XXX: should want to know if any mismatches, regardless wether one matches

  case "$doc" in "$V_MAIN_DOC" | *.json )
      continue;;
  esac

    ( grep -i 'version.*\<'$VER_STR'\>.*'$APP_ID $doc \
        || grep -i '[Ii]d[:=].*\<'$VER_STR'\>.*'$APPID $doc ) >> /dev/null && {
      test $verbosity -lt 3 || \
        echo "Version match in $doc"
    } || {
      test $verbosity -lt 3 || \
        echo "Version mismatch in $doc" 1>&2
      e=$(( $e + 1 ))
    }

done

exit $e
