# special rule targets
STRGTS := \
   usage \
   default \
   info \
   test \
   build \
   install \
   update \
   version \
   check \
   increment \
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

info:
	@./bin/cli-version.sh

version:
	@./bin/cli-version.sh version

check:
	@$(echo) -n "Checking for version "
	@./bin/cli-version.sh check

patch: m :=
patch:
	@git add -u && git ci -m "$(strip $(m) $$(./bin/cli-version.sh version))"
	@git tag $$(./bin/cli-version.sh version)
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


