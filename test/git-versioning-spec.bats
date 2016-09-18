#!/usr/bin/env bats

load helpers

bin=bin/cli-version.sh
version=0.1.2-dev # git-versioning

@test "no arguments prints application info" {
  verbosity=3
  case "$(uname)" in
    Linux ) x=2 ;;
    Darwin ) x=1 ;;
  esac
  x=1
  run ${bin}
  [ $status -eq 0 ]
  [ $(expr "${lines[$x]}" : "Application") -ne 0 ] || \
    fail "Out: $(${bin})"
}

@test "illegal arguments prints usage and exits 1" {
  verbosity=3
  x=2
  run ${bin} xxx
  [ $status -eq 1 ]
  [ $(expr "${lines[$x]}" : "Usage:") -ne 0 ]
}

@test "check prints all versioned files and exits 0" {
  verbosity=3
  ${bin} check > /dev/null
  [ $? -eq 0 ]
  test -z "$(grep 'Version mismatch' $TMPF)"
}

