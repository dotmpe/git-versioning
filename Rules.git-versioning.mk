# Id: git-versioning/0.0.18-master Rules.git-versioning.mk

# Build a tar from the local files. Tagging the build causes Travis to
# upload the package to the github releases.

include $(DIR)/Rules.git-versioning.shared.mk

empty :=
space := $(empty) $(empty)
usage::
	@echo 'usage:'
	@echo '# make [$(subst $(space),|,$(STRGT))]'

SRC += Makefile Rules.$(APP_ID).mk Rules.$(APP_ID).shared.mk .travis.yml \
			 Makefile.default-goals \
			 ReadMe.rst \
			 package.yaml package.json \
			 Sitefile.yaml \
			 lib/git-versioning.sh \
			 lib/formats.sh \
			 bin/ tools/
#			 reader.rst \


CLN += TODO.list $(APP_ID)-$(VERSION).tar
TRGT += TODO.list $(APP_ID)-$(VERSION).tar

$(APP_ID)-$(VERSION).tar: $(SRC) $(filter-out %.tar,$(TRGT))
	tar cvjf $@ $^


TODO.list: $(SRC)
	-grep -srI 'TODO\|FIXME\|XXX' $^ | grep -v 'grep..srI..TODO' | grep -v 'TODO.list' > $@

DEP += update
update:
	./bin/cli-version.sh update


#STRGT += release
#release: M=Release
#release:
#	[ -n "$(VERSION)" ] || exit 1
#	git add -u
#	git ci -m "$(M) $(VERSION)"
#	git tag $(VERSION)
#	git push origin
#	git push --tags


V_SH_SHARE := /usr/local/share/git-versioning

INSTALL += $(V_SH_SHARE)

$(V_SH_SHARE):
	@test -n "$(V_SH_SHARE)"
	@test ! -e "$(V_SH_SHARE)"
	@mkdir -p $@/
	@cp -vr bin/ $@/bin; chmod +x $@/bin/*
	@cp -vr lib/ $@/lib
	@cp -vr tools/ $@/tools; chmod +x $@/tools/*/*.sh
	@cd /usr/local/bin/;pwd;ln -vs $(V_SH_SHARE)/bin/cli-version.sh git-versioning

STRGT += uninstall reinstall

uninstall:
	@test -n "$(V_SH_SHARE)"
	@test -e "$(V_SH_SHARE)"
	@rm -vf /usr/local/bin/git-versioning
	@P=$$(dirname $(V_SH_SHARE))/$$(basename $(V_SH_SHARE)); \
	 [ "$P" != "/" ] && rm -rfv $$P

reinstall: uninstall install

