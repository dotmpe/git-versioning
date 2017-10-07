# Id: git-versioning/0.2.0-dev Rules.git-hooks.shared.mk

# http://git-scm.com/docs/githooks

git-applypatch-msg::
git-pre-applypatch::
git-post-applypatch::
git-pre-commit::

git-prepare-commit-msg:: COMMIT_MSG      :=
git-prepare-commit-msg:: COMMIT_MSG_SRC  :=
git-prepare-commit-msg:: COMMIT_UPDATES  :=
git-prepare-commit-msg::

git-post-update::
git-commit-msg::
git-post-commit::
git-pre-rebase::
git-post-checkout::
git-post-merge::

git-pre-push:: LOCAL_REF :=
git-pre-push:: LOCAL_SHA1 :=
git-pre-push:: REMOTE_REF :=
git-pre-push:: REMOTE_SHA1 :=
git-pre-push::

git-pre-receive::
git-update::
git-post-receive::
git-post-update::
git-push-to-checkout::
git-pre-auto-gc::
git-post-rewrite::


STRGT += \
				git-applypatch-msg \
				git-pre-applypatch \
				git-post-applypatch \
				git-pre-commit \
				git-prepare-commit-msg \
				git-post-update \
				git-commit-msg \
				git-post-commit \
				git-pre-rebase \
				git-post-checkout \
				git-post-merge \
				git-pre-push \
				git-pre-receive \
				git-update \
				git-post-receive \
				git-post-update \
				git-push-to-checkout \
				git-pre-auto-gc \
				git-post-rewrite

