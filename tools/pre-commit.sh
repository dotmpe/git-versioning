#!/bin/bash

# https://gist.github.com/dotmpe/c24b2de68adbc72ae8ab

# Generic file version GIT hook for Node/semver version tags
# (YAML, JSON, JavaScript, CoffeeScript, reStructuredText) 

# Source: https://github.com/neilco/xcode-pre-commit/blob/master/git-init-pre-commit
# Adjusted for Darwin (uses BSD sed)
# Made to work from paths listed in .versioned-files.list
# Case allows easy per-project custom versioned file name/ext and format.

# Id: git-versioning/0.0.14 tools/pre-commit.sh

V_TOP_PATH=$(git rev-parse --show-toplevel)

source $V_TOP_PATH/lib/git-versioning.sh

[ ! -e "$V_DOC_LIST" ] && {
  exit 0
}

Q=$1

echo 'GIT versioning' $V_DOC_LIST '('$0') Q='$Q

onVMAJ()
{
  incrVMAJ
  gitAddAll
}

onVMIN()
{
  incrVMIN
  gitAddAll
}

onVPAT()
{
  incrVPAT
  gitAddAll
}

case "$Q" in
  *vmaj++*) load; onVMAJ;;
  *vmin++*) load; onVMIN;;
  *vpat++*) load; onVPAT;;
  * ) ;;
esac


