#!/bin/sh

version=0.0.31-dev+20160412-1532 # git-versioning

case "$ENV" in

   production )
      ./configure.sh /usr/local && sudo ENV=$ENV ./install.sh && make test
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
     ( test -n "$PREFIX" && ( ./configure.sh $PREFIX && ENV=$ENV ./install.sh ) || printf "" ) && make test ;;
esac

