#!/usr/bin/env bash

set -e

test -z "$Build_Debug" || set -x

test -z "$Build_Deps_Default_Paths" || {

  test -n "$SRC_PREFIX" || {
    test -w /src/ \
      && SRC_PREFIX=/src/ \
      || SRC_PREFIX=$HOME/build
  }

  test -n "$PREFIX" || {
    test -w /usr/local/ \
      && PREFIX=/usr/local/ \
      || PREFIX=$HOME/.local
  }
}

test -n "$sudo" || sudo=
test -z "$sudo" || pref="sudo $pref"
test -z "$dry_run" || pref="echo $pref"

test -w /usr/local || {
  test -n "$sudo" || pip_flags=--user
}


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


test -n "$GIT_HOOK_NAMES" || GIT_HOOK_NAMES="apply-patch commit-msg post-update pre-applypatch pre-commit pre-push pre-rebase prepare-commit-msg update"


generate_git_hooks()
{
  # Create default script from pd-check
  test -n "$package_pd_meta_git_hooks_pre_commit_script" || {
    package_pd_meta_git_hooks_pre_commit_script="pd check $package_pd_meta_check"
  }

	for script in $GIT_HOOK_NAMES
	do
		t=$(eval echo \$package_pd_meta_git_hooks_$(echo $script|tr all '_'))
		test -n "$t" || continue
    test -e "$t" || {
      s=$(eval echo \$package_pd_meta_git_hooks_$(echo $script|tr all '_')_script)
      test -n "$s" || {
        echo "No default git $script script. "
        return
      }

      mkdir -vp $(dirname $t)
      echo "$s" >$t
      chmod +x $t
      echo "Installed $script GIT commit hook"
    }
  done
}

install_git_hooks()
{
	for script in $GIT_HOOK_NAMES
	do
		t=$(eval echo \$package_pd_meta_git_hooks_$(echo $script|tr all '_'))
		test -n "$t" || continue
		l=.git/hooks/$script
		test ! -e "$l" || {
			test -h $l && {
				test "$(readlink $l)" = "../../$t" && continue || {
					rm $l
				}
			} ||	{
				echo "Git hook exists and is not a symlink: $l"
				continue
			}
		}
		( cd .git/hooks; ln -s ../../$t $script )
		echo "Symlinked GIT hook to script: $script -> $t"
	done
}

install_bats()
{
  echo "Installing bats"
  local pwd=$(pwd)
  test -n "$BATS_BRANCH" || BATS_BRANCH=master
  mkdir -vp $SRC_PREFIX
  cd $SRC_PREFIX
  test -n "$BATS_REPO" || BATS_REPO=https://github.com/dotmpe/bats.git
  test -n "$BATS_BRANCH" || BATS_BRANCH=master
  test -d bats || {
    git clone $BATS_REPO bats || return $?
  }
  cd bats
  git checkout $BATS_BRANCH
  ${pref} ./install.sh $PREFIX
  cd $pwd

  bats --version && {
    echo "BATS install OK"
  } || {
    echo "BATS installation invalid" 1
  }
}


main_entry()
{
  test -n "$1" || set -- all

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

  case "$1" in all|project|git )
      git --version >/dev/null || { echo "GIT required"; exit 1; }
			test -x $(which jsotk.py 2>/dev/null) || {
				test -e .package.sh || {
          echo "jsotk.py (yaml2sh) required"; exit 1;
				}
			}
			test -e .package.sh || jsotk.py yaml2sh .package.yaml [id=invidia]
			. .package.sh
    ;; esac

  case "$1" in project|package|git|git-hooks )
      # FIXME: last I checked this was broken. See tools/git-hooks
  		generate_git_hooks || return $?
  		install_git_hooks || return $?
    ;; esac

  case "$1" in all|build|test|sh-test|bats )
      test -x "$(which bats)" || install_bats || return $?
    ;; esac

  echo "OK. All pre-requisites for '$1' checked"
}

test "$(basename $0)" = "install-dependencies.sh" && {
  while test -n "$1"
  do
    main_entry "$1" || exit $?
    shift
  done
} || printf ""

# Id: git-versioning/0.0.27-test install-dependencies.sh
