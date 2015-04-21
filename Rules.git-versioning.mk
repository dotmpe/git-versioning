# Id: git-versioning/0.0.13 Rules.git-versioning.mk
# special rule targets
STRGT += \
   usage \
   default \
   test \
   build \
   install \
   update \
   version \
   check \
   path release tag \
   publish

# BSD weirdness
echo = /bin/echo

DEFAULT := usage
empty :=
space := $(empty) $(empty)
usage:
	@echo 'usage:'
	@echo '# npm [info|update|test]'
	@echo '# make [$(subst $(space),|,$(STRGTS))]'

install::
	npm install
	make test

test: check

update:
	./bin/cli-version.sh update
	npm update
	bower update

build:: TODO.list

TODO.list: Makefile lib ReadMe.rst reader.rst package.yaml Sitefile.yaml
	grep -srI 'TODO\|FIXME\|XXX' $^ | grep -v 'grep..srI..TODO' | grep -v 'TODO.list' > $@

version:
	@./bin/cli-version.sh version

check:
	@$(echo) -n "Checking for $(APP_ID) version "
	@./bin/cli-version.sh check

patch:
	@./bin/cli-version.sh increment

release: maj := 
release:
	@./bin/cli-version.sh increment true $(maj)

#	@git add -u && git ci -m "$(m)"

tag:
	@git tag $(APP_ID)/$$(./bin/cli-version.sh version)
	@./bin/cli-version.sh increment
	@./tools/prep-version.sh


# XXX: GIT publish
publish: DRY := yes
publish: check
	@[ -z "$(VERSION)" ] && exit 1 || echo Publishing $(./bin/cli-version.sh version)
	git push
	@if [ $(DRY) = 'no' ]; \
	then \
		git tag v$(VERSION)
		git push fury master; \
		npm publish --tag $(VERSION); \
		npm publish; \
	else \
		echo "*DRY* $(VERSION)"; \
	fi


