#!/bin/bash

# Id: git-versioning/0.1.4-dev tools/cmd/prep-version.sh

# Script to reset flags for (auto) increments


# just set pre-release tag to the branch
BRANCH=$(git status|grep On.branch|awk '{print $3}')
echo BRANCH=$BRANCH
./bin/cli-version.sh pre-release $BRANCH

