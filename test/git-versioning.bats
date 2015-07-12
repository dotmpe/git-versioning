#!/usr/bin/env bats

load helpers

bin=git-versioning
version=0.0.28-dev # git-versioning

@test "no arguments prints application info" {
  echo bin=${bin}
  run ${bin}
  [ $status -eq 0 ]
  [ $(expr "${lines[0]}" : "Application") -ne 0 ]
}

@test "illegal arguments prints usage and exits 1" {
  run ${bin} xxx
  [ $status -eq 1 ]
  [ $(expr "${lines[1]}" : "Usage:") -ne 0 ]
}

@test "check prints all versioned files and exits 0" {
  ${bin} check > /dev/null
  [ $? -eq 0 ]
  test -z "$(grep 'Version mismatch' $TMPF)"
}

