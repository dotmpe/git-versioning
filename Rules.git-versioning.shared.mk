# Id: git-versioning/0.0.19-master Rules.git-versioning.shared.mk
# special rule targets
STRGT += \
   version \
   patch release tag \
   publish

version:
	@./bin/cli-version.sh version

check::
	@$(echo) -n "Checking for $(APP_ID) version "
	@./bin/cli-version.sh check

patch:
	@./bin/cli-version.sh increment

release: maj := 
release:
	@./bin/cli-version.sh increment true $(maj)

tag:
	@git tag $(APP_ID)/$$(./bin/cli-version.sh version)
	@echo "New tag: $(APP_ID)/$$(./bin/cli-version.sh version)"
	@./bin/cli-version.sh increment
	@./tools/cmd/prep-version.sh


