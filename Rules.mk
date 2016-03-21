# created local Rules to configure and test git-versioning hooks

# Id: git-versioning/0.0.28-dev+20160321-0517 Rules.mk


git-pre-commit::
	@git-versioning check
	@./test/git-versioning.bats


git-prepare-commit-msg::
	@bash .git/hooks/prepare-commit-msg.sample \
		$(COMMIT_MSG) $(COMMIT_MSG_SRC) $(COMMIT_UPDATES)
	@./tools/cmd/append-version-to-commit-msg.sh \
		$(COMMIT_MSG) $(COMMIT_MSG_SRC) $(COMMIT_UPDATES)


git-pre-push::
	@./tools/cmd/test-for-clean-branch.sh \
		$(LOCAL_REF) $(LOCAL_SHA1)
	@#$(REMOTE_REF) $(REMOTE_SHA1)


