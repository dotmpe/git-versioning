#!/bin/bash
# Id: git-versioning/0.1.1-dev tools/cmd/append-version-to-commit-msg.sh
# 1:commit-msg-file 2:commit-msg-src 3:commit-updates-sha1
APP_ID=$(git-versioning app-id)
cp $1 $1.tmp
echo "$(head -n 1 $1.tmp) ($APP_ID)" > $1
tail -n +2 $1.tmp >> $1
