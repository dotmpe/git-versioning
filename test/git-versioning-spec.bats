#!/usr/bin/env bats

load helpers

bin=bin/cli-version.sh
version=0.2.9-dev # git-versioning

@test "no arguments prints application info" {
  verbosity=3
  run ${bin}
  [ $status -eq 0 ]
  [ $(expr "${lines[0]}" : "Application") -ne 0 ] || \
    fail "Out: $(${bin})"
}

@test "illegal arguments prints usage and exits 1" {
  verbosity=3
  run ${bin} xxx
  [ $status -eq 1 ]
  [ $(expr "${lines[1]}" : "Usage:") -ne 0 ]
}

@test "check prints all versioned files and exits 0" {
  verbosity=3
  ${bin} check > /dev/null
  [ $? -eq 0 ]
  test -z "$(grep 'Version mismatch' $TMPF)"
}
