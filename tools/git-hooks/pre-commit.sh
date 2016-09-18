# Id: git-versioning/0.1.1-dev tools/git-hooks/pre-commit.sh
#make git-pre-commit
#pd check :make:git-pre-commit
pd check :vchk :bats-specs :bats:test/git-versioning-spec
