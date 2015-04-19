#!/bin/bash
source ./lib/git-versioning.sh

testing()
{
  pre-release alpha $*
  update
}

unstable()
{
  pre-release beta $*
  update
}

snapshot()
{
  build $(date +%s)
}

info()
{
  echo "git-versioning/"$version
}

help()
{
  echo 'Usage:'
  echo 'cli-version [info]                 Print current versions. '
  echo 'cli-version version                Print current version. '
  echo 'cli-version update                 Update files with embedded version. '
  echo 'cli-version increment [min [maj]]  Increment patch/min/maj version. '
  echo 'cli-version pre-release tag[s..]   Mark version pre-release with tag(s). '
  echo 'cli-version testing [tags..]       pre-release with default: alpha. '
  echo 'cli-version unstable [tags..]      pre-release with default: beta. '
  echo 'cli-version build meta[..]         Mark version with build meta tag(s). '
  echo 'cli-version snapshot               build meta set to timestamp. '
  echo 'cli-version check                  Verify version embedded files. '
  echo 'cli-version [help|*]               Print this usage. '
}

usage()
{
  help
  exit 1
}

default=info

# Main
if [ -n "$0" ] && [ $0 != "-bash" ]; then
  # Do something if script invoked as 'vc.sh'
  if [ "$(basename $0 .sh)" = "cli-version" ]; then
    # invoke with function name first argument,
    func=$1
    [ -n "$func" ] || func=$default
    type $func &>/dev/null && {
      load
      shift 1
      $func $@
    } || {
      usage $@
    }
  fi
fi

