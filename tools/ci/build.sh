#!/bin/sh

./bin/cli-version version &&
version=$(./bin/cli-version version) ||
version=0.2.4 # git-versioning

case "$ENV_NAME" in

   production )
      test -n "$PREFIX" || PREFIX=/usr/local/
      $sudo test -w "$PREFIX" || {
          echo "PREFIX must be writable: '$PREFIX'">&2
          exit 1
        }
      ./configure.sh /usr/local && $sudo ENV_NAME=$ENV_NAME ./install.sh && make test
      # strip meta tags
      DESCRIBE="$(echo "$version" | awk -F+ '{print $1}')"
      grep '^'$DESCRIBE'$' ChangeLog.rst && {
        make build
      } || {
        echo "Not a release: missing change-log entry $DESCRIBE: grep $DESCRIBE ChangeLog.rst)"
        echo "Not building package"
      }
    ;;

   test* | dev* )
     ./configure.sh && make build test ;;

   * )
     ( test -n "$PREFIX" && ( ./configure.sh $PREFIX && ENV_NAME=$ENV_NAME ./install.sh ) || printf "" ) && make test ;;

esac

