#!/bin/bash

set -e

# Globals

V_SH_SHARE=.
LIB=$V_SH_SHARE/lib
TOOLS=$V_SH_SHARE/tools

# Path to versioned files
V_TOP_PATH=.

# Id: git-versioning/0.0.30 bin/cli-version.sh

source $LIB/git-versioning.sh

scriptname=git-versioning


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


# Main

def_func=cmd_info

if [ -n "$0" ] && [ $0 != "-bash" ]; then

  # Do something (only) if script invoked as ...
  base=$(basename $0 .sh)
  case "$base" in

    $scriptname | cli-version )

      test -n "$verbosity" || verbosity=3

      # function name first as argument,
      cmd=$1
      [ -n "$def_func" -a -z "$cmd" ] \
        && func=$def_func \
        || func=$(echo cmd_$cmd | tr '-' '_')

      # load/exec if func exists
      type $func &> /dev/null && {
        func_exists=1
        load
        shift 1
        $func $@
      } || {
        # handle non-zero return or print usage for non-existant func
        e=$?
        [ -z "$cmd" ] && {
          load
          usage
          err 'No command given, see "help"' 1
        } || {
          [ "$e" = "1" -a -z "$func_exists" ] && {
            load
            usage
            err "No such command: $cmd" 1
          } || {
            err "Command $cmd returned $e" $e
          }
        }
      }

      ;;

    * )
      echo No frontend for $base

  esac
fi

