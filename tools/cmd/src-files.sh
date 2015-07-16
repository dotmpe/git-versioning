#!/bin/bash

# Id: git-versioning/0.0.28-dev+20150716-2336 tools/cmd/src-files.sh

# Seed code for 'src-files' command. Lists (versioned) src files.


# create 'find' exclude options for each ignored filesystem path pattern
_excl()
{
  [ -e $1 ] && cat $1 \
    | grep -v '^\s*#' \
    | grep -v '^\s*$' \
    | sed -E 's/(.*)/ -a -not -path "*\/\1\/*" -a -not -name "\1" /'
}

echo $(_excl .gitignore) $(_excl .git/info/exclude) | xargs find . -type f

