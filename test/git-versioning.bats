#!/usr/bin/env bats

load helpers

bin=bin/cli-version.sh
version=0.0.30-dev+20160321-0641 # git-versioning

@test "no arguments prints application info" {
  run ${bin}
  [ $status -eq 0 ]
  [ $(expr "${lines[1]}" : "Application") -ne 0 ]
}

@test "illegal arguments prints usage and exits 1" {
  run ${bin} xxx
  [ $status -eq 1 ]
  [ $(expr "${lines[2]}" : "Usage:") -ne 0 ]
}

@test "check prints all versioned files and exits 0" {
  ${bin} check > /dev/null
  [ $? -eq 0 ]
  test -z "$(grep 'Version mismatch' $TMPF)"
}

