
# created local Rules to configure and test git-versioning hooks


git-pre-commit::
	git-versioning check


git-prepare-commit-msg:
	bash .git/hooks/prepare-commit-msg.sample \
		$(COMMIT_MSG) $(COMMIT_MSG_SRC) $(COMMIT_UPDATES)
	git-versioning prepare-commit-msg \
		$(COMMIT_MSG) $(COMMIT_MSG_SRC) $(COMMIT_UPDATES)



