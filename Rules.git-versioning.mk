# Id: git-versioning/0.0.31-dev+20160412-1532 Rules.git-versioning.mk


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

ifeq ($(ENV),development)
TAR_SRC += \
			Makefile Makefile.default-goals \
			Rules.$(PROJECT).mk Rules.$(PROJECT).shared.mk .travis.yml \
			reader.rst Sitefile.yaml \
			package.yaml package.json
else
TAR_SRC += install.sh
endif

SRC += $(TAR_SRC)

ifneq ($(ENV),development)
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


STRGT += do-release
do-release:: min := 
do-release:: maj := 
do-release::
do-release:: M=Release
do-release:: cli-version-check
	[ -n "$(VERSION)" ] || exit 1
	git ci -m "$(M) $(VERSION)"
	git tag $(VERSION)
	git push origin
	git push --tags
	./bin/cli-version.sh increment $(min) $(maj)
	./tools/cmd/prep-version.sh
	@git add $$(echo $$(cat .versioned-files.list))

# install/uninstall
V_SH_SHARE := /usr/local/share/git-versioning

INSTALL += $(V_SH_SHARE)

STRGT += reset uninstall

$(V_SH_SHARE):
	@ENV=production ./configure.sh /usr/local
	@ENV=production sudo ./install.sh install

reset::
	@ENV=production ./configure.sh

uninstall::
	@ENV=production ./configure.sh /usr/local
	@ENV=production sudo ./install.sh uninstall

test-run::
	test -z "$$PREFIX" && ./bin/cli-version.sh || git-versioning

test-tags::
	test -z "$$PREFIX" && ./bin/cli-version.sh check || git-versioning check

test-specs::
	./test/git-versioning-spec.bats
	#./test/git-versioning-spec.rst

TEST := test-run test-tags test-specs


