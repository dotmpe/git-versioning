#!/bin/bash

# Globals

V_SH_SHARE=/usr/local/share/git-versioning
LIB=$V_SH_SHARE/lib
TOOLS=$V_SH_SHARE/tools

# Path to versioned files
V_TOP_PATH=.

# Id: git-versioning/0.0.27-master bin/cli-version.sh

source $LIB/git-versioning.sh


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
default=info


# Main
if [ -n "$0" ] && [ $0 != "-bash" ]; then
  # Do something (only) if script invoked as 'cli-version.sh'
  if [ "$(basename $0 .sh)" = "cli-version" -o "$(basename $0 .sh)" = "git-versioning" ]; then
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
        exit $e
      }
    }
  fi
fi

