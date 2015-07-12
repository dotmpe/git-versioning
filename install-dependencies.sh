#!/usr/bin/env bash

mkdir ~/test-app/{,bin}
mkdir ~/test-dep/{,bin}

test -x "$(which bats)" && {
  bats --version
} || {
  pushd $HOME
  git clone https://github.com/sstephenson/bats.git
  cd bats
  ./install.sh ~/test-dep/
  export PATH=$PATH:~/test-dep/bin/
  popd
  bats --version
}

# Id: git-versioning/0.0.27-test install-dependencies.sh
