#!/usr/bin/env bash

set -e

test -z "$Build_Debug" || set -x

test -n "$sudo" || sudo=



install_bats()
{
  echo "Installing bats"
  local pwd=$(pwd)
  mkdir -vp $SRC_PREFIX
  cd $SRC_PREFIX
  git clone https://github.com/sstephenson/bats.git
  cd bats
  ${sudo} ./install.sh $HOME/.local
  cd $pwd

  bats --version && {
    echo "BATS install OK"
  } || {
    echo "BATS installation invalid" 1
  }
}


main_entry()
{
  test -n "$1" || set -- '*'

  case "$1" in build )
			test -n "$SRC_PREFIX" || {
				echo "Not sure where checkout"
				exit 1
			}

			test -n "$PREFIX" || {
				echo "Not sure where to install"
				exit 1
			}

			test -d $SRC_PREFIX || ${sudo} mkdir -vp $SRC_PREFIX
			test -d $PREFIX || ${sudo} mkdir -vp $PREFIX
		;;
	esac

  case "$1" in '*'|project|git )
      git --version >/dev/null || { echo "GIT required"; exit 1; }
			test -x $(which jsotk.py 2>/dev/null) || {
				test -e .package.sh || {
          echo "jsotk.py (yaml2sh) required"; exit 1;
				}
			}
			test -e .package.sh || jsotk.py yaml2sh .package.yaml [id=invidia]
			. .package.sh
    ;; esac

  case "$1" in '*'|project|git )
      test -x "$(which pd)" || { echo "Pd (projectdir.sh) required"; exit 1; }
  		pd update . || return $?
    ;; esac

  case "$1" in '*'|build|test|sh-test|bats )
      test -x "$(which bats)" || install_bats || return $?
    ;; esac

  echo "OK. All pre-requisites for '$1' checked"
}

test "$(basename $0)" = "install-dependencies.sh" && {
  main_entry $@ || exit $?
}

# Id: git-versioning/0.0.27-test install-dependencies.sh
