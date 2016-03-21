#!/bin/bash

# Id: git-versioning/0.0.28-dev+20160321-0517 tools/cmd/prep-version.sh

# Script to reset flags for (auto) increments


# just set pre-release tag to the branch
BRANCH=$(git status|grep On.branch|awk '{print $3}')
echo BRANCH=$BRANCH
./bin/cli-version.sh pre-release $BRANCH

