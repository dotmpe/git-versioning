#!/bin/sh

case "$ENV" in
   production )
      ./configure.sh /usr/local && sudo ENV=$ENV ./install.sh && make test build
      grep '^'$TRAVIS_TAG'$' ChangeLog.rst && {
        echo "TODO: get log, tag"
        exit 1
      } || {
        echo "Not a release: missing change-log entry $TRAVIS_TAG: grep $TRAVIS_TAG ChangeLog.rst)"
      }
    ;;
   test* | dev* )
     ./configure.sh && make build test ;;
   * )
     ( test -n "$PREFIX" && ( ./configure.sh $PREFIX && ENV=$ENV ./install.sh ) || printf "" ) && make test ;;
esac

