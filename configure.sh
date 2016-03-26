#!/usr/bin/env bash

source lib/util.sh

[ -n "$ENV" ] || ENV=development
echo "Environment: $ENV"

[ -n "$1" ] && PREFIX=$1
[ -n "$PREFIX" ] || PREFIX=.
echo "Prefix: $PREFIX"

[ "." != "$PREFIX" ] && V_SH_SHARE=$PREFIX/share/git-versioning || V_SH_SHARE=$PREFIX
echo "Location: $V_SH_SHARE"

P=$(echo $PREFIX | sed 's/\//\\\//g')
sed_rewrite_tag 's/^PREFIX=.*/PREFIX='$P'/' install.sh

[ "." != "$PREFIX" ] \
  && sed_rewrite_tag 's/^bin=.*/bin=git-versioning/' test/git-versioning-spec.bats \
  || sed_rewrite_tag 's/^bin=.*/bin=bin\/cli-version.sh/' test/git-versioning-spec.bats

P=$(echo $V_SH_SHARE | sed 's/\//\\\//g')
sed_rewrite_tag 's/^V_SH_SHARE=.*/V_SH_SHARE='$P'/' install.sh
sed_rewrite_tag 's/^V_SH_SHARE=.*/V_SH_SHARE='$P'/' bin/cli-version.sh

echo "Rewrote installer and bin/cli-version include paths"


# reset .versioned-files.list
(
cat <<HEREDOC
ReadMe.rst
package.json
package.yaml
bin/cli-version.sh
lib/git-versioning.sh
lib/util.sh
lib/formats.sh
tools/git-hooks/prepare-commit-msg.sh
tools/git-hooks/pre-commit.sh
tools/git-hooks/pre-push.sh
tools/cmd/version-check.sh
tools/cmd/prep-version.sh
tools/cmd/src-files.sh
tools/cmd/src-tree.sh
tools/cmd/append-version-to-commit-msg.sh
tools/cmd/test-for-clean-branch.sh
Makefile
Rules.mk
Rules.git-versioning.mk
Rules.git-versioning.shared.mk
Rules.git-hooks.shared.mk
test/git-versioning-spec.bats
test/helpers.bash
HEREDOC
) > .versioned-files.list
echo "Reset .versioned-files.list"


# for dev and test add test files
[ "$ENV" == "production" ] || {
	(
		cat <<HEREDOC
test/example/rst_field_version.rst
test/example/rst_field_id.rst
test/example/unix_comment_id.sh
test/example/unix_comment_version.sh
test/example/mk_var_version.mk
test/example/sh_var_version.sh
test/example/yaml_version.yaml
test/example/json_version.json
test/example/js_var_version.js
test/example/coffee_var_version.coffee
test/example/properties_version.properties
test/example/build.xml
test/example/clike_line_comment_id.js
test/example/clike_line_comment_id.jade
HEREDOC
	) >> .versioned-files.list
	echo "Test files appended to .versioned-files.list"
}

# Id: git-versioning/0.0.27-master configure.sh
