#!/bin/bash

# Id: git-versioning/0.0.15-dev+20150422-0230 bin/cli-version.sh

source ./lib/git-versioning.sh


usage()
{
  cmd_help
  exit 1
}

default=cmd_info

# Main
if [ -n "$0" ] && [ $0 != "-bash" ]; then
  # Do something if script invoked as 'vc.sh'
  if [ "$(basename $0 .sh)" = "cli-version" ]; then
    # invoke with function name first argument,
    func=cmd_$(echo $1 | tr '-' '_')
    [ -n "$func" ] || func=$default
    type $func &>/dev/null && {
      load
      shift 1
      $func $@
    } || {
      e=$?
      [ "$e" = "1" ] && {
        usage
      } || {
        echo Error $e 1>&2
      }
    }
  fi
fi

