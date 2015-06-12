#!/bin/bash

# Id: git-versioning/0.0.16-master bin/cli-version.sh

source ./lib/git-versioning.sh


usage()
{
  cmd_help
  exit 1
}

cmd_release()
{
  release $*
}
cmd_pre_release()
{
  release $*
}
cmd_build()
{
  build $*
}
default=cmd_info

# Main
if [ -n "$0" ] && [ $0 != "-bash" ]; then
  # Do something (only) if script invoked as 'cli-version.sh'
  if [ "$(basename $0 .sh)" = "cli-version" ]; then
    # invoke with function name first argument,
    func=$(echo $1 | tr '-' '_')
    # or default
    [ -n "$func" ] || func=$default
    type cmd_$func &>/dev/null && {
      load
      shift 1
      cmd_$func $@
    } || {
      # or print usage
      e=$?
      [ "$e" = "1" ] && {
        load
        usage
      } || {
        echo Error $e 1>&2
      }
    }
  fi
fi

