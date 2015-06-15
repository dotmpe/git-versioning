# Id: git-versioning/0.0.20-master Rules.git-versioning.shared.mk


# print version from main file
version:
	@./bin/cli-version.sh version


# verify versioned-files
check::
	@$(echo) -n "Checking for $(APP_ID) version "
	@./bin/cli-version.sh check


# Increment patch
patch:
	@./bin/cli-version.sh increment


# Increment minor or major
release: maj := 
release:
	@./bin/cli-version.sh increment true $(maj)


# Create app/0.0.0 tag, then increment (patch)
tag:
	@git tag $(APP_ID)/$$(./bin/cli-version.sh version)
	@echo "New tag: $(APP_ID)/$$(./bin/cli-version.sh version)"
	@./bin/cli-version.sh increment $(min) $(maj)
	@./tools/cmd/prep-version.sh


# special rule targets
STRGT += \
   version \
   patch release tag \
   publish

