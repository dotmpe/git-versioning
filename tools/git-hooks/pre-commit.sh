set -e

git-versioning check
bats -c test/*-spec.bats
bats test/git-versioning-spec.bats

# Id: git-versioning/0.2.4 tools/git-hooks/pre-commit.sh
