# Id: git-versioning/0.2.7-dev Rules.git-versioning.mk


empty :=
space := $(empty) $(empty)
usage::
	@echo '[$(PROJECT)] usage:'
	@echo '# make [$(subst $(space),|,$(STRGT))]'


# Build a tar from the local files. Tagging the build causes Travis to
# upload the package to the github releases.

TAR_SRC += \
			ReadMe.rst \
			lib/git-versioning.sh \
			lib/formats.sh \
			bin tools

ifeq ($(ENV_NAME),development)
TAR_SRC += \
			Makefile Makefile.default-goals \
			Rules.$(PROJECT).mk Rules.$(PROJECT).shared.mk .travis.yml \
			reader.rst Sitefile.yaml \
			package.yaml
else
TAR_SRC += install.sh
endif

SRC += $(TAR_SRC)

ifneq ($(ENV_NAME),development)
CLN += $(PROJECT)-$(VERSION).tar
TRGT += $(PROJECT)-$(VERSION).tar
endif

$(PROJECT)-$(VERSION).tar: $(TAR_SRC) $(filter-out %.tar,$(TRGT))
	tar cvjf $@ $^


# Include a list of tasks with build
TRGT += TODO.list
CLN += TODO.list
TODO.list: $(SRC)
	-grep -nsrI 'TODO\|FIXME\|XXX' $^ | grep -v 'grep..srI..TODO' | grep -v 'TODO.list' > $@


# not sure where to keep these.. DEPs, build..

#DEP += .cli-version-update
.cli-version-update: ReadMe.rst $(shell echo $$(cat .versioned-files.list ))
	@echo $@ Because $?
	./bin/cli-version.sh update
	touch $@


cli-version-check::
	./bin/cli-version.sh check


# Release current version. Need to prepare source first.
STRGT += do-release
do-release:: min := 
do-release:: maj := 
do-release::
do-release:: M=Release
do-release:: cli-version-check
	VERSION="$$(./bin/cli-version.sh version)"; \
	[ -n "$$VERSION" ] || exit 1; \
	grep '^'$$VERSION'$$' ChangeLog.rst || { \
		echo "Please fix version or the ChangeLog: $$VERSION"; \
		exit 2; }
	ENV_NAME=testing ./configure.sh \
		&& git-versioning update && htd run check
	ENV_NAME=production ./configure.sh
	git add -u
	VERSION="$$(./bin/cli-version.sh version)"; \
	git commit -m "$(M) $$VERSION"; \
	git tag -a -m "$(M) $$VERSION" $$VERSION
	git push origin
	git push --tags
	@# Increment and tag
	@./bin/cli-version.sh increment $(min) $(maj)
	@#./tools/cmd/prep-version.sh
	@ENV_NAME= ./configure.sh \
		&& ./bin/cli-version.sh pre-release dev
	@# Stage changes
	@git reset .versioned-files.list
	@git checkout .versioned-files.list
	@VERSION="$$(./bin/cli-version.sh version)"; \
	[ -n "$$VERSION" ] || exit 1; \
	{ echo "" ; \
		echo "($$VERSION)" ;  \
		echo "  .." ; } >> ChangeLog.rst
	@git add -u

# install/uninstall
V_SH_SHARE := /usr/local/share/git-versioning

INSTALL += $(V_SH_SHARE) reset

STRGT += reset uninstall

$(V_SH_SHARE):
	@ENV_NAME=production ./configure.sh /usr/local
	@ENV_NAME=production sudo ./install.sh install

reset::
	@ENV_NAME=production ./configure.sh

uninstall::
	@ENV_NAME=production ./configure.sh /usr/local
	@ENV_NAME=production sudo ./install.sh uninstall

test-run::
	test -z "$$PREFIX" && ./bin/cli-version.sh || git-versioning

test-tags::
	test -z "$$PREFIX" && ./bin/cli-version.sh check || git-versioning check

test-specs::
	./test/git-versioning-spec.bats
	#./test/git-versioning-spec.rst

TEST := test-run test-tags test-specs reset
