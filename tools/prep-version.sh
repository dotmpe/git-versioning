#!/bin/bash

# Script to reset flags for (auto) increments

# just set pre-release tag to the branch
BRANCH=$(git status|grep On.branch|awk '{print $3}')
./tools/cli-version.sh pre-release $BRANCH

