#!/bin/bash

# Before commit, set the version to snapshot, dev pre-release
# or some customized edition based on ReadMe status field.

# Id: git-versioning/0.0.16-dev+20150430-2153 tools/pre-commit.sh

V_TOP_PATH=$(git rev-parse --show-toplevel)

# FIXME source $V_TOP_PATH/lib/git-versioning.sh
source ./lib/git-versioning.sh

[ ! -e "$V_DOC_LIST" ] && {
  exit 1
}

load;

git_add_vdoc()
{
  for doc in $V_PATH_LIST
  do
    git add $doc
  done
}

# XXX again rSt hardcoded
V_STATUS=$(grep -i '^:Status:' $V_MAIN_DOC | awk '{print $2}' | tr 'A-Z' 'a-z')

case $V_STATUS in

  release )
    echo "Removing release tags.."
    _1=$(release)
    _2=$(build)
    echo "Checking files.."
    cmd_check
    #echo $?
    echo "Staging files.."
    git_add_vdoc
    ;;

  dev* )
    echo "Setting 'dev' and snapshot tags.."
    _1=$(release dev)
    _2=$(cmd_snapshot)
    echo "Checking files.."
    cmd_check
    echo "Staging files.."
    git_add_vdoc
    ;;

  mixin )
    release $V_STATUS
    cmd_check
    git_add_vdoc
    ;;

  * )
    echo "$0: Unsupported status line in $V_MAIN_DOC: $V_STATUS" 1>&2
    ;;

esac

