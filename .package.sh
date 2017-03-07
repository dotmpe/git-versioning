
package_environments__0=development
package_id=git-versioning
package_main=git-versioning
package_pd_meta_check=":vchk :bats-specs :bats:test/git-versioning-spec.bats"
package_pd_meta_git_hooks_pre_commit=./tools/git-hooks/pre-commit.sh
package_pd_meta_init="./install-dependencies.sh all"
package_pd_meta_test=":bats"
package_scripts_check__0="git-versioning check"
package_scripts_check__1="bats -c test/*-spec.bats"
package_scripts_check__2="bats test/git-versioning-spec.bats"
package_scripts_init__0="Build_Deps_Default_Paths=1 ./install-dependencies.sh all"
package_scripts_test__0="bats test/*-spec.bats"
package_type=application/x-project-mpe
package_version=0.1.4-dev
