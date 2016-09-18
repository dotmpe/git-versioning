# Id: git-versioning/0.1.3 tools/git-hooks/pre-commit.sh
#make git-pre-commit
#pd check :make:git-pre-commit
#pd check
pd run :vchk :bats-specs :bats:test/git-versioning-spec.bats
